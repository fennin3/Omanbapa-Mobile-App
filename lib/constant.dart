import 'package:flutter/material.dart';

const Color appColor = Color.fromRGBO(247, 188, 6, 1);

// const String base_url = "https://api.omanbapa.com/";

const String base_url = "http://192.168.88.192:8000/";

const inputFormDeco = InputDecoration(labelText: "Email",
    labelStyle: TextStyle(fontSize: 13),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appColor))
);