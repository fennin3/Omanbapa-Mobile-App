import 'package:flutter/material.dart';


class MyUtils{

  static snack(context, text, int duration){
     final snackBar = SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: duration),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}