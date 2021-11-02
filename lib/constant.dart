import 'package:flutter/material.dart';

const Color appColor = Color.fromRGBO(247, 188, 6, 1);
// //
const String base_url = "https://api.omanbapa.com/";
const String base_url2 = "https://api.omanbapa.com";

const smallFont = TextStyle(fontSize: 14);
const mediumFont = TextStyle(fontSize: 15);
const bigFont = TextStyle(fontSize: 16);


// const String base_url = "http://192.168.8.132:8000/";
// const String base_url2 = "http://192.168.8.132:8000";


//
// const String base_url = "http://192.168.205.192:8000/";
// const String base_url2 = "http://192.168.205.192:8000";

const inputFormDeco = InputDecoration(labelText: "Email",
    labelStyle: TextStyle(fontSize: 15),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appColor))
);

const kTextFieldDecoration = InputDecoration(
    hintText: 'Enter a value',
    contentPadding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 0.0),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ));