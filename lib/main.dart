import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'package:havruta_project/Screens/Login1.dart';
import 'package:loading_animations/loading_animations.dart';

import 'Screens/SignupScreen.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var mongoDB;
  Future mongoConnectFuture;

  @override
  void initState(){
    // TODO: implement mongodb
    super.initState();
    mongoDB = new Mongo();
    mongoConnectFuture = mongoDB.connect();
  }

  @override
  void dispose(){
    super.dispose();
    mongoDB.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: FutureBuilder(
            future: mongoConnectFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: LoadingBouncingGrid.square(
                      borderColor: Colors.teal[400],
                      backgroundColor: Colors.teal[400],
                      size: 80.0,
                    ),
                  );
                case ConnectionState.done:
                  return EventScreen();
                default:
                  return Text('default');
              }
            },
          ),
        )
      ),
    );
  }
}