import 'package:flutter/material.dart';
import 'package:omanbapa/main.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/constituent/assessment_con.dart';
import 'package:omanbapa/screens/constituent/incident_report.dart';
import 'package:omanbapa/screens/constituent/request_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
            child: Image.asset('assets/images/logo.jpg'),
          )),
          ListTile(
            onTap: () {
              if (_pro.userData!['is_constituent']) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const IncidentReportCon()));
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
            },
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text("Request Form"),
            // onTap: () => Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => AllVendors())),
          ),
          ListTile(
            onTap: () {
              if (_pro.userData!['is_constituent']) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AssessmentCon(),),);
              }
            },
            leading: const Icon(Icons.assessment),
            title: const Text("Assessment"),
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
    );
  }
}
