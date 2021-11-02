import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class AssessmentSummary extends StatefulWidget {
  const AssessmentSummary({Key? key}) : super(key: key);

  @override
  _AssessmentSummaryState createState() => _AssessmentSummaryState();
}

class _AssessmentSummaryState extends State<AssessmentSummary> {
  List? years;
  String? currentYear=DateTime.now().year.toString();
  List<Map> _condData=[];
  List<Map> _projectData=[];
  bool _done=true;


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

  void retrieveAssessment(String year)async{
    setState(() {
      _done=false;
    });
    Map _data;
    final userId = await UserLocalData.userID();

    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/retrieve-assessment-summary/$userId/$year/"));

    if(response.statusCode < 206){
      _condData=[];
      _projectData=[];
      setState(() {
        _data = json.decode(response.body);
        try{
          for (var i=0;  i < _data['projects_assessment'].length; i++){
            _projectData.add({
              "project":_data['projects_assessment'][i]['project_title'],
              "data": [
                for(var j = 0; j <
                    _data['projects_assessment'][i]['assessement_names']
                        .length; j++)

                  {
                    "title": _data['projects_assessment'][i]['assessement_names'][j],
                    "value": _data['projects_assessment'][i]['assessment_values'][j],
                    "label": _data['projects_assessment'][i]['assessement_names'][j],
                  },
              ]
            });
          }

          for (var i=0; i < _data['conduct_assessment'].length; i++){
            _condData.add({
              "conduct":_data['conduct_assessment'][i]['conduct'],
              "data": [
                for(var j = 0; j < _data['conduct_assessment'][i]['assessment_names']
                    .length; j++)

                  {
                    "title": _data['conduct_assessment'][i]['assessment_names'][j],
                    "value": _data['conduct_assessment'][i]['assessment_value'][j],
                    "label": _data['conduct_assessment'][i]['assessment_names'][j],
                  },
              ]
            });
          }
        }
        catch(e){
          _condData=[];
          _projectData=[];
        }
      });
    }else{
    }

    setState(() {
      _done=true;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveAssessment(currentYear!);
    retrieveYears();
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
          "Assessment - Summary",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _done &&  years != null ?
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
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
                              "2011",
                              for(var year in years!)
                                year.toString()
                            ],
                            label: "Year",
                            hint: "Year",
                            onChanged: (e) {
                              setState(() {
                                currentYear=e;
                              });
                              retrieveAssessment(currentYear!);
                            },
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 10,),
                    const Padding(
                      padding:  EdgeInsets.only(bottom: 8.0),
                      child:  Text("Conduct Assessment", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                    ),
                    if(_condData.isEmpty)
                      const Center(child:  Text("No Data",  style: smallFont),)
                    else
                      for(var con in _condData)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            color: Colors.white,
                            height: 250,
                            child: SfCircularChart(
                                backgroundColor: Colors.grey[100],
                                title: ChartTitle(text: "${con['conduct']}", textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

                                legend: Legend(isVisible: true),
                                series: <PieSeries<Map, String>>[
                                  PieSeries<Map, String>(
                                    explode: true,
                                    explodeIndex: 0,
                                    dataSource: con['data'],
                                    xValueMapper: (Map data, _) => data['title'],
                                    yValueMapper: (Map data, _) => data['value'],
                                    dataLabelMapper: (Map data, _) => data['label'],
                                    dataLabelSettings: const DataLabelSettings(isVisible: true),),
                                ]
                            ),
                          ),
                        ),

                    const SizedBox(height: 20,),
                    const Padding(
                      padding:  EdgeInsets.only(bottom: 8.0),
                      child:  Text("Project Assessment", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                    ),
                    if(_projectData.isEmpty)
                      const Center(child:  Text("No Data", style: smallFont,),)
                    else
                      for(var con in _projectData)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            color: Colors.white,
                            height: 250,
                            child: SfCircularChart(
                                backgroundColor: Colors.grey[100],
                                title: ChartTitle(text: "${con['project']}", textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

                                legend: Legend(isVisible: true),
                                series: <PieSeries<Map, String>>[
                                  PieSeries<Map, String>(
                                    explode: true,
                                    explodeIndex: 0,
                                    dataSource: con['data'],
                                    xValueMapper: (Map data, _) => data['title'],
                                    yValueMapper: (Map data, _) => data['value'],
                                    dataLabelMapper: (Map data, _) => ((data['value']/con['data'].fold(0, (t,e)=>t +e['value'])) * 100).toStringAsFixed(1)+ "%",
                                    dataLabelSettings: const DataLabelSettings(isVisible: true),),
                                ]
                            ),
                          ),
                        ),

                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          )

          :const Center(child: MyProgressIndicator(),),
    );
  }
}
