import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta1.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta2.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:havruta_project/Screens/Login/LoginMoreDetails.dart';
import 'package:havruta_project/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  // Future signInAnon() async {
  //   try {
  //     auth.UserCredential result = await _auth.signInAnonymously();
  //     auth.User user = result.user;
  //     return user;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _id;
  Future mongoConnectFuture;

  @override
  void initState() {
    super.initState();
    Globals.db = new Mongo();
    mongoConnectFuture = Globals.db.connect();
  }

  @override
  void dispose() {
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
                _id = _prefs.then((prefs) {
                  return (prefs.getString('id') ?? "");
                });
                return FutureBuilder(
                    future: _id,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Not connected - go to Login
                            if (snapshot.data == ""){
                              return Login();
                            }
                            // Connected - update current_user and go to home page
                            else {
                              var current_user = Globals.db.getUserByID(snapshot.data);
                              return FutureBuilder(
                                  future: current_user,
                                  builder: (BuildContext context, AsyncSnapshot<User> snapshot){
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return const CircularProgressIndicator();
                                      case ConnectionState.done:
                                        Globals.currentUser = snapshot.data;
                                        return HomePage();
                                        break;
                                      default:
                                        return Text('default');
                                    }
                                  });
                            }
                          }
                          break;
                        default:
                          return Text('default');
                      }
                    });
                break;
              default:
                return Text('default');
            }
          },
        ),
      )),
    );
  }
}


// // TODO REMOVE THIS CODE WHEN THE CURRENT USER IS READY TO GO
// // getUser by mail
// var current_user = Globals.db.getUser("4yonatan4@gmail.com");
// return FutureBuilder(
// future: current_user,
// builder:
// (BuildContext context, AsyncSnapshot<User> snapshot) {
// switch (snapshot.connectionState) {
// case ConnectionState.waiting:
// return const CircularProgressIndicator();
// default:
// // Update global current_user
// Globals.currentUser = snapshot.data;
// return Login();
// }
// });
// // TODO CODE TO REMOVE - UNTIL HERE