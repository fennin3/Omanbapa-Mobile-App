import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:omanbapa/screens/auth/login_screen.dart';

class VerifyAccount extends StatefulWidget {
  final String? email;

  VerifyAccount({this.email});

  @override
  _VerifyAccountState createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _code = TextEditingController();

  bool _loading = false;

  void activateAccount() async {
    setState(() {
      _loading = true;
    });
    final Map _data = {
      "email": _email.text,
      "code": _code.text,

    };
    http.Response response = await http.post(
      Uri.parse(base_url + "users/email-otp-verification/"),
      body: _data,
    );

    if (response.statusCode < 206) {
      const snackBar = SnackBar(
        content: Text(
          "Account has been activated successful",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Future.delayed(const Duration(seconds: 2))
          .then((value) => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        ),
            (Route<dynamic> route) => false,
      ));
    } else {
      final snackBar = SnackBar(
        content: Text(
          "${json.decode(response.body)['message']}",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _loading = false;
    });
  }

  void setData(){
    setState(() {
      _email.text = widget.email!;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _code.dispose();
    _email.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Activate Account",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
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
                  "Please check your mail, we have sent a code for activating your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
              const SizedBox(
                height: 20,
              ),
              Container(
                width: size.width * 0.8,
                child: TextFormField(
                  style: TextStyle(fontSize: 14),
                  controller: _code,
                  validator: (e) {
                    if (_code.text.isEmpty) {
                      return "Enter the code we sent";
                    } else {
                      return null;
                    }
                  },
                  decoration: inputFormDeco.copyWith(labelText: "Code"),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 30,),
              InkWell(
                onTap: ()=>activateAccount(),
                child: Container(
                  width: size.width * 0.8,
                  height: 40,
                  decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(7)),
                  child: Center(
                      child: !_loading
                          ? const Text("Activate")
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
    );
  }
}
