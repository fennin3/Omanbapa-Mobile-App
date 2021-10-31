import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';


class UpdateConstituent extends StatefulWidget {
  final String status;
  final String conId;

  UpdateConstituent({required this.status, required this.conId});

  @override
  _UpdateConstituentState createState() => _UpdateConstituentState();
}

class _UpdateConstituentState extends State<UpdateConstituent> {
  bool _loading = false;
  String selected = "";

  Map dd = {
  "Assembly Man":"ass",
  "Medical Center":"med",
  "Security Personnel":"sec",
  "Regular":"regular"
  };

  void setStatus() async {
    setState(() {
      _loading = true;
    });
    final _pro = Provider.of<GeneralData>(context, listen: false);
    final userId = await UserLocalData.userID();

    http.Response response = await http.post(
        Uri.parse(base_url + "mp-operations/switch-user-status/$userId/${widget.conId}/${dd[selected]}/"));
    if (response.statusCode < 206) {
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    } else {
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);
    }
    _pro.getAllConstituents();
  }

  void setData(){
    setState(() {
      selected = widget.status;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  const Text(
                    "Update Constituent Status",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSelectedItems: true,
                      selectedItem: widget.status,
                      items:  const [
                        "Regular",
                        "Medical Center",
                        "Security Personnel",
                        "Assembly Man"
                      ],
                      label: "Constituent status",
                      hint: "Constituent status",
                      onChanged: (e) {
                        setState(() {
                          selected=e!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(appColor)),
                          onPressed: () {
                            setStatus();

                          },
                          child: !_loading
                              ? const Text(
                            "Save",
                            style: const TextStyle(color: Colors.white),
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
                                  height: 15,
                                  width: 15,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ))
                            ],
                          ))
                    ],
                  )
                ],
              ),

            ),
          ),
        ),
         Positioned(
            top: 10,
            right: 15,
            child: InkWell(
              onTap: ()=>Navigator.pop(context),
              child: const Card(
                color: appColor,
                child: Icon(Icons.close,color: Colors.white,),),
            ))
      ],
    );
  }
}
