import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/screens/general/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    final Map _data = {
      "email_or_contact": _email.text,
      "password": _password.text
    };
    http.Response response =
        await http.post(Uri.parse(base_url + "users/login/"), body: _data);

    if (response.statusCode < 206) {
      const snackBar = SnackBar(
        content: Text(
          "Login Successful",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      final _data = json.decode(response.body);
      sharedPreferences.setStringList(
          'userdata', [_data['token'], _data['id'].toString(), _data['email']]);

      sharedPreferences.setBool('loggedIn', true);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print(response.body);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.27,
            ),
            Center(
                child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 70,
                    child: Image.asset("assets/images/logo.jpg"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: TextFormField(
                      style: TextStyle(fontSize: 14),
                      controller: _email,
                      validator: (e) {
                        if (!_email.text.contains('@')) {
                          return "Enter a valid email or phone";
                        } else if (!_email.text.contains('.com')) {
                          return "Enter a valid email or phone";
                        } else if (_email.text.isEmpty) {
                          return "Enter an email address or phone";
                        } else {
                          return null;
                        }
                      },
                      decoration: inputFormDeco,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: TextFormField(
                      style: TextStyle(fontSize: 14),
                      controller: _password,
                      validator: (e) {
                        if (_password.text.isEmpty) {
                          return "Enter password";
                        } else {
                          return null;
                        }
                      },
                      decoration: inputFormDeco.copyWith(labelText: "Password"),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: appColor),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                    child: Container(
                      width: size.width * 0.8,
                      height: 40,
                      decoration: BoxDecoration(
                          color: appColor,
                          borderRadius: BorderRadius.circular(7)),
                      child: Center(
                          child: !_loading
                              ? const Text("Login")
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Processing"),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  ],
                                )),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Need an account?",
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: appColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
