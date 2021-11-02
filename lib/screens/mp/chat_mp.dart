import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class ChatMP extends StatefulWidget {
  final String conId;
  final Map con;

  ChatMP({required this.conId, required this.con});

  @override
  _ChatMPState createState() => _ChatMPState();
}

class _ChatMPState extends State<ChatMP> {
  List? _indieMessages;
  final TextEditingController _messageText = TextEditingController();
  bool _loading =false;
  ScrollController _indiecontroller = ScrollController();

  IO.Socket socket =
  IO.io('https://sapa-chatsystem.herokuapp.com/chat', <String, dynamic>{
    'transports': ['websocket'],
    'extraHeaders': {'foo': 'bar'} // optional
  });

  void setUnreadIndieMessages()async{
    final userId = await UserLocalData.userID();
    try{
      http.Response response = await http.post(Uri.parse(base_url + "general/set-unread-messages-to-read/$userId/${widget.conId}/"));
      if(response.statusCode < 206){}
      else{print(response.body);}
    }catch(e){}
  }

  void getMessages()async{
    setState(() {
      _loading=true;
      _indieMessages=[];
    });

    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/retrieve-messages/$userId/${widget.conId}/"));
    if(response.statusCode <206){
      setState(() {
        _loading=false;
      });
      for(var message in json.decode(response.body)['messages']) {
        final date = DateTime.now();
        setState((){
          message.putIfAbsent('userId', () => userId);
          message.putIfAbsent('date', () => date);
        _indieMessages!.add(message);
      });
      }
    }
    else{
      setState(() {
        _loading=false;
      });
    }
  }


  void socketInit() async {

      final userId = await UserLocalData.userID();
      socket.on('connect', (data) {
        socket.emit('joined', {"room": widget.conId + '' + userId});

        print("Connected ---");
      });
      socket.on("status", (data) => print('Connected again ----'));


      socket.on("message", (data) {
        final date = DateTime.now();
        data.putIfAbsent('date', () => date);
        data.putIfAbsent('userId', () => userId);
        setState(() {
          _indieMessages!.add(data);
        });
      });

      // socket.on("forum-message", (data) {
      //   final date = DateTime.now();
      //   data.putIfAbsent('date', () => date);
      //   data.putIfAbsent('userId', () => userId);
      //   setState(() {
      //     _forumMessages.add(data);
      //   });
      // });

  }

  void SendIndividualMessage(sender, message)async{
    socket.emit('text', {"sender":sender, "message":message});

    final Map  _data = {
        "sender":sender['system_id_for_user'],
        "receiver":widget.conId,
        "message":message
    };

    http.Response response =await http.post(Uri.parse(base_url +"chatsystem/send-message/"), body: _data);
    if(response.statusCode< 206){

    }
    else{
      MyUtils.snack(context, "message saving failed", 2);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessages();
    socketInit();
    setUnreadIndieMessages();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageText.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context,listen: true);

    if (_indieMessages!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 50)).then((value) =>
          _indiecontroller.jumpTo(_indiecontroller.position.maxScrollExtent));
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title:  Text(
          "${widget.con['full_name']}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: !_loading ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _indiecontroller,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        if(_indieMessages!.isNotEmpty)
                          for (var data in _indieMessages!)
                            Column(
                              crossAxisAlignment:
                              data['userId'] != data['sender']['system_id_for_user']
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                        mainAxisAlignment: data['userId'] !=
                                            data['sender']['system_id_for_user']
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: data['userId'] == data['sender']['system_id_for_user']
                                                    ? Colors.grey.withOpacity(0.2)
                                                    : Colors.blueGrey,
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(
                                                        data['userId'] == data['sender']['system_id_for_user']
                                                            ? 0
                                                            : 6),
                                                    topLeft: Radius.circular(
                                                      data['userId'] == data['sender']['system_id_for_user']
                                                          ? 6
                                                          : 0,
                                                    ),
                                                    bottomLeft: const Radius.circular(6),
                                                    bottomRight: const Radius.circular(6))),
                                            child: Column(
                                                crossAxisAlignment:data['userId'] == data['sender']['system_id_for_user']? CrossAxisAlignment.end:CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    constraints: BoxConstraints(
                                                        minWidth: 0.0,
                                                        maxWidth: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            0.65),
                                                    padding: const EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        top: 6,
                                                        bottom: 4),
                                                    child:Text(
                                                      "${data['msg']??data['message']}",
                                                      style: TextStyle(
                                                          color: data['userId'] ==
                                                              data['sender']['system_id_for_user']
                                                              ? Colors.black
                                                              : Colors.white,
                                                          fontSize: 15),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            right: 5.0, bottom: 5, left: 5),
                                                        child: Text(
                                                          timeago.format(data['date'],
                                                              locale: 'en_short') +
                                                              (timeago.format(data['date'],
                                                                  locale:
                                                                  'en_short') ==
                                                                  'now'
                                                                  ? ""
                                                                  : " ago"),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: data['userId'] ==
                                                                  data['sender'][
                                                                  'system_id_for_user']
                                                                  ? Colors.black
                                                                  : Colors.white,
                                                              fontWeight: FontWeight.w600),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ]),
                                          ),
                                        ]))
                              ],
                            )
                        else
                          const Center(child: Text("No Messages", style: TextStyle(fontSize: 16),),)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                children: [
                  const  SizedBox(width: 7,),
                  Expanded(
                    child:  Padding(
                      padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 0.006),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 0, maxHeight: MediaQuery.of(context).size.height* 0.17),
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: _messageText,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "Type message here...",
                                hintStyle: const TextStyle(fontSize: 14)
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  const EdgeInsets.only(right: 7.0, left: 7.0, bottom: 5.0),
                    child: InkWell(
                        onTap: (){
                          Future.delayed(const Duration(milliseconds: 300)).then((value) =>
                              _indiecontroller.jumpTo(_indiecontroller.position.maxScrollExtent));
                          SendIndividualMessage(_pro.userData,_messageText.text);
                          _messageText.clear();
                        },
                        child: const Icon(Icons.send, size: 28,)),
                  )
                ],
              ),
            ),

          ],
        ): const Center(child: MyProgressIndicator(),),
      ),
    );
  }
}
