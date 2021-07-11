

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:havruta_project/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Globals.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _email;
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
                    // TODO REMOVE THIS CODE WHEN THE CURRENT USER IS READY TO GO
                    // getUser by mail
                    var current_user = Globals.db.getUser("4yonatan4@gmail.com");
                              return FutureBuilder(
                                  future: current_user,
                                  builder: (BuildContext context, AsyncSnapshot<User> snapshot){
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return const CircularProgressIndicator();
                                      default:
                                        // Update global current_user
                                        Globals.currentUser = snapshot.data;
                                        return ProfileScreen();
                                    }
                                  });
                            // TODO CODE TO REMOVE - UNTIL HERE
                    // TODO - CODE OF SAVING DATA IN USER PHONE
                    /*
                    // // return ProfileScreen();
                    // _email = _prefs.then((prefs) {
                    //   return (prefs.getString('email') ?? "");
                    // });
                    // return FutureBuilder(
                    //     future: _email,
                    //     builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    //       switch (snapshot.connectionState) {
                    //         case ConnectionState.waiting:
                    //           return const CircularProgressIndicator();
                    //         default:
                    //           if (snapshot.hasError) {
                    //             return Text('Error: ${snapshot.error}');
                    //           } else {
                    //             // Not connected - go to Login
                    //             if (snapshot.data == ""){
                    //               // This Code need to be in the last login page - to save the mail locally in the user phone
                    //               // Future.delayed(Duration(seconds: 2)).then((value) async {
                    //               //   final SharedPreferences prefs = await _prefs;
                    //               //   await prefs.setString('email', "4yonatan4@gmail.com");
                    //               //   print("email updated");
                    //               // });
                    //               return Login();
                    //             }
                    //             // Connected - update current_user and go to home page
                    //             else {
                    //               var current_user = getUser(snapshot.data);
                    //               return FutureBuilder(
                    //                   future: current_user,
                    //                   builder: (BuildContext context, AsyncSnapshot<User> snapshot){
                    //                     switch (snapshot.connectionState) {
                    //                       case ConnectionState.waiting:
                    //                         return const CircularProgressIndicator();
                    //                       default:
                    //                         Globals.currentUser = snapshot.data;
                    //                         return HomePage();
                    //                     }
                    //                   });
                    //             }
                    //           }
                    //       }
                    //     });
                    // break;
                     */
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
