import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/main.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/login_screen.dart';
import 'package:omanbapa/screens/constituent/action_plan_approval.dart';
import 'package:omanbapa/screens/constituent/assessment_con.dart';
import 'package:omanbapa/screens/constituent/incident_report.dart';
import 'package:omanbapa/screens/constituent/request_form.dart';
import 'package:omanbapa/screens/mp/action_plan_area.dart';
import 'package:omanbapa/screens/mp/action_plan_summary.dart';
import 'package:omanbapa/screens/mp/add_subadmin.dart';
import 'package:omanbapa/screens/mp/all_constituents.dart';
import 'package:omanbapa/screens/mp/assessment_summary.dart';
import 'package:omanbapa/screens/mp/incidend_report.dart';
import 'package:omanbapa/screens/mp/my_subadmins.dart';
import 'package:omanbapa/screens/mp/request_form.dart';
import 'package:omanbapa/screens/mp/send_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restart/flutter_restart.dart';

class MyDrawer extends StatelessWidget {
  final bool assessment;
  final int ir;
  final int rf;
  final bool notice;

  MyDrawer(
      {required this.assessment,
      required this.ir,
      required this.rf,
      required this.notice});

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
                child: Center(
              child: Image.asset('assets/images/logo.jpg'),
            )),
            if (_pro.userData!['is_assembly_man'] && _pro.userData!['active_constituency']['id'].toString()==_pro.userData!['assembly_man_for'].toString())
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActionPlanApproval(),
                    ),
                  );
                },
                leading: const Icon(Icons.next_plan),
                title: const Text("Action Plan Approval"),
                // onTap: () => Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => AllVendors())),
              ),

            if (_pro.userData!['is_mp'])
              ExpansionTile(
                title: const Text("Action Plan"),
                leading: const Icon(Icons.summarize),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                ),
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActionPlanArea(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.next_plan),
                    title: const Text("Action Plan (area based) "),
                    // onTap: () => Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => AllVendors())),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActionPlanSummary(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.summarize),
                    title: const Text("Action Plan (Summary) "),
                    // onTap: () => Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => AllVendors())),
                  ),
                ],
              ),
            if (_pro.userData!['is_mp'])
              ExpansionTile(
                title: const Text("Manage Constituents"),
                leading: const Icon(Icons.groups),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                ),
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllConstituents(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.groups),
                    title: const Text("All Constituents"),
                    // onTap: () => Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => AllVendors())),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddSubAdmin(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.person),
                    title: const Text("Add Subadmin"),
                    // onTap: () => Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => AllVendors())),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MySubAdmins(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.people),
                    title: const Text("My Subadmins"),
                    // onTap: () => Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => AllVendors())),
                  ),
                ],
              ),

            if (_pro.userData!['is_mp'] ||
                _pro.userData!['is_constituent'] && assessment)
              ListTile(
                onTap: () {
                  if (_pro.userData!['is_constituent']) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssessmentCon(
                          notice: notice,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssessmentSummary(),
                      ),
                    );
                  }
                },
                leading: const Icon(Icons.assessment),
                title: const Text("Assessment"),
                // onTap: () => Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => AllVendors())),
              ),

            ListTile(
              onTap: () {
                if (_pro.userData!['is_constituent']) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IncidentReportCon()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IncidenReportMP()));
                }
              },
              leading: const Icon(Icons.report),
              title: const Text("Incident Report"),
              trailing: _pro.userData!['is_mp'] && ir > 0
                  ? Card(
                      color: Colors.teal,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "$ir",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox(),
              // onTap: () => Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => AllVendors())),
            ),
            ListTile(
              onTap: () {
                if (_pro.userData!['is_constituent']) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestFormCon()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestFormMp()));
                }
              },
              leading: const Icon(Icons.receipt_long_outlined),
              title: _pro.userData!['is_mp']? const Text("Constituent's Request"): const Text("Request Form"),
              trailing: _pro.userData!['is_mp'] && rf > 0
                  ? Card(
                      color: Colors.teal,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "$rf",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox(),
              // onTap: () => Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => AllVendors())),
            ),
            if (_pro.userData!['is_mp'] || (_pro.userData!['is_subadmin'] && _pro.userData!['active_constituency']['id'] == _pro.userData!['subadmin_for'] ))
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SendMail()));
                },
                leading: const Icon(Icons.mail),
                title: const Text("Send Mail"),
                // onTap: () => Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => AllVendors())),
              ),

            //Logout
            ListTile(
              onTap: () async {
                SharedPreferences sharedpref =
                    await SharedPreferences.getInstance();
                sharedpref.remove("loggedIn");
                sharedpref.remove("userdata");
                sharedpref.remove("state");
                // FlutterRestart.restartApp();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              leading: const Icon(Icons.logout),
              title: const Text(
                "Logout",
                style: TextStyle(fontSize: 15),
              ),
              // onTap: () => Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => AllVendors())),
            ),
          ],
        ),
      ),
    );
  }
}
