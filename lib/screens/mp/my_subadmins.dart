import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class MySubAdmins extends StatefulWidget {
  const MySubAdmins({Key? key}) : super(key: key);

  @override
  _MySubAdminsState createState() => _MySubAdminsState();
}

class _MySubAdminsState extends State<MySubAdmins> {
  String query= "";
  List _data = [];
  List _data1 = [];
  bool showSpin =false;
  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  void searchData(){

    setState(() {
      _data=_data1;
      _data = _data.where((element) => element['user']['full_name'].toString().toLowerCase().contains(query.toLowerCase()) || element['user']['email'].toString().toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void getSubadmins()async{
    final userId = await UserLocalData.userID();

    http.Response response = await http.post(Uri.parse(base_url + "mp-operations/retrieve-all-subadmins/$userId/"));

    if(response.statusCode < 206){
      setState(() {
        _data1 = json.decode(response.body)['data'];
      });
    }
    else{}
  }

  void unmakeSubadmin(String constid)async{
    Navigator.pop(context);
    setState(() {
      showSpin =true;
    });
    final userId = await UserLocalData.userID();

    http.Response response = await http.post(Uri.parse(base_url + "mp-operations/mp-unmake-subadmin/$userId/$constid/"));
    if(response.statusCode < 206){
      setState(() {
        showSpin =false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
    else{
      setState(() {
        showSpin =false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
    getSubadmins();
  }

  void showDial(constId){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Removing a subadmin'),
        content: const Text('Do you want to proceed with this operation'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => unmakeSubadmin(constId),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubadmins();
  }

  @override
  Widget build(BuildContext context) {
    searchData();
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
        title: Container(
            height: 35,
            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 5),

            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextFormField(
                style: mediumFont,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "search here ...",
                    hintStyle: smallFont),
                onChanged: (e){
                  setState(() {
                    query=e;
                  });
                },
              ),
            )),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
        child: _data.isNotEmpty
            ? ModalProgressHUD(
          inAsyncCall: showSpin,
              child: Column(
          children: [
              for (var con in _data)
                Padding(
                  padding: const EdgeInsets.
                  only(bottom: 5.0),
                  child: Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: () {
                          //Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //               builder: (context) => IRDetail(
                          //                   data: _pro.requestnotifications![
                          //                   'incident_reports'][index])))
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              base_url2 + con['user']['profile_picture']),
                        ),
                        visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -3),
                        title: Text(
                          "${con['user']['full_name']}",
                          style: bigFont,
                        ),
                        subtitle: Text(
                          "${con['user']['email']}",
                          style: mediumFont,
                        ),
                        trailing: const Text(
                          "slide <<<",
                          style: smallFont,
                        ),
                      ),
                    ),
                    // actions: <Widget>[
                    //   IconSlideAction(
                    //     caption: 'Archive',
                    //     color: Colors.blue,
                    //     icon: Icons.archive,
                    //     onTap: () => _showSnackBar('Archive'),
                    //   ),
                    //   IconSlideAction(
                    //     caption: 'Share',
                    //     color: Colors.indigo,
                    //     icon: Icons.share,
                    //     onTap: () => _showSnackBar('Share'),
                    //   ),
                    // ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Remove',
                        color: Colors.red,
                        icon: Icons.clear,
                        onTap: () => showDial(con['user']['system_id_for_user']),
                      ),
                      IconSlideAction(
                        caption: 'Mail',
                        color: Colors.black45,
                        icon: Icons.mail,
                        onTap: () => _launchURL("mailto:${con['user']['email']}"),
                      ),
                      IconSlideAction(
                        caption: 'Call',
                        color: appColor,
                        icon: Icons.call,
                        onTap: () => _launchURL("tel:${con['user']['contact']}"),
                      ),
                    ],
                  ),
                )
          ],
        ),
            )
            : const Center(
          child: Text("No subadmin"),
        ),
      ),
    );
  }
}
