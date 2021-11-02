import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omanbapa/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActionPlanApproval extends StatefulWidget {
  const ActionPlanApproval({Key? key}) : super(key: key);

  @override
  _ActionPlanApprovalState createState() => _ActionPlanApprovalState();
}

class _ActionPlanApprovalState extends State<ActionPlanApproval> {
  bool showSpin = false;
  List? years;
  List<Map> _mapData = [];
  Map? _actionPlans;
  bool approved = false;
  String? currentYear = DateTime.now().year.toString();
  final TextEditingController _comment = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void retrieveActionPlan(String year) async {
    final userId = await UserLocalData.userID();

    http.Response response = await http.get(Uri.parse(base_url +
        "constituent-operations/retrieve-action-plan-summary/$userId/$year/"));

    if (response.statusCode < 206) {
      _mapData = [];
      setState(() {
        _actionPlans = json.decode(response.body);
        print(_actionPlans);
        print("**********");
        for (var i = 0; i < _actionPlans!['problem_titles'].length; i++) {
          _mapData.add({
            "title": _actionPlans!['problem_titles'][i],
            "value": _actionPlans!['stats'][i],
            "label": _actionPlans!['problem_titles'][i],
          });
        }
      });
    } else {}
  }

  void retrieveActionPlan2(String year) async {
    setState(() {
      showSpin = true;
    });
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(
        base_url + "constituent-operations/retrieve-action-plan-summary/$userId/$year/"));

    if (response.statusCode < 206) {
      _mapData = [];
      setState(() {
        _actionPlans = json.decode(response.body)['data'];
        for (var i = 0; i < _actionPlans!['problem_titles'].length; i++) {
          _mapData.add({
            "title": _actionPlans!['problem_titles'][i],
            "value": _actionPlans!['stats'][i],
            "label": _actionPlans!['problem_titles'][i],
          });
        }
      });
    } else {}

    setState(() {
      showSpin = false;
    });
  }

  void retrieveYears() async {
    http.Response response = await http
        .get(Uri.parse(base_url + "constituent-operations/retrieve-years/"));

    if (response.statusCode < 206) {
      setState(() {
        years = json.decode(response.body)['years'];
        if (years!.isEmpty) {
          years!.add(DateTime.now().year.toString());
        }
      });
    } else {}
  }

  void getACApprovalStatus() async {
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url +
        "constituent-operations/approval-status/$userId/$currentYear/"));
    if (response.statusCode < 206) {
      print(response.body);
      setState(() {
        approved = json.decode(response.body)['status'];
      });
    } else {}
  }

  void approveActionPlan() async {
    setState(() {
      showSpin=true;
    });
    final userId = await UserLocalData.userID();

    final Map _data = {
      "problem_titles": _actionPlans!['problem_titles'],
      "stats": _actionPlans!['stats'],
      "comment":_comment.text
    };

    http.Response response = await http.post(
        Uri.parse(base_url +
            "constituent-operations/approval-status/$userId/$currentYear/"),
        body: json.encode(_data),
        headers: {'Content-Type': 'application/json'});

    if(response.statusCode <206){
      // getACApprovalStatus();
      setState(() {
        showSpin=false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
    else{
      setState(() {
        showSpin=false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);

    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveActionPlan(currentYear!);
    retrieveYears();
    getACApprovalStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _comment.dispose();
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
            "Action Plan Approval",
            style: TextStyle(color: Colors.white),
          )),
      body: _actionPlans == null || years == null
          ? const Center(child: MyProgressIndicator())
          : ModalProgressHUD(
              inAsyncCall: showSpin,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
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
                                  items: [
                                    for (var year in years!) year.toString()
                                  ],
                                  label: "Year",
                                  hint: "Year",
                                  onChanged: (e) {
                                    setState(() {
                                      currentYear = e;
                                    });
                                    retrieveActionPlan2(currentYear!);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          if (_mapData.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: Text("No Data"),
                              ),
                            )
                          else
                            Container(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: SfCircularChart(
                                  backgroundColor: Colors.grey[100],
                                  legend: Legend(isVisible: true),
                                  series: <PieSeries<Map, String>>[
                                    PieSeries<Map, String>(
                                      explode: true,
                                      explodeIndex: 0,
                                      dataSource: _mapData,
                                      xValueMapper: (Map data, _) =>
                                          data['title'],
                                      yValueMapper: (Map data, _) =>
                                          data['value'],
                                      dataLabelMapper: (Map data, _) =>
                                          data['label'],
                                      dataLabelSettings: const DataLabelSettings(
                                          isVisible: true),
                                    ),
                                  ]),
                            ),

                          const SizedBox(height: 10),
                          if (_mapData.isNotEmpty && !approved)
                          Container(
                            width: MediaQuery.of(context).size.width *0.9,
                            child: TextFormField(

                              style: const TextStyle(fontSize: 14),
                              controller: _comment,
                              validator: (e) {
                                if (_comment.text.isEmpty || approved) {
                                  return "Enter the comment";
                                } else {
                                  return null;
                                }
                              },
                              decoration: inputFormDeco.copyWith(labelText: "Comment", labelStyle: const TextStyle(fontSize: 11)),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (_mapData.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                  message:
                                      "Press this button to approve this action plan.",
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(approved
                                                  ? Colors.blueGrey
                                                  : appColor)),
                                      onPressed: () {
                                        if (!approved) {
                                          if(_formKey.currentState!.validate()){
                                            approveActionPlan();
                                          }
                                        } else {
                                          MyUtils.snack(context,
                                              "You have already approved it", 2);
                                        }
                                      },
                                      child: Text(
                                        approved ? "Approved" : "Approve",
                                        style:
                                            const TextStyle(color: Colors.white),
                                      )),
                                )
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
