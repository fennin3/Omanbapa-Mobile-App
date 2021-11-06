import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'package:omanbapa/screens/constituent/chat.dart';
import 'package:omanbapa/screens/general/forum.dart';
import 'package:omanbapa/screens/general/profile.dart';
import 'package:omanbapa/screens/mp/chat_intro.dart';
import 'package:omanbapa/screens/mp/post.dart';
import 'package:omanbapa/screens/mp/project.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool ac_on = false;
  bool ass_on = false;
  bool forum_on = false;
  bool notice = true;
  bool assnotice = true;
  List availableConts = [];
  int unreadMessages = 0;
  int unreadIncident = 0;
  int unreadRequest = 0;
  Map mpId ={};
  bool messageConnected = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);


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
        builder: (_) => Dialog(
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

  void getUnreads() async {
    final userId = await UserLocalData.userID();

    http.Response response =
        await http.get(Uri.parse(base_url + "general/unread-info/$userId/"));
    if (response.statusCode < 206) {
      Map _data = json.decode(response.body);
      setState(() {
        unreadMessages = _data['messages'];
        unreadIncident = _data['incident_reports'];
        unreadRequest = _data['request_forms'];
      });
    } else {}
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
    getNottatus();
    getAssNottatus();
    getForumtatus();
    getUnreads();
    getMPData();
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

  void getNottatus() async {
    http.Response response =
        await http.get(Uri.parse(base_url + "general/get-notice-status/"));
    if (response.statusCode < 206) {
      setState(() {
        notice = json.decode(response.body)['show_notice'];
      });
    } else {}
  }

  void getAssNottatus() async {
    http.Response response =
        await http.get(Uri.parse(base_url + "general/get-as-notice-status/"));
    if (response.statusCode < 206) {
      setState(() {
        assnotice = json.decode(response.body)['show_notice'];
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
                          child: Text(
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
                                        builder: (context) => const CreatePost()))
                                .then((value) => _onRefresh());
                          },
                          child: Text(
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

  void getMPData()async{
    final _data = await MyFunc.checkForMp();
    if (_data != null && _data.isNotEmpty) {
      final _mpID = _data;
      setState(() {
        mpId = _mpID;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getUnreads();
    final _pro = Provider.of<GeneralData>(context, listen: true);
    final _screen = [
      HomeScreen(pro: _pro),
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
                  notice: assnotice,
                  assessment: ass_on,
                  ir: unreadIncident,
                  rf: unreadRequest,
                ),
                body: SmartRefresher(
                  enablePullDown: true,
                  header: const WaterDropMaterialHeader(),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: SafeArea(child: _screen[_selectedIndex]),
                ),
                bottomNavigationBar: Container(
                  width: double.infinity,
                  height: 55,
                  child: Row(
                    mainAxisAlignment: forum_on
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: forum_on ? 20.0 : 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.home, size: 30, color: appColor),
                            Text(
                              "Home",
                              style: mediumFont.copyWith(color: appColor),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          print(_pro.userData!['subadmin_for']);
                          if (_pro.userData!['is_constituent'] && _pro.userData!['active_constituency']['id'] != _pro.userData!['subadmin_for']) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatScreenCon()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatIntroMP(mp: mpId,)));
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Icon(
                                  Icons.message,
                                  size: 25,
                                  color: Colors.black54,
                                ),
                                Text("Chat")
                              ],
                            ),
                            if (unreadMessages > 0)
                              Positioned(
                                right: -7,
                                top: -7,
                                child: Card(
                                  color: appColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 4),
                                    child: Text(
                                      unreadMessages.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      if (forum_on)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ForumPage()));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.forum_outlined,
                                  size: 25, color: Colors.black54),
                              Text("Forum")
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(right: forum_on ? 20.0 : 0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Profile()));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.person,
                                  size: 25, color: Colors.black54),
                              Text("Profile")
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  color: Colors.grey.withOpacity(0.1),
                ),
                floatingActionButton: _pro.userData!['is_mp'] ||
                        (_pro.userData!['is_subadmin'] &&
                            _pro.userData!['active_constituency']['id'] ==
                                _pro.userData!['subadmin_for'])
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
              if (!_pro.userData!['is_mp'] && ac_on && _selectedIndex == 0)
                Positioned(
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(appColor)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ActionPlanCon(
                                    notice: notice,
                                  )));
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
