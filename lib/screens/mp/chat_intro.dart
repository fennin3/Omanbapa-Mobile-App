import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/screens/mp/chat_mp.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

class ChatIntroMP extends StatefulWidget {
  final Map mp;
  ChatIntroMP({required this.mp});

  @override
  _ChatIntroMPState createState() => _ChatIntroMPState();
}

class _ChatIntroMPState extends State<ChatIntroMP> {
  List? _mpMessages;
  bool _loading = false;


  void getMpMessages() async {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    List? _data;
    String userId ="";
    if(_pro.userData!['is_mp']){
      userId = await UserLocalData.userID();
    }else{
      userId = widget.mp['system_id_for_user'];
    }

    http.Response response = await http
        .get(Uri.parse(base_url + "mp-operations/mp-request-notifications/$userId/"));

    if (response.statusCode < 206) {
      final List _data = json.decode(response.body)['messages'];
      if(mounted){
        setState(() {
          _mpMessages=_data;
        });
      }
    } else {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMpMessages();
  }

  @override
  Widget build(BuildContext context) {
    getMpMessages();
    final _pro = Provider.of<GeneralData>(context);
    return  DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),),
          title: const Text(
            "Chat",
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            unselectedLabelColor: Colors.black,
            labelColor: appColor,
            labelStyle:  TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
            isScrollable: false,
            tabs:  [

              Tab(
                text: 'Messages',
              ),
              Tab(
                text: 'All Constituents',
              ),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: _mpMessages == null ? const SafeArea(child: Center(child: MyProgressIndicator(),)):  SafeArea(child:  TabBarView(
          children: [
            Container(
              child: _mpMessages!.isEmpty? const Center(child:  Text("No Messages", style: bigFont,),):
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    for (var message in _mpMessages!.reversed.toList())
                      ListTile(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChatMP(
                                        mp: widget.mp,
                                        conId: message['sender']['system_id_for_user'],
                                        con: message['sender'],
                                      )));
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(base_url2 +
                              message['sender']['profile_picture']),
                        ),
                        visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -2),
                        title: Text(
                          "${message['sender']['full_name']}",
                          style: bigFont,
                        ),
                        subtitle: Text("${message['message']}", overflow: TextOverflow.ellipsis, style: mediumFont,),
                        trailing:message['read']
                            ?  Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                           const  Icon(
                              Icons.done_all,
                              color: Colors.blue,
                              size: 13,
                            ),
                            Text(
                              timeago.format(
                                  DateTime.parse(message['date_sent']),
                                  locale: 'en_short') +
                                  (timeago.format(
                                      DateTime.parse(message['date_sent']),
                                      locale: 'en_short') ==
                                      'now'
                                      ? ""
                                      : " ago"),
                              style: smallFont.copyWith(fontSize: 11),
                            )
                          ],)
                            :  Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              elevation: 5,
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                    "unread",
                                    style: smallFont.copyWith(color: Colors.white, fontSize: 12)
                                ),
                              ),
                            ),
                            Text(
                              timeago.format(
                                  DateTime.parse(message['date_sent']),
                                  locale: 'en_short') +
                                  (timeago.format(
                                      DateTime.parse(message['date_sent']),
                                      locale: 'en_short') ==
                                      'now'
                                      ? ""
                                      : " ago"),
                              style: smallFont.copyWith(fontSize: 10),
                            )
                          ],),
                      ),
                    const SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
            if (_pro.allConstituents != null &&
                _pro.allConstituents!.isNotEmpty) SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),

                    for (var con in _pro.allConstituents!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () =>
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatMP(
                                            mp: widget.mp,
                                            conId: con['system_id_for_user'],
                                            con: con,
                                          ))),
                          child: Row(
                            children: [
                               CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(base_url2 +
                                    con['profile_picture']),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${con['full_name']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "${con['email']}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )

                  ],
                ),
              ),
            )
            else
              const Center(
                child: Text("No constituents", style: bigFont,),
              )
          ],

        )

        ),

      ),
    );
  }
}



