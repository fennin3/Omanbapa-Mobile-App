import 'package:shared_preferences/shared_preferences.dart';

class UserLocalData{
  static userToken()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final _token = sharedPreferences.getStringList('userdata')![0];
    return _token;
  }

  static userID()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final _id = sharedPreferences.getStringList('userdata')![3];
    return _id;
  }


  static userEmail()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final _email = sharedPreferences.getStringList('userdata')![2];
    return _email;
  }
}