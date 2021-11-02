import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:omanbapa/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/get_functions.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/screens/components/actionplan_const.dart';
import 'package:omanbapa/screens/components/homescreen.dart';
import 'package:omanbapa/screens/components/mydrawer.dart';
import 'package:omanbapa/screens/components/sec_registration.dart';
import 'package:omanbapa/screens/components/switch_const.dart';
import 'package:omanbapa/screens/general/profile.dart';
import 'package:omanbapa/screens/mp/chat_mp.dart';
import 'package:omanbapa/screens/mp/post.dart';
import 'package:omanbapa/screens/mp/project.dart';
import 'package:omanbapa/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  int _selectedIndex = 0;
  bool ac_on = false;
  bool ass_on = false;
  bool forum_on = false;
  List availableConts = [];
  List<Map> _indieMessages = [];
  List<Map> _forumMessages = [];
  List _mpMessages=[];
  List _chatMessages = [];
  int unreadMessages = 0;
  int unreadIncident = 0;
  int unreadRequest = 0;
  String? mpId;
  bool messageConnected = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  final TextEditingController _messageText = TextEditingController();
  final TextEditingController _forumText = TextEditingController();
  ScrollController _indiecontroller = ScrollController();
  ScrollController _forumcontroller = ScrollController();
  TabController? _tabController;


  IO.Socket socket =
  IO.io('https://sapa-chatsystem.herokuapp.com/chat', <String, dynamic>{
    'transports': ['websocket'],
    'extraHeaders': {'foo': 'bar'} // optional
  });

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

      socket.on("message", (data) {
        final date = DateTime.now();
        data.putIfAbsent('date', () => date);
        data.putIfAbsent('userId', () => userId);
        setState(() {
          _indieMessages.add(data);
        });
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

  void _onRefresh() async {
    setState(() {
      setInitData();
    });
    _refreshController.refreshCompleted();
  }

  void secRegitration() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            Dialog(
                child: SecRegistration(
                  data: availableConts,
                )));
  }

  void switchConst() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Dialog(child: SwitchConst()));
  }

  void getAvailableConst() async {
    final userId = await UserLocalData.userID();

    http.Response response = await http.get(Uri.parse(
        base_url + "constituent-operations/retrieve-con-available/$userId/"));

    if (response.statusCode < 206) {
      setState(() {
        availableConts = json.decode(response.body)['data'];
      });
    } else {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setUnreadIndieMessages() async {
    final userId = await UserLocalData.userID();
    try {
      http.Response response = await http.post(Uri.parse(
          base_url + "general/set-unread-messages-to-read/$userId/$mpId/"));
      if (response.statusCode < 206) {}
      else {
        print(response.body);
      }
    } catch (e) {}
  }

  void getUnreads() async {
    final userId = await UserLocalData.userID();

    http.Response response = await http.get(
        Uri.parse(base_url + "general/unread-info/$userId/"));
    if (response.statusCode < 206) {
      Map _data = json.decode(response.body);
      setState(() {
        unreadMessages = _data['messages'];
        unreadIncident = _data['incident_reports'];
        unreadRequest = _data['request_forms'];
      });
    }
    else {}
  }

  void setInitData() {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    _pro.getUserData();
    _pro.getProjects();
    _pro.getAllConstituents();
    _pro.getrequestNotification();
    _pro.getAllUsers();
    getAvailableConst();
    getACStatus();
    getASStatus();
    getForumtatus();
    getUnreads();
  }

  void getACStatus() async {
    http.Response response =
    await http.get(Uri.parse(base_url + "general/get-actionplan-status/"));
    if (response.statusCode < 206) {
      setState(() {
        ac_on = json.decode(response.body)['action_plan_status'];
      });
    } else {}
  }

  void getASStatus() async {
    http.Response response =
    await http.get(Uri.parse(base_url + "general/get-assessment-status/"));
    if (response.statusCode < 206) {
      setState(() {
        ass_on = json.decode(response.body)['assessment_status'];
      });
    } else {}
  }

  void getForumtatus() async {
    http.Response response =
    await http.get(Uri.parse(base_url + "general/get-forum-status/"));
    if (response.statusCode < 206) {
      setState(() {
        forum_on = json.decode(response.body)['forum_status'];
      });
    } else {}
  }

  void SendIndividualMessage(Map user, message) async {
    socket.emit('text', {"sender": user, "message": message});
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
    if (response.statusCode < 206) {} else {
      MyUtils.snack(context, "message sending failed", 2);
    }
  }

  void SendForumMessage(Map user, message) async {
    socket.emit('msg_form', {"sender": user, "message": message});
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

  void getForumMessageds() async {
    List? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http
        .get(Uri.parse(base_url + "general/retrieve-forum-messages/$userId/"));

    if (response.statusCode < 206) {
      _data = json.decode(response.body)['data'];
      for (Map message in _data!) {
        final date = DateTime.now();
        setState(() {
          message.putIfAbsent('userId', () => userId);
          message.putIfAbsent('date', () => date);
          _forumMessages.add(message);
        });
      }
    } else {}
  }


  void getMpMessages() async {
    List? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http
        .get(Uri.parse(base_url + "mp-operations/mp-request-notifications/$userId/"));

    if (response.statusCode < 206) {
      final List _data = json.decode(response.body)['messages'];
      setState(() {
        _mpMessages=_data;
      });
    } else {
      print(response.body);
    }
  }

  void getIndieMessageds() async {
    List? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(
        base_url + "constituent-operations/retrieve-messages/$userId/"));

    if (response.statusCode < 206) {
      _data = json.decode(response.body)['messages'];
      for (Map message in _data!) {
        final date = DateTime.now();
        setState(() {
          message.putIfAbsent('userId', () => userId);
          message.putIfAbsent('date', () => date);
          _indieMessages.add(message);
        });
      }
    } else {}
  }

  void selectPostOrProject() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(appColor)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const CreateProject()))
                                .then((value) => _onRefresh());
                          },
                          child:  Text(
                            "Create Project",
                            style: bigFont.copyWith(color: Colors.white),
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(appColor)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreatePost()))
                                .then((value) => _onRefresh());
                          },
                          child:  Text(
                            "Create Post",
                            style: bigFont.copyWith(color: Colors.white),
                          )),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitData();
    socketInit();
    getForumMessageds();
    getIndieMessageds();
    _tabController = TabController(length: 2, vsync: this);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageText.dispose();
    _forumText.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getMpMessages();
    final _pro = Provider.of<GeneralData>(context, listen: true);
    if (_pro.userData != null && !_pro.userData!['is_mp']) {
      if (_selectedIndex == 1) {
        setUnreadIndieMessages();
      }
    }


    if (_selectedIndex == 1 && !_pro.userData!['is_mp']) {
      Future.delayed(const Duration(milliseconds: 50)).then((value) =>
          _indiecontroller.jumpTo(_indiecontroller.position.maxScrollExtent));
    }

    if (_selectedIndex == 2) {
      Future.delayed(const Duration(milliseconds: 50)).then((value) =>
          _forumcontroller.jumpTo(_forumcontroller.position.maxScrollExtent));
    }

    final _screen = [
      HomeScreen(pro: _pro),
      if (_pro.userData != null)
        _pro.userData!['is_constituent']
            ? _indieMessages.isNotEmpty ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                  reverse: false,
                  controller: _indiecontroller,
                  itemCount: _indieMessages.length,
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 10, left: 10),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: _indieMessages[index]['userId'] !=
                          _indieMessages[index]['sender']['system_id_for_user']
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Padding(
                            padding:
                            const EdgeInsets.only(bottom: 15),
                            child: Row(
                                mainAxisAlignment: _indieMessages[index][
                                'userId'] !=
                                    _indieMessages[index]['sender']
                                    ['system_id_for_user']
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: _indieMessages[index]['userId'] ==
                                            _indieMessages[index]['sender'][
                                            'system_id_for_user']
                                            ? Colors.grey
                                            .withOpacity(0.2)
                                            : Colors.blueGrey,
                                        borderRadius:
                                        BorderRadius.only(
                                            topRight: Radius.circular(
                                                _indieMessages[index]['userId'] ==
                                                    _indieMessages[index]['sender']
                                                    [
                                                    'system_id_for_user']
                                                    ? 0
                                                    : 6),
                                            topLeft: Radius
                                                .circular(
                                              _indieMessages[index]['userId'] ==
                                                  _indieMessages[index]['sender']
                                                  [
                                                  'system_id_for_user']
                                                  ? 6
                                                  : 0,
                                            ),
                                            bottomLeft:
                                            const Radius.circular(
                                                6),
                                            bottomRight:
                                            const Radius.circular(6))),
                                    child: Column(
                                        crossAxisAlignment: _indieMessages[index][
                                        'userId'] ==
                                            _indieMessages[index]['sender'][
                                            'system_id_for_user']
                                            ? CrossAxisAlignment
                                            .end
                                            : CrossAxisAlignment
                                            .end,
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
                                            const EdgeInsets
                                                .only(
                                                left: 10,
                                                right: 10,
                                                top: 6,
                                                bottom: 4),
                                            child: Text(
                                              "${_indieMessages[index]['msg'] ??
                                                  _indieMessages[index]['message']}",
                                              style: TextStyle(
                                                  color: _indieMessages[index]['userId'] ==
                                                      _indieMessages[index]['sender']
                                                      [
                                                      'system_id_for_user']
                                                      ? Colors
                                                      .black
                                                      : Colors
                                                      .white,
                                                  fontSize: 15),
                                              textAlign:
                                              TextAlign.start,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .end,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .only(
                                                    right:
                                                    5.0,
                                                    bottom: 5,
                                                    left: 5),
                                                child: Text(
                                                  timeago.format(
                                                      _indieMessages[index][
                                                      'date'],
                                                      locale:
                                                      'en_short') +
                                                      (timeago.format(
                                                          _indieMessages[index]['date'],
                                                          locale: 'en_short') ==
                                                          'now'
                                                          ? ""
                                                          : " ago"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      12,
                                                      color: _indieMessages[index]['userId'] ==
                                                          _indieMessages[index]['sender'][
                                                          'system_id_for_user']
                                                          ? Colors
                                                          .black
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
                  }),
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
                          bottom: MediaQuery
                              .of(context)
                              .viewInsets
                              .bottom *
                              0.006),
                      child: Container(
                        constraints: BoxConstraints(
                            minHeight: 0,
                            maxHeight:
                            MediaQuery
                                .of(context)
                                .size
                                .height * 0.17),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
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
                    padding:
                    const EdgeInsets.only(right: 7.0, left: 7.0, bottom: 5.0),
                    child: InkWell(
                        onTap: () {
                          Timer(
                            const Duration(milliseconds: 300),
                                () =>
                                _indiecontroller.jumpTo(_indiecontroller
                                    .position.maxScrollExtent),
                          );
                          // SendIndividualMessage(
                          //     _pro.userData!, _messageText.text);
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
        ) : const Center(
          child: Text(
            "No Messages",
            style: bigFont,
          ),
        )
            :
        // MP chat starting

        Column(
          children: [
            TabBar(
              unselectedLabelColor: Colors.black,
              labelColor: appColor,
              labelStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
              isScrollable: false,
              tabs: const [

                Tab(
                  text: 'Messages',
                ),
                Tab(
                  text: 'All Constituents',
                ),
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: _mpMessages.isEmpty? const Center(child:  Text("No Messages", style: bigFont,),):
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20,),
                        for (var message in _mpMessages.reversed.toList())
                          ListTile(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatMP(
                                            conId: message['sender']['system_id_for_user'],
                                            con: message['sender'],
                                          )));
                              },
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(base_url2 +
                                  message['sender']['profile_picture']),
                            ),
                            visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                            title: Text(
                              "${message['sender']['full_name']}",
                              style: bigFont,
                            ),
                            subtitle: Text("${message['message']} yuyyuyvv   h h vb ghv hg gf g jn gj yugy gvgg gh ", overflow: TextOverflow.ellipsis, style: mediumFont,),
                            trailing:message['read']
                                ?  Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                    Icon(
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
                                color: Colors.grey,
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
                          )

                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        if (_pro.allConstituents != null &&
                            _pro.allConstituents!.isNotEmpty)
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
                                                  conId: con['system_id_for_user'],
                                                  con: con,
                                                ))),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
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
                        else
                          const Center(
                            child: Text("No constituents"),
                          )
                      ],
                    ),
                  ),
                )
            ],

            ))
          ],
        )
      else
        Container(),

      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          Expanded(
              child: _forumMessages.isEmpty ? Container(
                child: const Center(child: Text("No Messages", style: bigFont,),),) :
              ListView.builder(
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
                                size: 20,
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
                                            ? Colors.grey.withOpacity(0.2)
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
                    onTap: () {
                      Timer(
                        const Duration(milliseconds: 300),
                            () =>
                                _forumcontroller.jumpTo(_forumcontroller
                                .position.maxScrollExtent),
                      );
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
      ),
      const Profile(),
    ];
    return _pro.userData == null || _pro.projects == null
        ? const Scaffold(
      body: Center(
        child: MyProgressIndicator(),
      ),
    )
        : Stack(
      children: [
        Scaffold(
          key: _key,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Omanbapa",
              style:
              GoogleFonts.lobster(color: Colors.white, fontSize: 30),
            ),
            actions: [
              availableConts.length < 2 || _pro.userData!['is_mp']
                  ? Container()
                  : _pro.userData!['constituency'].length < 2
                  ? IconButton(
                  onPressed: () {
                    secRegitration();
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ))
                  : IconButton(
                  onPressed: () {
                    switchConst();
                  },
                  icon: const Icon(
                    Icons.change_circle,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () => _key.currentState!.openDrawer(),
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ))
            ],
          ),
          drawer: MyDrawer(
            assessment: ass_on, ir: unreadIncident, rf: unreadRequest,),
          body: SmartRefresher(
            enablePullDown: true,
            header: const WaterDropMaterialHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SafeArea(child: _screen[_selectedIndex]),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                tooltip: "Home",
                icon: Icon(Icons.home),
                label: 'Home',
              ),

              BottomNavigationBarItem(
                tooltip: "Chat",
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat),
                    if(_pro.userData!['is_mp'] && unreadMessages > 0)
                      Positioned(
                          right: -10,
                          top: -10,
                          child: Card(
                            color: Colors.teal,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text("$unreadMessages",
                                style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),),
                            ),
                          ))
                  ],
                ),
                label: 'Chat',
              ),
              if(forum_on)

                const BottomNavigationBarItem(
                  tooltip: "Forum",
                  icon: Icon(Icons.forum),
                  label: ' Forum',
                ),
              const BottomNavigationBarItem(
                tooltip: "Profile",
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: appColor,
            selectedFontSize: 15.0,
            unselectedItemColor: Colors.black54,
            showUnselectedLabels: true,
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            unselectedIconTheme: const IconThemeData(size: 22),
            onTap: _onItemTapped,
          ),
          floatingActionButton:
          _pro.userData!['is_mp'] && _selectedIndex == 0
              ? FloatingActionButton(
            onPressed: () {
              selectPostOrProject();
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
              : Container(),
        ),
        if (!_pro.userData!['is_mp'] && ac_on)
          Positioned(
            right: 0,
            top: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(appColor)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ActionPlanCon()));
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                ),
              ),
            ),
          )
      ],
    );
  }
}













