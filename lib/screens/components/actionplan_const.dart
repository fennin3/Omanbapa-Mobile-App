import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';


class ActionPlanCon extends StatefulWidget {
  const ActionPlanCon({Key? key}) : super(key: key);

  @override
  _ActionPlanConState createState() => _ActionPlanConState();
}

class _ActionPlanConState extends State<ActionPlanCon> {
  bool _loading = false;
  int switchVal = 0;
  List? acTitles;
  String _first="";
  String _second="";
  String _third="";


  void sendActionPlan()async{

    final userId = await UserLocalData.userID();
    setState(() {
      _loading=true;
    });
    final Map _data = {
      "_one":_first,
      "_two":_second,
      "_three":_third
    };

    http.Response response = await http.post(Uri.parse(base_url + "constituent-operations/send-action-plan/$userId/"), body: _data);
    if(response.statusCode < 206){
      setState(() {
        _loading=false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
      Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pop(context));
    }
    else{
      setState(() {
        _loading=false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
      Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pop(context));
    }

  }


  void getACTitles()async{
    http.Response response = await http.get(Uri.parse(base_url + "constituent-operations/action-titles/"));

    if(response.statusCode < 206){
      print(response.body);
      setState(() {
        acTitles = json.decode(response.body)['data'];
      });
    }
    else{
      MyUtils.snack(context, "Sorry, something went wrong.", 2);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getACTitles();
  }
  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);
    print(acTitles);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: InkWell(
            onTap: ()=>Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: const Text("Action Plan", style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: acTitles == null ? const Center(
          child: MyProgressIndicator(),
        ): Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select the problems below in the order of priority",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 20,
                ),
                  Container(
                  child: DropdownSearch<String>(
                    mode: Mode.BOTTOM_SHEET,
                    showSelectedItems: true,
                    items: [
                      for(var tit in acTitles!)
                        tit['title']
                    ],
                    label: "Most Interest",
                    hint: "Select most interest",
                    popupItemDisabled: (String con) => con == _second || con == _third,
                    onChanged: (e) {
                     setState(() {
                       _first=e!;
                     });
                    },
                  ),
                ),
                  const SizedBox(height:15,),
                  Container(
                  child: DropdownSearch<String>(
                    mode: Mode.BOTTOM_SHEET,
                    showSelectedItems: true,
                    items:  [
                      for(var tit in acTitles!)
                        tit['title']
                    ],
                    label: "2nd Interest",
                    hint: "Select 2nd interest",
                    popupItemDisabled: (String con) => con == _first || con == _third,
                    onChanged: (e) {
                     setState(() {
                       _second = e!;
                     });
                    },
                  ),
                ),
                const SizedBox(height:15,),
                  Container(
                  child: DropdownSearch<String>(
                    mode: Mode.BOTTOM_SHEET,
                    showSelectedItems: true,
                    items:  [
                      for(var tit in acTitles!)
                        tit['title']
                    ],
                    label: "3nd Interest",
                    hint: "Select 3nd interest",
                    popupItemDisabled: (String con) => con == _second || con == _first,
                    onChanged: (e) {
                      setState(() {
                        _third=e!;
                      });

                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        sendActionPlan();
                      },
                      child: !_loading
                          ? const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      )
                          : Row(
                        children: [
                          const Text(
                            "Processing",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10,),
                          Container(
                            height: 16,
                            width: 16,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),
                          )
                        ],
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(appColor)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



