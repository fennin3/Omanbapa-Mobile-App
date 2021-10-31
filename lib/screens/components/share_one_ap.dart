import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';


class ShareOneAP extends StatefulWidget {
  final String area;
  final String image;

  ShareOneAP({required this.image, required this.area});

  @override
  _ShareOneAPState createState() => _ShareOneAPState();
}

class _ShareOneAPState extends State<ShareOneAP> {
  final TextEditingController _comment = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void shareOnePost() async {
    setState(() {
      _loading = true;
    });
    final _pro = Provider.of<GeneralData>(context, listen: false);
    final userId = await UserLocalData.userID();

    final Map _data = {
      "area": widget.area,
      "image": widget.image,
      "comment": _comment.text
    };

    http.Response response = await http.post(
        Uri.parse(base_url + "mp-operations/share-action-plan/$userId/"),
        body: _data);
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
    _pro.getProjects();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _comment.dispose();
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Share Action Plan as Post",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      style: const TextStyle(fontSize: 14),
                      controller: _comment,
                      validator: (e) {
                        if (_comment.text.isEmpty) {
                          return "Enter your comment";
                        } else {
                          return null;
                        }
                      },
                      decoration: inputFormDeco.copyWith(
                          labelText: "Comment",
                          labelStyle: const TextStyle(fontSize: 11)),
                      keyboardType: TextInputType.text,
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
                              if (_formKey.currentState!.validate()) {
                                shareOnePost();
                              }
                            },
                            child: !_loading
                                ? const Text(
                              "Share",
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


