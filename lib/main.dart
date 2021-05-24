import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/FindMeAChavruta1.dart';
import 'package:havruta_project/Screens/FindMeAChavruta2.dart';
import 'package:havruta_project/Screens/FindMeAChavruta3.dart';
import 'package:havruta_project/Screens/Login1.dart';
import 'package:havruta_project/Widgets/DatePicker.dart';
import 'package:havruta_project/Widgets/ListViews.dart';
import 'Screens/SignupScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FindMeAChavruta1(),
      ),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/landingpage': (BuildContext context) => new MyApp(),
        '/signupScreen': (BuildContext context) => new SignupScreen(),
      },
    );
  }
}
