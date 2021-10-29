import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/model.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omanbapa/utils.dart';

class AssessmentCon extends StatefulWidget {
  const AssessmentCon({Key? key}) : super(key: key);

  @override
  _AssessmentConState createState() => _AssessmentConState();
}

class _AssessmentConState extends State<AssessmentCon> {
  bool _loading = false;
  List? _projects;
  List? _conducts;
  List<AssessProject> _assProjects = [];
  List<AssessCond> _assConds = [];

  void getProjects() async {
    final userId = await UserLocalData.userID();
    final year = DateTime.now().year;
    http.Response response = await http.get(Uri.parse(base_url +
        "constituent-operations/retrive-projects-for-assessment/$userId/$year/"));
    if (response.statusCode < 206) {
      print(response.body);
      setState(() {
        _projects = json.decode(response.body)['projects'];
        for (var prod in _projects!) {
          _assProjects.add(AssessProject(keyy: prod['name']));
        }
      });
    } else {}
  }

  void getConducts() async {
    final userId = await UserLocalData.userID();
    final year = DateTime.now().year;
    http.Response response = await http.get(Uri.parse(
        base_url + "constituent-operations/retrive-conducts-for-assessment/"));
    if (response.statusCode < 206) {
      setState(() {
        _conducts = json.decode(response.body)['data'];
        for (var cond in _conducts!) {
          _assConds.add(AssessCond(keyy: cond['title']));
        }
      });
    } else {}
  }

  sendAssesment()async{
    setState(() {
      _loading=true;
    });
    final userId = await UserLocalData.userID();
    Map _proj_ass={};
    Map _con_ass={};
    for(var proj in _assProjects){
      _proj_ass.putIfAbsent(proj.text, () => proj.keyy);
    }

    for(var con in _assConds){
      _con_ass.putIfAbsent(con.keyy, () => con.text);
    }
    final Map _data = {
      "projects_assessment": _proj_ass,
      "conduct_assessment":_con_ass
    };
    http.Response response = await http.post(Uri.parse(base_url + "constituent-operations/send-assessment/$userId/"),
    body: json.encode(_data),
      headers: {'Content-Type': 'application/json'}
    );
    if(response.statusCode < 206){
      setState(() {
        _loading=false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
      Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pop(context));
    }else{
      setState(() {
        _loading=false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProjects();
    getConducts();
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
          "Assesment",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _projects == null && _conducts == null
          ? Center(
              child: MyProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Projects",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    for (var proj in _assProjects)
                      Column(
                        children: [
                          Text("${proj.keyy}"),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: DropdownSearch<String>(
                              mode: Mode.MENU,
                              showSelectedItems: true,
                              items: const [
                                "Excellent",
                                "Very Good",
                                "Good",
                                "Average",
                                "Poor"
                              ],
                              label: "Select",
                              hint: "Select your assessment",
                              // popupItemDisabled: (String con) => con == _second || con == _first,
                              onChanged: (e) {
                                setState(() {
                                  final pro = _projects!.where((element) => element['name']==proj.keyy).toList();
                                  if(pro.isNotEmpty){
                                    proj.text = pro[0]['id'].toString();
                                  }
                                  print(proj.text);
                                  print(proj.keyy);
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Conducts",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    for (var cond in _assConds)
                      Column(
                        children: [
                          Text("${cond.keyy}"),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: DropdownSearch<String>(
                              mode: Mode.MENU,
                              showSelectedItems: true,
                              items: const [
                                "Excellent",
                                "Very Good",
                                "Good",
                                "Average",
                                "Poor"
                              ],
                              label: "Select",
                              hint: "Select your assessment",
                              // popupItemDisabled: (String con) => con == _second || con == _first,
                              onChanged: (e) {
                                setState(() {
                                  cond.text=e;

                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            sendAssesment();
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
    );
  }
}
