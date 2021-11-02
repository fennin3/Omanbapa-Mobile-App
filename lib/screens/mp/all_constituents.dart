import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/components/update_const_status.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class AllConstituents extends StatefulWidget {
  const AllConstituents({Key? key}) : super(key: key);

  @override
  _AllConstituentsState createState() => _AllConstituentsState();
}

class _AllConstituentsState extends State<AllConstituents> {
  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  String query= "";
  List _data = [];


  void searchData(){
    final _pro = Provider.of<GeneralData>(context, listen: true);

    setState(() {
      _data = _pro.allConstituents!.where((element) => element['full_name'].toString().toLowerCase().contains(query.toLowerCase()) || element['email'].toString().toLowerCase().contains(query.toLowerCase())).toList();
      _data = _data.reversed.toList();
    });
  }

  void updateConstituentStatus(String status, conId) {
    showModalBottomSheet(
        enableDrag: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return UpdateConstituent(status: status,conId: conId,);
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _pro = Provider.of<GeneralData>(context, listen: false);
    _pro.getAllConstituents();
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
                    hintStyle: TextStyle(fontSize: 13)),
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
            ? Column(
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
                                  base_url2 + con['profile_picture']),
                            ),
                            visualDensity:
                                const VisualDensity(horizontal: 0, vertical: -3),
                            title: Text(
                              "${con['full_name']}",
                              style: bigFont,
                            ),
                            subtitle: Text(
                              "${con['email']}",
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
                            caption: 'Edit',
                            color: Colors.blueGrey,
                            icon: Icons.edit,
                            onTap: () => updateConstituentStatus(con['status'],con['system_id_for_user']),
                          ),
                          IconSlideAction(
                            caption: 'Mail',
                            color: Colors.black45,
                            icon: Icons.mail,
                            onTap: () => _launchURL("mailto:${con['email']}"),
                          ),
                          IconSlideAction(
                            caption: 'Call',
                            color: appColor,
                            icon: Icons.call,
                            onTap: () => _launchURL("tel:${con['contact']}"),
                          ),
                        ],
                      ),
                    )
                ],
              )
            : const Center(
                child: Text("No Constituents"),
              ),
      ),
    );
  }
}
