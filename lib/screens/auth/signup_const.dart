import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/screens/auth/login_screen.dart';
import 'package:omanbapa/screens/auth/verify_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

class SignupConstPage extends StatefulWidget {
  const SignupConstPage({Key? key}) : super(key: key);

  @override
  _SignupConstPageState createState() => _SignupConstPageState();
}

class _SignupConstPageState extends State<SignupConstPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _full_name = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _voterId = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _town = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final TextEditingController _constituency = TextEditingController();
  final TextEditingController _area = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  List? allCountries;
  List allRegions = [];
  List allConstituencies = [];
  List allTowns = [];
  List allAreas = [];

  void signUp() async {
    setState(() {
      _loading = true;
    });
    final Map _data = {
      "email": _email.text,
      "password": _password.text,
      "full_name": _full_name.text,
      "date_of_birth": _dob.text,
      "voters_id": _voterId.text,
      "town": _town.text,
      "contact": _contact.text,
      "country": _country.text,
      "region": _region.text,
      "area": _area.text,
      "constituency": _constituency.text,
    };
    http.Response response = await http.post(
      Uri.parse(base_url + "users/create-constituent-account/"),
      body: _data,
    );

    if (response.statusCode < 206) {
      const snackBar = SnackBar(
        content: Text(
          "Account has been created Successful",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Future.delayed(const Duration(seconds: 2))
          .then((value) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => VerifyAccount(email: _email.text,),
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

  getCountry() async {
    http.Response response =
        await http.get(Uri.parse(base_url + "users/all-countries/"));

    if (response.statusCode < 206) {
      setState(() {
        allCountries = json.decode(response.body);
      });
    } else {}
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _password.dispose();
    _full_name.dispose();
    _dob.dispose();
    _voterId.dispose();
    _contact.dispose();
    _town.dispose();
    _country.dispose();
    _region.dispose();
    _constituency.dispose();
    _area.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountry();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: allCountries != null
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    Form(
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
                              controller: _full_name,
                              validator: (e) {
                                if (_full_name.text.isEmpty) {
                                  return "Enter full name";
                                } else {
                                  return null;
                                }
                              },
                              decoration: inputFormDeco.copyWith(
                                  labelText: "Full name"),
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
                              controller: _voterId,
                              validator: (e) {
                                if (_voterId.text.isEmpty) {
                                  return "Enter ID's number";
                                } else {
                                  return null;
                                }
                              },
                              decoration: inputFormDeco.copyWith(
                                  labelText: "National ID number"),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              width: size.width * 0.8,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 14),
                                      controller: _dob,
                                      validator: (e) {
                                        if (_dob.text.isEmpty) {
                                          return "Enter date of birth";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: inputFormDeco.copyWith(
                                          labelText: "Date of birth"),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2010),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2010),
                                        ).then((value) {
                                          setState(() {
                                            _dob.text = value!.year.toString() +
                                                "-" +
                                                value.month.toString() +
                                                "-" +
                                                value.day.toString();
                                            print(_dob.text);
                                          });
                                        });
                                      },
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: appColor,
                                      ))
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14),
                              controller: _contact,
                              validator: (e) {
                                if (_contact.text.isEmpty) {
                                  return "Enter your contact";
                                } else {
                                  return null;
                                }
                              },
                              decoration: inputFormDeco.copyWith(
                                  labelText: "Contact",
                                  helperText: "example: +233541752049"),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: DropdownSearch<String>(
                              showSearchBox: true,
                              mode: Mode.BOTTOM_SHEET,
                              showSelectedItems: true,
                              items: [
                                for (var country in allCountries!)
                                  country['name']
                              ],
                              label: "Country",
                              hint: "Choose your country",
                              onChanged: (e) {
                                setState(() {
                                  final selected = allCountries!
                                      .where((element) => element['name'] == e)
                                      .toList();
                                  if (selected.isNotEmpty) {
                                    // print(selected[0]);
                                    _country.text =
                                        selected[0]['id'].toString();
                                    allRegions = selected[0]['regions'];
                                  }
                                  print(_country.text);
                                  _region.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: DropdownSearch<String>(
                              showSearchBox: true,
                              mode: Mode.BOTTOM_SHEET,
                              showSelectedItems: true,
                              items: [
                                for (var region in allRegions) region['name']
                              ],
                              label: "Region",
                              hint: "Choose your region",
                              onChanged: (e) {
                                setState(() {
                                  final selected = allRegions
                                      .where((element) => element['name'] == e)
                                      .toList();
                                  if (selected.isNotEmpty) {
                                    // print(selected[0]);
                                    _region.text = selected[0]['id'].toString();
                                    allConstituencies =
                                        selected[0]['constituencies'];
                                  }
                                  _constituency.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: DropdownSearch<String>(
                              showSearchBox: true,
                              mode: Mode.BOTTOM_SHEET,
                              showSelectedItems: true,
                              items: [
                                for (var consti in allConstituencies)
                                  consti['name']
                              ],
                              label: "Constituency",
                              hint: "Choose your constituency",
                              onChanged: (e) {
                                setState(() {
                                  final selected = allConstituencies
                                      .where((element) => element['name'] == e)
                                      .toList();
                                  if (selected.isNotEmpty) {
                                    // print(selected[0]);
                                    _constituency.text =
                                        selected[0]['id'].toString();
                                    allTowns = selected[0]['towns'];
                                  } else {
                                    print("empty");
                                  }
                                  _town.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: DropdownSearch<String>(
                              showSearchBox: true,
                              mode: Mode.BOTTOM_SHEET,
                              showSelectedItems: true,
                              items: [for (var town in allTowns) town['name']],
                              label: "Town",
                              hint: "Choose your town",
                              onChanged: (e) {
                                setState(() {
                                  final selected = allTowns
                                      .where((element) => element['name'] == e)
                                      .toList();
                                  if (selected.isNotEmpty) {
                                    // print(selected[0]);
                                    _town.text = selected[0]['id'].toString();
                                    allAreas = selected[0]['areas'];
                                  } else {
                                    print("empty");
                                  }
                                  _area.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: DropdownSearch<String>(
                              showSearchBox: true,
                              mode: Mode.BOTTOM_SHEET,
                              showSelectedItems: true,
                              items: [for (var area in allAreas) area['name']],
                              label: "Area",
                              hint: "Choose your area",
                              onChanged: (e) {
                                setState(() {
                                  final selected = allAreas
                                      .where((element) => element['name'] == e)
                                      .toList();
                                  if (selected.isNotEmpty) {
                                    // print(selected[0]);
                                    _area.text = selected[0]['id'].toString();
                                  } else {
                                    print("empty");
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: TextFormField(
                              obscureText: true,
                              style: TextStyle(fontSize: 14),
                              controller: _password,
                              validator: (e) {
                                if (_password.text.isEmpty) {
                                  return "Enter password";
                                } else {
                                  return null;
                                }
                              },
                              decoration:
                                  inputFormDeco.copyWith(labelText: "Password"),
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
                              style: TextStyle(fontSize: 14),
                              controller: _confirmPassword,
                              validator: (e) {
                                if (_password.text != _confirmPassword.text) {
                                  return "Passwords do not match";
                                } else {
                                  return null;
                                }
                              },
                              decoration: inputFormDeco.copyWith(
                                  labelText: "Confirm password"),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                signUp();
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
                                      ? const Text("Create account")
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
                          const SizedBox(
                            height: 25,
                          ),
                          Container(
                            width: size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Have an account already?",
                                  style: TextStyle(fontSize: 13),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen())),
                                  child: const Text(
                                    "Sign In",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: appColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          : const Center(
              child: MyProgressIndicator(),
            ),
    );
  }
}

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 50,
          child: Image.asset("assets/images/logo.jpg"),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: 20,
          height: 20,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
      ],
    );
  }
}
