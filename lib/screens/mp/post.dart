import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:omanbapa/utils.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _caption = TextEditingController();
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

  void createPost(String? filepath) async {
    setState(() {
      _loading = true;
    });
    final userId = await UserLocalData.userID();
    final Map<String, String> data = {
      "user_id": userId,
      "caption": _caption.text
    };
    final response = http.MultipartRequest(
        'POST', Uri.parse(base_url + "mp-operations/create-post/"));

    if (_image != null) {
      response.files.add(await http.MultipartFile.fromPath("media", filepath!));
    }

    response.fields.addAll(data);

    // response.headers['authorization'] = "Bearer $token";

    var streamedResponse = await response.send();
    var res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode < 206) {
      print(res.body);
      MyUtils.snack(context, "${json.decode(res.body)['message']}", 2);
      Future.delayed(Duration(seconds: 1)).then((value){
        Navigator.pop(context);
        Navigator.pop(context);
      });
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
    _caption.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _loading=false;
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
          "Create Post",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child:  Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: size.width * 0.9,
                      child: TextFormField(
                        maxLines: 2,
                        style: const TextStyle(fontSize: 15),
                        controller: _caption,
                        validator: (e) {
                          if (_caption.text.isEmpty) {
                            return "Enter the post text";
                          } else {
                            return null;
                          }
                        },
                        decoration: inputFormDeco.copyWith(labelText: "Text"),
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
                                createPost(_image== null?"":_image!.path);
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
