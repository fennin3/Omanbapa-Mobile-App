import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/screens/components/share_one_ap.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';


class ActionPlanArea extends StatefulWidget {
  const ActionPlanArea({Key? key}) : super(key: key);

  @override
  _ActionPlanAreaState createState() => _ActionPlanAreaState();
}

class _ActionPlanAreaState extends State<ActionPlanArea> {
  List? years;
  String? currentYear=DateTime.now().year.toString();
  List _actionPlans = [];
  bool showSpin =false;


  void retrieveYears()async{
    http.Response response = await http.get(Uri.parse(base_url + "constituent-operations/retrieve-years/"));

    if(response.statusCode < 206){
      setState(() {
        years = json.decode(response.body)['years'];
        if(years!.isEmpty){
          years!.add(DateTime.now().year.toString());
        }
      });
    }else{

    }
  }


  void retrieveActionPlan(String year)async{
    final userId = await UserLocalData.userID();

    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/retrieve-action-plans-summary/$userId/$year/"));

    if(response.statusCode < 206){
      setState(() {
        _actionPlans = json.decode(response.body)['data'];
      });
    }else{

    }
    print(_actionPlans);
  }

  void retrieveActionPlan2(String year)async{
    setState(() {
      showSpin=true;
    });
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/retrieve-action-plans-summary/$userId/$year/"));

    if(response.statusCode < 206){
      setState(() {
        _actionPlans = json.decode(response.body)['data'];
      });
    }else{

    }

    setState(() {
      showSpin=false;
    });
  }


  void shareOneAP(String image, area) {
    showModalBottomSheet(
      enableDrag: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return ShareOneAP(image: image, area: area,);
        });
  }

  void shareAllAP() async {
    setState(() {
      showSpin = true;
    });
    final _pro = Provider.of<GeneralData>(context, listen: false);
    final userId = await UserLocalData.userID();

    http.Response response = await http.post(
        Uri.parse(base_url + "mp-operations/share-all-action-plan/$userId/$currentYear/"));

    if (response.statusCode < 206) {
      setState(() {
        showSpin = false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    } else {
      setState(() {
        showSpin = false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
    _pro.getProjects();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveYears();
    retrieveActionPlan(currentYear!);
  }
  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Action Plan - Area",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: years == null ? const Center(child:  MyProgressIndicator(),):

      ModalProgressHUD(
        inAsyncCall: showSpin,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Tooltip(
                        message: "Share all records as posts",
                        child: InkWell(
                          onTap: (){
                            shareAllAP();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration:  BoxDecoration(color: appColor, borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              children: const [
                                 Text("Share all", style: TextStyle(color: Colors.white),),
                                SizedBox(width: 3,),
                                Icon(Icons.reply, color: Colors.white,)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 45,
                        child: DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          selectedItem: currentYear,
                          items:  [
                            for(var year in years!)
                              year.toString()
                          ],
                          label: "Year",
                          hint: "Year",
                          onChanged: (e) {
                            setState(() {
                              currentYear=e;
                            });
                            retrieveActionPlan2(currentYear!);
                          },
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 15,),
                  if(_actionPlans.isEmpty)
                    const Padding(
                      padding:  EdgeInsets.only(top: 100.0),
                      child:  Center(
                        child: Text("No Data"),
                      ),
                    )
                  else
                    for(var ac in _actionPlans)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 300,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(image: NetworkImage(base_url2 + ac['image']), fit: BoxFit.cover)
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  left: 5,
                                  child: Text(ac['area']['name'], style: TextStyle(fontWeight: FontWeight.w600),),
                                ),
                                  Positioned(
                                  top: 2,
                                  right: 0,
                                  child: Tooltip(
                                    message: "Share as post",
                                    child:  InkWell(
                                      onTap: ()=>shareOneAP(base_url2+ac['image'],ac['area']['name']),
                                      child: const Card(
                                          color: Colors.blueGrey,
                                          child: Padding(
                                        padding: EdgeInsets.all(3.0),
                                        child: Icon(Icons.reply,color: Colors.white,),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                             Padding(
                              padding:  const EdgeInsets.all(5.0),
                              child:Column(

                                children: [
                                   Text("Comment From Assemblyman", style: smallFont.copyWith(fontWeight: FontWeight.w600),),
                                  Text("${ac['comment']}", style: bigFont,),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
