import 'package:flutter/material.dart';
import 'package:omanbapa/main.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/constituent/assessment_con.dart';
import 'package:omanbapa/screens/constituent/incident_report.dart';
import 'package:omanbapa/screens/constituent/request_form.dart';
import 'package:omanbapa/screens/mp/action_plan_area.dart';
import 'package:omanbapa/screens/mp/action_plan_summary.dart';
import 'package:omanbapa/screens/mp/all_constituents.dart';
import 'package:omanbapa/screens/mp/assessment_summary.dart';
import 'package:omanbapa/screens/mp/incidend_report.dart';
import 'package:omanbapa/screens/mp/request_form.dart';
import 'package:omanbapa/screens/mp/send_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  final bool assessment;
  MyDrawer({required this.assessment});

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
            if(_pro.userData!['is_mp'])
              ListTile(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActionPlanArea(),),);

                },
                leading: const Icon(Icons.next_plan),
                title: const Text("Action Plan (area based) "),
                // onTap: () => Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => AllVendors())),
              ),
            if(_pro.userData!['is_mp'])
              ListTile(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActionPlanSummary(),),);

                },
                leading: const Icon(Icons.summarize),
                title: const Text("Action Plan (Summary) "),
                // onTap: () => Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => AllVendors())),
              ),
            if(_pro.userData!['is_mp'])
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllConstituents(),),);

                },
                leading: const Icon(Icons.groups),
                title: const Text("All Constituents"),
                // onTap: () => Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => AllVendors())),
              ),
            if(_pro.userData!['is_mp'] || _pro.userData!['is_constituent'] && assessment)
              ListTile(
                onTap: () {
                  if (_pro.userData!['is_constituent']) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssessmentCon(),),);
                  }
                  else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssessmentSummary(),),);
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
                }
                else{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IncidenReportMP()));
                }
              },
              leading: const Icon(Icons.report),
              title: const Text("Incident Report"),
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
                }
                else{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestFormMp()));
                }
              },
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text("Request Form"),
              // onTap: () => Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => AllVendors())),
            ),
            if(_pro.userData!['is_mp'])
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
                main();
              },
              leading: Icon(Icons.logout),
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
