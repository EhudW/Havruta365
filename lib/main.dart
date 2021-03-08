import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/Login1.dart';
import 'Screens/SignupScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: Login1(),
      ),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/landingpage': (BuildContext context) => new MyApp(),
        '/signupScreen': (BuildContext context)=> new SignupScreen(),
      },
    );
  }
}