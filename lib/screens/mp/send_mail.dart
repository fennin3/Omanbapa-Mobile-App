import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';
import 'package:html_editor/html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class SendMail extends StatefulWidget {
  const SendMail({Key? key}) : super(key: key);

  @override
  _SendMailState createState() => _SendMailState();
}

class _SendMailState extends State<SendMail> {
  String mailtype = "All constituents";
  String? selectedIndie;
  String? selectedArea;
  String filepath = "";
  List? areas;
  int? areaId;
  String? constid;
  bool showSpin = false;
  final TextEditingController _subject = TextEditingController();
  GlobalKey<HtmlEditorState> keyEditor = GlobalKey();
  final _formKey = GlobalKey<FormState>();


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

  void getAreas() async {
    final userId = await UserLocalData.userID();

    http.Response response = await http.get(
        Uri.parse(base_url + "mp-operations/get-areas-for-mp/$userId/"));

    if (response.statusCode < 206) {
      setState(() {
        areas = json.decode(response.body)['areas'];
      });
    }
    else {

    }
  }

  void sendMail(String filepath, String subject, String message) async {
    setState(() {
      showSpin = true;
    });
    final userId = await UserLocalData.userID();
    Map<String, String> _data = {
      if(mailtype != "Individual")
        "user_id": userId.toString(),
      if(mailtype == "Individual")
        "sender_id": userId,
      if(mailtype == "Individual")
        "receiver_id": constid.toString(),

      "message": message,
      "subject": subject
    };

    print(_data);

    final _url = mailtype == "Individual"
        ? "mp-operations/mp-send-email/"
        : mailtype == "Area"
        ? "mp-operations/send-email-to-area/$areaId/"
        : "mp-operations/mp-send-emails/";

    try {
      final response = http.MultipartRequest('POST',
          Uri.parse(base_url + _url));

      if (filepath.isNotEmpty) {
        response.files
            .add(await http.MultipartFile.fromPath("attached_file", filepath));
      }
      response.fields.addAll(_data);


      var streamedResponse = await response.send();
      var res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode < 206) {
        MyUtils.snack(context, json.decode(res.body)['message'], 2);
        Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pop(context));
      } else {
        MyUtils.snack(context, "Sorry, something went wrong", 2);

      }
    } on SocketException {
      MyUtils.snack(context, "No Internet", 2);
    }

    setState(() {
      showSpin = false;
      filepath = "";
      _subject.clear();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAreas();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subject.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);
    final size = MediaQuery
        .of(context)
        .size;
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
          "Send mail",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: areas != null ? ModalProgressHUD(
        inAsyncCall: showSpin,
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSelectedItems: true,
                      selectedItem: "All constituents",
                      items: const [
                        "All constituents",
                        "Individual",
                        "Area"
                      ],
                      label: "Recipient(s)",
                      hint: "Choose who to receive this mail",
                      onChanged: (e) {
                        setState(() {
                          mailtype = e!;
                        });
                      },
                    ),


                    //INDIVIDUAL SEARCH BOX
                    if(mailtype == "Individual")
                      const SizedBox(height: 20,),
                    if(mailtype == "Individual")
                      DropdownSearch<String>(
                        mode: Mode.BOTTOM_SHEET,
                        showSelectedItems: true,
                        showSearchBox: true,
                        items: [
                          for(var con in _pro.allConstituents!)
                            con['full_name'] + " -  (${con['email']})"
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


                    //AREA SEARCH BOX
                    if(mailtype == "Area")
                      const SizedBox(height: 20,),
                    if(mailtype == "Area")
                      DropdownSearch<String>(
                        mode: Mode.BOTTOM_SHEET,
                        showSelectedItems: true,
                        showSearchBox: true,
                        items: [
                          for(var area in areas!)
                            area['name']
                        ],
                        label: "Select area",
                        hint: "Select the area",
                        onChanged: (e) {
                          setState(() {
                            selectedArea = e!;
                            List ar = areas!.where((
                                element) => element['name'] == selectedArea)
                                .toList();
                            areaId = ar[0]['id'];
                          });
                        },
                      ),
                    const SizedBox(height: 20,),

                    Container(
                      width: size.width * 0.9,
                      child: TextFormField(
                        style: bigFont,
                        controller: _subject,
                        validator: (e) {
                          if (_subject.text.isEmpty) {
                            return "Enter the subject";
                          } else {
                            return null;
                          }
                        },
                        decoration: inputFormDeco.copyWith(
                            labelText: "Subject"),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(height: 30,),
                    HtmlEditor(
                      hint: "Type your message here...",
                      key: keyEditor,
                      height: 350,
                    ),
                    const SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Attach File",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
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
                    const SizedBox(height: 40,),
                    Container(
                      width: size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                final txt = await keyEditor.currentState!
                                    .getText();

                                if (txt.isEmpty) {
                                  MyUtils.snack(context,
                                      "please message can not be empty", 2);
                                }
                                else {
                                  sendMail(
                                      filepath, _subject.text, txt);
                                }
                              }
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
                                    "Send",
                                    style: TextStyle(color: Colors.white),
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30,),
                  ],
                ),
              ),
            )
        ),
      ) : const Center(child: MyProgressIndicator(),),
    );
  }
}
