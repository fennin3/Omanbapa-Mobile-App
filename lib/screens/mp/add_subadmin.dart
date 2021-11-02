import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/mp/subadmin_form.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AddSubAdmin extends StatefulWidget {
  const AddSubAdmin({Key? key}) : super(key: key);

  @override
  _AddSubAdminState createState() => _AddSubAdminState();
}

class _AddSubAdminState extends State<AddSubAdmin> {
  String? selectedIndie;
  String? constid;
  String? type="";
  bool _loading =false;
  
  
  void addSubadmin()async{
    setState(() {
      _loading =true;
    });
    final userId = await UserLocalData.userID();
    
    http.Response response = await http.post(Uri.parse(base_url + "mp-operations/mp-make-subadmin/$userId/$constid/"));
    if(response.statusCode < 206){
      setState(() {
        _loading =false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
    else{
      setState(() {
        _loading =false;
      });
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);
    final size = MediaQuery.of(context).size;
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
          "Add Subadmin",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                SizedBox(height: 15,),
                DropdownSearch<String>(
                  mode: Mode.MENU,
                  showSelectedItems: true,
                  items: const [
                    "Existing User",
                    "New User"
                  ],
                  label: "Select Type",
                  hint: "Select the type",
                  onChanged: (e) {
                    setState(() {
                      type=e;
                    });

                  },
                ),
                SizedBox(height: 15,),
                if(type == "Existing User")
                DropdownSearch<String>(
                  mode: Mode.BOTTOM_SHEET,
                  showSelectedItems: true,
                  showSearchBox: true,
                  items: [
                    for(var con in _pro.allusers!)
                      con['full_name'].toString() + " -  (${con['email']})"
                  ],
                  label: "Select constituent",
                  hint: "Select the constituent",
                  onChanged: (e) {
                    setState(() {
                      selectedIndie = e!;
                      List ar = _pro.allConstituents!
                          .where((element) =>
                      element['full_name'] +
                          " -  (${element['email']})" == selectedIndie)
                          .toList();
                      constid = ar[0]['system_id_for_user'];
                    });

                  },
                ),
                if(type == "Existing User")
                const SizedBox(height: 25,),
                if(type == "Existing User")
                Container(
                  width: size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () async {
                          if(constid!.isNotEmpty){
                              addSubadmin();
                          }else{
                            MyUtils.snack(context, "Please select constituent", 2);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                          height: 40,
                          decoration: BoxDecoration(
                              color: appColor,
                              borderRadius: BorderRadius.circular(7)),
                          child:  Center(
                              child: !_loading ? Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              ):const ProcessingWidget()
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if(type == "New User")
                  Container(
                    width: size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const SubAdminForm()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            height: 40,
                            decoration: BoxDecoration(
                                color: appColor,
                                borderRadius: BorderRadius.circular(7)),
                            child: const Center(
                                child: Text(
                                  "Proceed",
                                  style: TextStyle(color: Colors.white),
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProcessingWidget extends StatelessWidget {
  const ProcessingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

