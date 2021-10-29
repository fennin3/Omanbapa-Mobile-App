import 'package:flutter/cupertino.dart';
import 'package:omanbapa/provider/get_functions.dart';

class GeneralData with ChangeNotifier{
  Map? userData;
  List? projects;
  List? allConstituents=[];



  void getUserData()async{
    userData = await MyFunc.getUserDetails();

    notifyListeners();
  }

  void getProjects()async{
    projects = await MyFunc.getProjects();

    notifyListeners();
  }

  void getAllConstituents()async{
    allConstituents = await MyFunc.allConsttuents();

    notifyListeners();
  }

}