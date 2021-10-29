import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:provider/provider.dart';

class SecRegistration extends StatefulWidget {
  final List data;

  SecRegistration({required this.data});

  @override
  _SecRegistrationState createState() => _SecRegistrationState();
}

class _SecRegistrationState extends State<SecRegistration> {
  final TextEditingController _town = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final TextEditingController _constituency = TextEditingController();
  final TextEditingController _area = TextEditingController();

  List allRegions = [];
  List allConstituencies = [];
  List allTowns = [];
  List allAreas = [];
  bool _loading = false;

  void setData() {
    setState(() {
      allRegions = widget.data;
    });
  }

  void setPro(){
    final _pro = Provider.of<GeneralData>(context, listen: false);
    _pro.getProjects();
    _pro.getUserData();
  }

  void secRegister() async {
    setState(() {
      _loading=true;
    });

    final userId = await UserLocalData.userID();
    final Map _data = {
      "system_id_for_user": userId.toString(),
      "town": _town.text,
      "region": _region.text,
      "area": _area.text,
      "constituency": _constituency.text,
    };


    http.Response response = await http.put(
      Uri.parse(base_url + "users/create-secondary-account/"),
      body: _data,
    );

    if (response.statusCode < 206) {
      setPro();
      setState(() {
        _loading=false;
      });
      final snackBar = SnackBar(
        content: Text(
          "${json.decode(response.body)['message']}",
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
      setState(() {
      });
    } else {
      setState(() {
        _loading=false;
      });
      const snackBar =  SnackBar(
        content: Text(
          "Sorry, something went wrong",
          textAlign: TextAlign.center,
        ),
        duration:  Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _town.dispose();
    _region.dispose();
    _constituency.dispose();
    _area.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _pro = Provider.of<GeneralData>(context, listen: true);
    return Container(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Join Another Constituency",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: DropdownSearch<String>(
                      showSearchBox: true,
                      mode: Mode.BOTTOM_SHEET,
                      showSelectedItems: true,
                      items: [for (var region in allRegions) region['name']],
                      label: "Region",
                      hint: "Choose your region",
                      onChanged: (e) {
                        setState(() {
                          final selected = allRegions
                              .where((element) => element['name'] == e)
                              .toList();
                          if (selected.isNotEmpty) {
                            // print(selected[0]);
                            _region.text = selected[0]['id'].toString();
                            allConstituencies = selected[0]['constituencies'];
                          }
                          _constituency.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: DropdownSearch<String>(
                      showSearchBox: true,
                      mode: Mode.BOTTOM_SHEET,
                      showSelectedItems: true,
                      items: [
                        for (var consti in allConstituencies) consti['name']
                      ],
                      label: "Constituency",
                      hint: "Choose your constituency",
                      popupItemDisabled: (String con) => con == _pro.userData!['active_constituency']['name'],
                      onChanged: (e) {
                        setState(() {
                          final selected = allConstituencies
                              .where((element) => element['name'] == e)
                              .toList();
                          if (selected.isNotEmpty) {
                            // print(selected[0]);
                            _constituency.text = selected[0]['id'].toString();
                            allTowns = selected[0]['towns'];
                          } else {
                            print("empty");
                          }
                          _town.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: DropdownSearch<String>(
                      showSearchBox: true,
                      mode: Mode.BOTTOM_SHEET,
                      showSelectedItems: true,
                      items: [for (var town in allTowns) town['name']],
                      label: "Town",
                      hint: "Choose your town",
                      onChanged: (e) {
                        setState(() {
                          final selected = allTowns
                              .where((element) => element['name'] == e)
                              .toList();
                          if (selected.isNotEmpty) {
                            // print(selected[0]);
                            _town.text = selected[0]['id'].toString();
                            allAreas = selected[0]['areas'];
                          } else {
                            print("empty");
                          }
                          _area.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: DropdownSearch<String>(
                      showSearchBox: true,
                      mode: Mode.BOTTOM_SHEET,
                      showSelectedItems: true,
                      items: [for (var area in allAreas) area['name']],
                      label: "Area",
                      hint: "Choose your area",
                      onChanged: (e) {
                        setState(() {
                          final selected = allAreas
                              .where((element) => element['name'] == e)
                              .toList();
                          if (selected.isNotEmpty) {
                            // print(selected[0]);
                            _area.text = selected[0]['id'].toString();
                          } else {
                            print("empty");
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     TextButton(
                       onPressed: () {
                         secRegister();
                       },
                       child: !_loading
                           ? const Text(
                         "Join",
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
          Positioned(
            right: 0,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Card(
                color: appColor,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
