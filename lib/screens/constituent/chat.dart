import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/get_functions.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

class ChatScreenCon extends StatefulWidget {
  const ChatScreenCon({Key? key}) : super(key: key);

  @override
  _ChatScreenConState createState() => _ChatScreenConState();
}

class _ChatScreenConState extends State<ChatScreenCon>
    with SingleTickerProviderStateMixin {
  String? mpId;
  bool _loading = false;
  bool messageConnected = false;
  List<Map> _indieMessages = [];
  int counter = 0;
  ScrollController _indiecontroller = ScrollController();
  final TextEditingController _messageText = TextEditingController();

  IO.Socket socket =
      IO.io('https://sapa-chatsystem.herokuapp.com/chat', <String, dynamic>{
    'transports': ['websocket'],
    'extraHeaders': {'foo': 'bar'} // optional
  });

  void socketInit() async {
    final _userId = await UserLocalData.userID();
    final Map _da = await MyFunc.checkForMp();
    if (_da != null && _da.isNotEmpty) {
      final _mpID = _da['system_id_for_user'];
      setState(() {
        mpId = _mpID;
      });
      final userId = await UserLocalData.userID();
      socket.on('connect', (data) {
        socket.emit('joined', {"room": _userId + _mpID});
        print("Connected");
      });
      socket.on("status", (data) => print('Connected again'));
      setState(() {
        messageConnected = true;
      });

      socket.on("message", (data) {
        final date = DateTime.now();
        data.putIfAbsent('date', () => date);
        data.putIfAbsent('userId', () => userId);
        setState(() {
          _indieMessages.add(data);
        });
      });
    }
  }

  void setUnreadIndieMessages() async {
    final userId = await UserLocalData.userID();
    try {
      http.Response response = await http.post(Uri.parse(
          base_url + "general/set-unread-messages-to-read/$userId/$mpId/"));
      if (response.statusCode < 206) {
      } else {
        print(response.body);
      }
    } catch (e) {}
  }

  void getIndieMessageds() async {
    List? _data;
    setState(() {
      _loading = true;
    });
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(
        base_url + "constituent-operations/retrieve-messages/$userId/"));

    if (response.statusCode < 206) {
      _data = json.decode(response.body)['messages'];
      for (Map message in _data!) {
        setState(() {
          message.putIfAbsent('userId', () => userId);
          message.putIfAbsent(
              'date', () => DateTime.parse(message['date_sent'].toString()));
          _indieMessages.add(message);
        });
      }
    } else {}
    setState(() {
      _loading = false;
    });
    Timer(
        const Duration(milliseconds: 300),
        () =>
            _indiecontroller.jumpTo(_indiecontroller.position.maxScrollExtent));
  }

  Future<String> emitMessage(user, message) async {
    final a = await UserLocalData.userID();
    socket.emit('text', {"sender": user, "message": message});
    return a;
  }

  SendIndividualMessage(Map user, message) async {
    Map _data = {};

    if (mpId != null) {
      _data = {
        "sender": user['system_id_for_user'],
        "receiver": mpId,
        "message": message
      };
    }
    http.Response response = await http
        .post(Uri.parse(base_url + "chatsystem/send-message/"), body: _data);
    if (response.statusCode < 206) {
    } else {
      MyUtils.snack(context, "message sending failed", 2);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socketInit();
    getIndieMessageds();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageText.dispose();
    _indiecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);

    if (_indiecontroller.hasClients) {
      _indiecontroller.jumpTo(_indiecontroller.position.maxScrollExtent);
    }

    if (mpId != null) {
      setUnreadIndieMessages();
    }

    if (_indieMessages.isNotEmpty && counter < _indieMessages.length) {
      Timer(
          const Duration(milliseconds: 300),
          () => _indiecontroller
              .jumpTo(_indiecontroller.position.maxScrollExtent));
      setState(() {
        counter = _indieMessages.length;
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: !_loading
          ? Column(
              children: [
                Expanded(
                  child: _indieMessages.isNotEmpty
                      ? ListView.builder(
                          controller: _indiecontroller,
                          itemCount: _indieMessages.length,
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 13, left: 13),
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: _indieMessages[index]
                                          ['userId'] !=
                                      _indieMessages[index]['sender']
                                          ['system_id_for_user']
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                        mainAxisAlignment: _indieMessages[index]
                                                    ['userId'] !=
                                                _indieMessages[index]['sender']
                                                    ['system_id_for_user']
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: _indieMessages[index]
                                                            ['userId'] ==
                                                        _indieMessages[index]
                                                                ['sender'][
                                                            'system_id_for_user']
                                                    ? Colors.grey
                                                        .withOpacity(0.3)
                                                    : Colors.blueGrey,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(
                                                        _indieMessages[index][
                                                                    'userId'] ==
                                                                _indieMessages[index]
                                                                        ['sender']
                                                                    ['system_id_for_user']
                                                            ? 0
                                                            : 6),
                                                    topLeft: Radius.circular(
                                                      _indieMessages[index]
                                                                  ['userId'] ==
                                                              _indieMessages[
                                                                          index]
                                                                      ['sender']
                                                                  [
                                                                  'system_id_for_user']
                                                          ? 6
                                                          : 0,
                                                    ),
                                                    bottomLeft: const Radius.circular(6),
                                                    bottomRight: const Radius.circular(6))),
                                            child: Column(
                                                crossAxisAlignment: _indieMessages[
                                                            index]['userId'] ==
                                                        _indieMessages[index]
                                                                ['sender'][
                                                            'system_id_for_user']
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    constraints: BoxConstraints(
                                                        minWidth: 0.0,
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.65),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 6,
                                                            bottom: 4),
                                                    child: Text(
                                                      "${_indieMessages[index]['msg'] ?? _indieMessages[index]['message']}",
                                                      style: TextStyle(
                                                          color: _indieMessages[
                                                                          index]
                                                                      [
                                                                      'userId'] ==
                                                                  _indieMessages[
                                                                              index]
                                                                          [
                                                                          'sender']
                                                                      [
                                                                      'system_id_for_user']
                                                              ? Colors.black
                                                              : Colors.white,
                                                          fontSize: 15),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 5.0,
                                                                bottom: 5,
                                                                left: 5),
                                                        child: Text(
                                                          timeago.format(
                                                                  _indieMessages[
                                                                          index]
                                                                      ['date'],
                                                                  locale:
                                                                      'en_short') +
                                                              (timeago.format(
                                                                          _indieMessages[index]
                                                                              [
                                                                              'date'],
                                                                          locale:
                                                                              'en_short') ==
                                                                      'now'
                                                                  ? ""
                                                                  : " ago"),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: _indieMessages[
                                                                              index]
                                                                          [
                                                                          'userId'] ==
                                                                      _indieMessages[
                                                                              index]['sender']
                                                                          [
                                                                          'system_id_for_user']
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ]),
                                          ),
                                        ]))
                              ],
                            );
                          })
                      : const Center(
                          child: Text(
                            "No Messages",
                            style: bigFont,
                          ),
                        ),
                ),
                Align(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom *
                                  0.006),
                          child: Container(
                            constraints: BoxConstraints(
                                minHeight: 0,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.17),
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: TextField(
                                onTap: () {
                                  Timer(
                                      const Duration(milliseconds: 500),
                                      () => _indiecontroller.jumpTo(
                                          _indiecontroller
                                              .position.maxScrollExtent));
                                },
                                controller: _messageText,
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: "Type message here...",
                                    hintStyle: const TextStyle(fontSize: 14)),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 7.0, left: 7.0, bottom: 5.0),
                        child: InkWell(
                            onTap: () async {
                              await emitMessage(
                                      _pro.userData!, _messageText.text)
                                  .then((value) {
                                Future.delayed(
                                        const Duration(milliseconds: 500))
                                    .then((value) {
                                  setState(() {});
                                });
                              });

                              SendIndividualMessage(
                                  _pro.userData!, _messageText.text);

                              _messageText.clear();
                            },
                            child: const Icon(
                              Icons.send,
                              size: 28,
                            )),
                      )
                    ],
                  ),
                  alignment: Alignment.bottomLeft,
                )
              ],
            )
          : const Center(
              child: MyProgressIndicator(),
            ),
    );
  }
}
