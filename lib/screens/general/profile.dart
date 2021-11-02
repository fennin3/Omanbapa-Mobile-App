import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  bool _loading = false;

  void editprofile(String filepath) async {
    final userId = await UserLocalData.userID();
    final _pro = Provider.of<GeneralData>(context, listen: false);
    setState(() {
      _loading = true;
    });
    final Map<String, String> data = {};
    final response = http.MultipartRequest(
        'POST', Uri.parse(base_url + "general/edit-profile/$userId/"));

    if (_image != null) {
      response.files
          .add(await http.MultipartFile.fromPath("profile_picture", filepath));
    }

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
    _pro.getUserData();
  }

  Future getImageFromCam() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera)
        .then((value) {
      setState(() {
        _image = value;
      });
      print("shhshdhshdhhs");
      editprofile(_image!.path);

    });


  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      setState(() {
        _image = value;
      });
      print("shhshdhshdhhs");
      editprofile(_image!.path);

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

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Container(
        child: _pro.userData == null
            ? const Center(
                child: MyProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                                base_url2 + _pro.userData!['profile_picture']),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => showImagePickerModal(),
                                child: const Card(
                                  color: appColor,
                                  child: Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                      child: Text(
                    "Change profile picture",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )),
                  ProfileWidget(
                    size: size,
                    text: "Full Name",
                    text2: "${_pro.userData!['full_name']}",
                  ),
                  ProfileWidget(
                    size: size,
                    text: "Email",
                    text2: "${_pro.userData!['email']}",
                  ),
                  ProfileWidget(
                    size: size,
                    text: "Phone",
                    text2: "${_pro.userData!['contact']}",
                  ),
                ],
              ),
      ),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    Key? key,
    required this.size,
    required this.text,
    required this.text2,
  }) : super(key: key);

  final Size size;
  final String text;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(6)),
        width: size.width * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              text2,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
