import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/utils.dart';

import 'login_screen.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _email = TextEditingController();
  bool _loading =false;
  final _formKey = GlobalKey<FormState>();

  void sendMail() async {
    setState(() {
      _loading = true;
    });

    http.Response response = await http.post(
      Uri.parse(base_url + "users/send-reset-code/${_email.text}/"),
    );



    if (response.statusCode < 206) {
      print(response.body);
      MyUtils.snack(context, "${json.decode(response.body)['message']}", 2);

    } else {
      print(response.body);
      final snackBar = SnackBar(
        content: Text(
          "${json.decode(response.body)['message']}",
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(onPressed: ()=>Navigator.pop(context),icon: Icon(Icons.arrow_back_ios, color: Colors.white,),),
        title: const Text(
          "Password Reset",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.06,
                ),
                Container(
                  width: 120,
                  height: 120,
                  child: Image.asset('assets/images/account.png'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: size.width * 0.8,
                  child: const Text(
                    "Please provide your email, we will send instructions via your mail on how to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: size.width * 0.8,
                  child: TextFormField(
                    style: TextStyle(fontSize: 16),
                    controller: _email,
                    validator: (e) {
                      if (!_email.text.contains('@')) {
                        return "Enter a valid email";
                      } else if (!_email.text.contains('.com')) {
                        return "Enter a valid email";
                      } else if (_email.text.isEmpty) {
                        return "Enter an email address";
                      } else {
                        return null;
                      }
                    },
                    decoration: inputFormDeco,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 30,),
                InkWell(
                  onTap: (){
                    if(_formKey.currentState!.validate()){
                      sendMail();
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
                            ? const Text("Send Mail")
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
          ),
        ),
      ),
    );
  }
}
