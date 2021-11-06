import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/get_functions.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Map> _forumMessages = [];
  final ScrollController _forumcontroller = ScrollController();
  final TextEditingController _forumText = TextEditingController();
  String? mpId;
  bool messageConnected = false;
  bool _loading = false;
  int counter =0;

  IO.Socket socket =
  IO.io('https://sapa-chatsystem.herokuapp.com/chat', <String, dynamic>{
    'transports': ['websocket'],
    'extraHeaders': {'foo': 'bar'} // optional
  });

  void SendForumMessage(Map user, message) async {
    Map _data = {};

    if (mpId != null) {
      _data = {"sender": user['system_id_for_user'], "message": message};
    }
    http.Response response = await http.post(
        Uri.parse(base_url + "general/send-message-to-forum/"),
        body: _data);
    if (response.statusCode < 206) {} else {
      MyUtils.snack(context, "message sending failed", 2);
    }
  }

  Future<String> emitMessage(user, message)async{
    final a = await UserLocalData.userID();
    socket.emit('msg_form', {"sender": user, "message": message});
    return a;
  }

  void socketInit() async {
    final Map _da = await MyFunc.checkForMp();
    // final List _da = await MyFunc.getProjects();
    if (_da != null && _da.isNotEmpty) {
      final _mpID = _da['system_id_for_user'];
      final const_ = _da['active_constituency']['name'];
      setState(() {
        mpId = _mpID;
      });
      final userId = await UserLocalData.userID();
      socket.on('connect', (data) {
        socket.emit('forumed', {"room": const_});
        print("Connected");
      });
      socket.on("status", (data) => print('Connected again'));
      setState(() {
        messageConnected = true;
      });


      socket.on("forum-message", (data) {
        final date = DateTime.now();
        data.putIfAbsent('date', () => date);
        data.putIfAbsent('userId', () => userId);
        setState(() {
          _forumMessages.add(data);
        });
      });
    }
  }

  void getForumMessageds() async {
    setState(() {
      _loading=true;
    });
    List? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http
        .get(Uri.parse(base_url + "general/retrieve-forum-messages/$userId/"));

    if (response.statusCode < 206) {
      _data = json.decode(response.body)['data'];
      for (Map message in _data!) {
        setState(() {
          message.putIfAbsent('userId', () => userId);
          message.putIfAbsent('date', () => DateTime.parse(message['date_sent'].toString()));
          _forumMessages.add(message);
        });
      }
    } else {}
    setState(() {
      _loading=false;
    });
    Timer(
        const Duration(milliseconds: 300),
            () => _forumcontroller
            .jumpTo(_forumcontroller.position.maxScrollExtent));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socketInit();
    getForumMessageds();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _forumcontroller.dispose();
    _forumText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context);

    if(_forumcontroller.hasClients){
      _forumcontroller.jumpTo(_forumcontroller.position.maxScrollExtent);
    }

    if(_forumMessages.length != 0 && counter < _forumMessages.length){
      Timer(const Duration(milliseconds: 300),
              () => _forumcontroller
              .jumpTo(_forumcontroller.position.maxScrollExtent));
      setState(() {
        counter=_forumMessages.length;
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),),
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: !_loading ? Column(
        children: [

          Expanded(
              child: _forumMessages.isEmpty ? Container(
                child: const Center(child: Text("No Messages", style: bigFont,),),) :
              ListView.builder(
                  padding: const EdgeInsets.only(right: 13, left: 13, top: 10, bottom: 10),
                  controller: _forumcontroller,
                  itemCount: _forumMessages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: _forumMessages[index]['userId'] !=
                          _forumMessages[index]['sender']['system_id_for_user']
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: _forumMessages[index]['userId'] !=
                              _forumMessages[index]['sender']['system_id_for_user']
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            if (_forumMessages[index]['sender']['system_id_for_user'] ==
                                mpId)
                              const Icon(
                                Icons.check_circle,
                                color: appColor,
                                size: 16,
                              ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              "${_forumMessages[index]['sender']['full_name']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Padding(
                            padding:
                            const EdgeInsets.only(bottom: 15, top: 2),
                            child: Row(
                                mainAxisAlignment: _forumMessages[index]['userId'] !=
                                    _forumMessages[index]['sender']
                                    ['system_id_for_user']
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: _forumMessages[index]['userId'] ==
                                            _forumMessages[index]['sender']
                                            ['system_id_for_user']
                                            ? Colors.grey.withOpacity(0.3)
                                            : Colors.blueGrey,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(
                                                _forumMessages[index][
                                                'userId'] ==
                                                    _forumMessages[index]['sender'][
                                                    'system_id_for_user']
                                                    ? 0
                                                    : 6),
                                            topLeft: Radius.circular(
                                              _forumMessages[index]['userId'] ==
                                                  _forumMessages[index]['sender'][
                                                  'system_id_for_user']
                                                  ? 6
                                                  : 0,
                                            ),
                                            bottomLeft:
                                            const Radius.circular(6),
                                            bottomRight:
                                            const Radius.circular(
                                                6))),
                                    child: Column(
                                        crossAxisAlignment: _forumMessages[index][
                                        'userId'] ==
                                            _forumMessages[index]['sender']
                                            ['system_id_for_user']
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                              constraints: BoxConstraints(
                                                  minWidth: 0.0,
                                                  maxWidth: MediaQuery
                                                      .of(
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
                                                "${_forumMessages[index]['msg'] ??
                                                    _forumMessages[index]['message']}",
                                                style: TextStyle(
                                                    color: _forumMessages[index]['userId'] ==
                                                        _forumMessages[index]['sender']
                                                        [
                                                        'system_id_for_user']
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15),
                                                textAlign:
                                                TextAlign.start,
                                              )),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    right: 5.0,
                                                    bottom: 5,
                                                    left: 5),
                                                child: Text(
                                                  timeago.format(
                                                      _forumMessages[index]['date'],
                                                      locale:
                                                      'en_short') +
                                                      (timeago.format(
                                                          _forumMessages[index][
                                                          'date'],
                                                          locale:
                                                          'en_short') ==
                                                          'now'
                                                          ? ""
                                                          : " ago"),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: _forumMessages[index]['userId'] ==
                                                          _forumMessages[index]['sender']
                                                          [
                                                          'system_id_for_user']
                                                          ? Colors.black
                                                          : Colors.white,
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
          ),
          Row(
            children: [
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery
                          .of(context)
                          .viewInsets
                          .bottom * 0.006),
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: 0,
                        maxHeight: MediaQuery
                            .of(context)
                            .size
                            .height * 0.17),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        onTap: (){
                          Timer(
                              const Duration(milliseconds: 500),
                                  () => _forumcontroller
                                  .jumpTo(_forumcontroller.position.maxScrollExtent));
                        },
                        controller: _forumText,
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
                padding: const EdgeInsets.only(right: 7.0, left: 7.0, bottom: 5.0),
                child: InkWell(
                    onTap: () async{
                      await emitMessage(_pro.userData!, _forumText.text).then((value){
                        Timer(
                          const Duration(milliseconds: 300),
                              () =>
                              _forumcontroller.jumpTo(_forumcontroller
                                  .position.maxScrollExtent),
                        );
                      });

                      SendForumMessage(_pro.userData!, _forumText.text);

                      _forumText.clear();
                    },
                    child: const Icon(
                      Icons.send,
                      size: 28,
                    )),
              )
            ],
          ),
        ],
      ): const Center(child: MyProgressIndicator(),),
    );
  }
}
