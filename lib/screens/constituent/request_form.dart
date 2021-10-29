import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:html_editor/html_editor.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestFormCon extends StatefulWidget {
  const RequestFormCon({Key? key}) : super(key: key);

  @override
  _RequestFormConState createState() => _RequestFormConState();
}

class _RequestFormConState extends State<RequestFormCon> {
  final TextEditingController _subject = TextEditingController();
  GlobalKey<HtmlEditorState> keyEditor = GlobalKey();
  String filepath = "";
  bool showSpin = false;

  void pickFile() async {
    File result = await FilePicker.getFile();

    if (result != null) {
      setState(() {
        filepath = result.path;
      });
    } else {
      // User canceled the picker
    }
  }


  void sendRequestForm(
      String filepath, String subject, String message, context) async {


    setState(() {
      showSpin=true;
    });
    final userId = await UserLocalData.userID();
    Map<String, String> _data = {
      "sender": userId.toString(),
      "message": message,
      "subject": subject
    };

    try {
      final response = http.MultipartRequest('POST',
          Uri.parse(base_url + "constituent-operations/send-request-form/"));

      if (filepath.isNotEmpty) {
        response.files
            .add(await http.MultipartFile.fromPath("attached_file", filepath));
      }
      response.fields.addAll(_data);


      var streamedResponse = await response.send();
      var res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode < 206) {
        MyUtils.snack(context, json.decode(res.body)['message'], 2);
      } else {
        print(res.body);
        MyUtils.snack(context, "Sorry, something went wrong", 2);
      }
    } on SocketException {
      MyUtils.snack(context, "No Internet", 2);
    }

    setState(() {
      showSpin=false;
      filepath="";
      _subject.clear();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subject.dispose();
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
          "Request Form",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpin,
          progressIndicator: const MyProgressIndicator(),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontSize: 14),
                    controller: _subject,
                    validator: (e) {
                      if (_subject.text.isEmpty) {
                        return "Enter the subject";
                      } else {
                        return null;
                      }
                    },
                    decoration: inputFormDeco.copyWith(
                        labelText: "Subject",
                        labelStyle: TextStyle(fontSize: 11)),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  HtmlEditor(
                    hint: "Your text here...",
                    key: keyEditor,
                    height: 400,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attach File",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        color: Colors.white,
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                flex: 5,
                                child: Text(filepath.isEmpty
                                    ? "This field is not required"
                                    : filepath
                                        .toString()
                                        .split("/")
                                        .last
                                        .toString())),
                            Flexible(
                              child: Container(
                                height: 50,
                                color: appColor,
                                child: TextButton(
                                  onPressed: () => pickFile(),
                                  child: const Icon(
                                    Icons.upload_file,
                                    size: 33,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () async {
          final txt = await keyEditor.currentState!.getText();

          if (txt.isEmpty || _subject.text.isEmpty) {
            MyUtils.snack(
                context, "please subject and message can not be empty", 2);
          } else {
            sendRequestForm(filepath, _subject.text, txt, context);
          }
        },
      ),
    );
  }
}
