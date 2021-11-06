import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';


class MyUtils{

  static snack(context, text, int duration){
     final snackBar = SnackBar(
      content: Text(
        text,
        style: bigFont,
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: duration),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}