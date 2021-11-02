import 'package:flutter/material.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omanbapa/screens/general/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/services.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

void main() async{
  String state = "";
  WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final _loggedId = sharedPreferences.getBool('loggedIn');

  if (sharedPreferences.getString("state") != null) {
    state = sharedPreferences.getString("state")!;
  } else {
    state = getRandomString(10);

    sharedPreferences.setString("state", state);
  }
  runApp(MultiProvider(
    key: ObjectKey(state),
    providers: [
      ChangeNotifierProvider<GeneralData>(
        create: (_) => GeneralData(),
      ),
    ],
    child: MyApp(loggedid: _loggedId,),
  ),);
}


class MyApp extends StatelessWidget {
  final loggedid;

  MyApp({this.loggedid});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omanbapa',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: loggedid == true? const HomePage(): const LoginScreen(),
    );
  }
}


