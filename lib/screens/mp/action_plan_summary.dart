import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';


class ActionPlanSummary extends StatefulWidget {
  const ActionPlanSummary({Key? key}) : super(key: key);

  @override
  _ActionPlanSummaryState createState() => _ActionPlanSummaryState();
}

class _ActionPlanSummaryState extends State<ActionPlanSummary> {
  List? years;
  String? currentYear=DateTime.now().year.toString();
  Map _actionPlans = {};
  bool showSpin =false;
  List<Map>? _mapData=[];

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

    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/action-plan-overall-summary/$userId/$year/"));

    if(response.statusCode < 206){
      _mapData=[];
      setState(() {
        _actionPlans = json.decode(response.body)['data'];
        for (var i=0;  i < _actionPlans['problem_titles'].length; i++){
          _mapData!.add({
            "title":_actionPlans['problem_titles'][i],
            "value":_actionPlans['total_ratings'][i],
            "label":_actionPlans['problem_titles'][i],
          });
        }
      });
    }else{

    }
  }
  void retrieveActionPlan2(String year)async{
    setState(() {
      showSpin=true;
    });
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/action-plan-overall-summary/$userId/$year/"));

    if(response.statusCode < 206){
      _mapData=[];
      setState(() {
        _actionPlans = json.decode(response.body)['data'];
        for (var i=0;  i < _actionPlans['problem_titles'].length; i++){
          _mapData!.add({
            "title":_actionPlans['problem_titles'][i],
            "value":_actionPlans['total_ratings'][i],
            "label":_actionPlans['problem_titles'][i],
          });
        }
      });
    }else{

    }

    setState(() {
      showSpin=false;
    });
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
        title:  const Text(
          "Action Plan - Summary",
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

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
                  const SizedBox(height: 30,),
                  if(_mapData!.isEmpty)
                    const Padding(
                      padding:  EdgeInsets.only(top: 100.0),
                      child:  Center(
                        child: Text("No Data"),
                      ),
                    )
                  else
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: SfCircularChart(
                        backgroundColor: Colors.grey[100],

                          legend: Legend(isVisible: true),
                          series: <PieSeries<Map, String>>[
                            PieSeries<Map, String>(
                                explode: true,
                                explodeIndex: 0,
                                dataSource: _mapData,
                                xValueMapper: (Map data, _) => data['title'],
                                yValueMapper: (Map data, _) => data['value'],
                                dataLabelMapper: (Map data, _) => data['label'],
                                dataLabelSettings: const DataLabelSettings(isVisible: true),),
                          ]
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

