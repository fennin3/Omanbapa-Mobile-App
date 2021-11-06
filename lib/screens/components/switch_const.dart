import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SwitchConst extends StatefulWidget {
  const SwitchConst({Key? key}) : super(key: key);

  @override
  _SwitchConstState createState() => _SwitchConstState();
}

class _SwitchConstState extends State<SwitchConst> {
  bool _loading = false;
  int switchVal = 0;
  int? selected;

  void setPro() {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    _pro.getProjects();
    _pro.getUserData();
  }

  void switchConstituency() async {
    setState(() {
      _loading = true;
    });
    final userId = await UserLocalData.userID();
    http.Response response = await http.post(
      Uri.parse(base_url +
          "constituent-operations/switch-active-constituency/$userId/$selected/"),
    );

    if (response.statusCode < 206) {
      setPro();
      setState(() {
        _loading = false;
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
      setState(() {});
    } else {
      setState(() {
        _loading = false;
      });
      const snackBar = SnackBar(
        content: Text(
          "Sorry, something went wrong",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void setData() {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    final List _inds = _pro.userData!['constituency'].where((element)=> element['id']!=_pro.userData!['active_constituency']['id']).toList();
    if(_inds.isNotEmpty){
      setState(() {
        switchVal = _inds[0]['id'];
      });
    }
    else{
      setState(() {
        switchVal = _pro.userData!['active_constituency']['id'];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);
    // print(_pro.userData!['constituency']);
    // print(_pro.userData!['active_constituency']);
    return Container(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Switch Active Constituency",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      // for (var con in _pro.userData!['constituency'])
                      //   InkWell(
                      //       onTap: () {
                      //         setState(() {
                      //           switchVal = con['id'];
                      //         });
                      //       },
                      //       child: SwitchWidget(
                      //         data: con,
                      //         switchValue:
                      //             con['id'] == switchVal ? true : false,
                      //       )),
                      for (var con in _pro.userData!['constituency'])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            padding: const EdgeInsets.only(left: 8),
                            color: Colors.black.withOpacity(0.04),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  "${con['name']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Switch(
                                    value:
                                        con['id'] == switchVal ? false:true,
                                    onChanged: (e) {
                                      if (e == false) {
                                        final _ind = _pro.userData!['constituency'].indexOf(con);
                                          setState(() {
                                            switchVal=con['id'];
                                            if(_ind == 0){
                                              selected = _pro.userData!['constituency'][1]['id'];
                                            }
                                            else{
                                              selected = _pro.userData!['constituency'][0]['id'];
                                            }
                                          });
                                      }
                                      else{
                                        final _ind = _pro.userData!['constituency'].indexOf(con);
                                        if(_ind==0){
                                          setState(() {
                                            switchVal = _pro.userData!['constituency'][1]['id'];
                                            selected = _pro.userData!['constituency'][0]['id'];
                                          });
                                        }
                                        else{
                                          setState(() {
                                            switchVal = _pro.userData!['constituency'][0]['id'];
                                            selected = _pro.userData!['constituency'][1]['id'];
                                          });
                                        }
                                        print(switchVal);
                                      }

                                      switchConstituency();
                                    })
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if(_loading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                        },
                        child: !_loading
                            ? const Text(
                                "Switch",
                                style: TextStyle(color: Colors.white),
                              )
                            : Row(
                                children: [
                                  const Text(
                                    "Processing",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 16,
                                    width: 16,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                ],
                              ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(appColor)),
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

class SwitchWidget extends StatelessWidget {
  final Map data;
  final bool switchValue;

  SwitchWidget({required this.data, required this.switchValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        color: Colors.black.withOpacity(0.04),
        child: Row(
          children: [
            Expanded(
                child: Text(
              "${data['name']}",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )),
            const SizedBox(
              width: 10,
            ),
            Switch(value: switchValue, onChanged: (e) {})
          ],
        ),
      ),
    );
  }
}
