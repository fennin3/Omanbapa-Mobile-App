import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/provider/get_functions.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/screens/auth/signup_mp.dart';
import 'package:omanbapa/screens/auth/verify_account.dart';
import 'package:omanbapa/screens/general/home.dart';
import 'package:omanbapa/utils.dart';
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

    try{
      http.Response response =
      await http.post(Uri.parse(base_url + "users/login/"), body: _data);

      if (response.statusCode < 206) {
        setState(() {
          _loading = false;
        });
        const snackBar = SnackBar(
          content: Text(
            "Login Successful",
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        final _data = json.decode(response.body);
        sharedPreferences.setStringList(
            'userdata', [_data['token'], _data['id'].toString(), _data['email'], _data['system_id_for_user']]);

        sharedPreferences.setBool('loggedIn', true);

        Future.delayed(const Duration(seconds: 1))
            .then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => HomePage(),
          ),
              (Route<dynamic> route) => false,
        ));
      } else {
        setState(() {
          _loading = false;
        });
        if (json.decode(response.body)['email_verified'] != null &&
            json.decode(response.body)['email_verified'] == false) {
          final snackBar = SnackBar(
            content: Text(
              "${json.decode(response.body)['message']}",
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(const Duration(milliseconds: 2100)).then(
                (value) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyAccount(
                  email: _email.text,
                ),
              ),
            ),
          );
        }
        else{
          print(response.body);
          setState(() {
            _loading = false;
          });
          try{
            MyUtils.snack(context, "${json.decode(response.body)['non_field_errors'][0]}", 2);
          }
          catch(e){}
        }
      }
    }
    on SocketException{
      setState(() {
        _loading = false;
      });
      MyUtils.snack(context, "No Internet", 2);
    }
  }

  void accoutTypeModal() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(appColor)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupConstPage()));
                          },
                          child: const Text(
                            "Constituent Account",
                            style: TextStyle(color: Colors.white),
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(appColor)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupMP()));
                          },
                          child: const Text(
                            "MP Account",
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  )
                ],
              ),
            ),
          );
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
                      style: const TextStyle(fontSize: 15),
                      controller: _email,
                      validator: (e) {
                        if (_email.text.isEmpty) {
                          return "Enter an email address or phone";
                        } else {
                          return null;
                        }
                      },
                      decoration: inputFormDeco.copyWith(labelText: "Email or Phone"),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: TextFormField(
                      obscureText: true,
                      style: const TextStyle(fontSize: 15),
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
                              ? const Text("Login", style: mediumFont,)
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
                      children: [
                        const Text(
                          "Need an account?",
                          style: mediumFont,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () => accoutTypeModal(),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: appColor),
                          ),
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
