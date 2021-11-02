import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';

class MyFunc{
  static getUserDetails()async{
    Map? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "general/get-user-info/$userId/"));

    if(response.statusCode < 206){
      _data = json.decode(response.body);
    }
    else{
    }
    return _data;
  }

  static getProjects()async{
    List? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "constituent-operations/retrieve-projects/$userId/"));

    if(response.statusCode < 206){
      _data = json.decode(response.body)['data'];
    }
    else{
    }
    return _data;

  }

  static checkForMp()async{
    Map? _data;
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "general/check-for-mp/$userId/"));

    if(response.statusCode < 206){
      _data = json.decode(response.body)['mp'];
    }
    else{
      print(response.body);
    }
    return _data;

  }


  static allConsttuents()async{
    List? _data=[];
    final userId = await UserLocalData.userID();
    http.Response response = await http.post(Uri.parse(base_url + "mp-operations/list-mp-constituent/$userId/"));

    if(response.statusCode < 206){
      _data = json.decode(response.body)['data'];
    }
    else{
      print(response.body);
    }

    return _data;
  }

  static AllUsers()async{
    List? _data=[];
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/get-users-in-country/Ghana/"));

    if(response.statusCode < 206){
      _data = json.decode(response.body)['data'];
    }
    else{
      print(response.body);
    }

    return _data;
  }


  static requestNotification()async{
    Map? _data={};
    final userId = await UserLocalData.userID();
    http.Response response = await http.get(Uri.parse(base_url + "mp-operations/mp-request-notifications/$userId/"));

    if(response.statusCode < 206){
      _data = json.decode(response.body);
    }
    else{
    }

    return _data;
  }


}