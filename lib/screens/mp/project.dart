import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({Key? key}) : super(key: key);

  @override
  _CreateProjectState createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _place = TextEditingController();
  final TextEditingController _description = TextEditingController();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future getImageFromCam() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  void showImagePickerModal() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 160,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Image Pick Options",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => getImageFromCam(),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: appColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                "Open camera",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Icon(
                                Icons.camera,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: appColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: GestureDetector(
                          onTap: () => getImageFromGallery(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                "Open Gallery",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Icon(
                                Icons.image,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void createProject(String? filepath) async {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    setState(() {
      _loading = true;
    });
    final userId = await UserLocalData.userID();
    final Map<String, String> data = {
      "user_id": userId,
      "name": _name.text,
      "place": _place.text,
      "description": _description.text
    };
    final _url = !_pro.userData!['is_mp'] ? "constituent-operations/create-project-for-mp/":"mp-operations/create-project/";

    final response = http.MultipartRequest(
        'POST', Uri.parse(base_url + _url));

    if (_image != null) {
      response.files.add(await http.MultipartFile.fromPath("media", filepath!));
    }
    response.fields.addAll(data);

    // response.headers['authorization'] = "Bearer $token";

    var streamedResponse = await response.send();
    var res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode < 206) {
      MyUtils.snack(context, "${json.decode(res.body)['message']}", 2);
      Navigator.pop(context);
    } else {
      MyUtils.snack(context, "${json.decode(res.body)['message']}", 2);
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _name.dispose();
    _place.dispose();
    _description.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "Create Project",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width * 0.9,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 15),
                      controller: _name,
                      validator: (e) {
                        if (_name.text.isEmpty) {
                          return "Enter the name of the project";
                        } else {
                          return null;
                        }
                      },
                      decoration:
                          inputFormDeco.copyWith(labelText: "Project name"),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width * 0.9,
                    child: TextFormField(
                      style: TextStyle(fontSize: 15),
                      controller: _place,
                      validator: (e) {
                        if (_place.text.isEmpty) {
                          return "Enter the place";
                        } else {
                          return null;
                        }
                      },
                      decoration: inputFormDeco.copyWith(labelText: "Place"),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width * 0.9,
                    child: TextFormField(
                      maxLines: 4,
                      style: TextStyle(fontSize: 15),
                      controller: _description,
                      validator: (e) {
                        if (_description.text.isEmpty) {
                          return "Enter the project description";
                        } else {
                          return null;
                        }
                      },
                      decoration:
                          inputFormDeco.copyWith(labelText: "Description"),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      Container(
                        color: Colors.grey.withOpacity(0.2),
                        height: 300,
                        width: size.width * 0.9,
                        child: _image == null
                            ? const Center(
                                child: Text(
                                  "no image selected.\nImage not required",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                child: Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                )),
                      ),
                      Positioned(
                          bottom: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () => showImagePickerModal(),
                            child: const Card(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: appColor,
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              createProject(_image!.path);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            decoration: BoxDecoration(
                                color: appColor,
                                borderRadius: BorderRadius.circular(7)),
                            child: Center(
                                child: !_loading
                                    ? const Text(
                                        "Create",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Processing"),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            height: 20,
                                            width: 20,
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        ],
                                      )),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
