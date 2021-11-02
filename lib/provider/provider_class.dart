import 'package:flutter/cupertino.dart';
import 'package:omanbapa/provider/get_functions.dart';


class GeneralData with ChangeNotifier{
  Map? userData;
  List? projects;
  List? allConstituents=[];
  List? allusers=[];
  Map? requestnotifications;



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

  void getAllUsers()async{
    allusers = await MyFunc.AllUsers();

    notifyListeners();
  }

  void getrequestNotification()async{
    requestnotifications = await MyFunc.requestNotification();

    notifyListeners();
  }

}