import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:loading_animations/loading_animations.dart';

import 'Screens/HomePageScreen/home_page.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future mongoConnectFuture;

  @override
  void initState(){
    super.initState();
    Globals.db = new Mongo();
    mongoConnectFuture = Globals.db.connect();
  }

  @override
  void dispose(){
    super.dispose();
    Globals.db.db.close();
  }

  User u1 = User.fromUser('Yonatan', '4yonatan4@gmail.com','male');

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
                  Globals.currentUser = u1;
                  return UserScreen("4yonatan4@gmail.com");
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