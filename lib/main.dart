//import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/DataBase_auth/mongo2.dart';
//import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta1.dart';
//import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta2.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
//import 'package:havruta_project/Screens/Login/LoginMoreDetails.dart';
//import 'package:havruta_project/Screens/ProfileScreen/ProfileScreen.dart';
//import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'Globals.dart';
import 'Widgets/SplashScreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String>? _id;
  Future? mongoConnectFuture;

  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    //FirebaseCrashlytics.instance.crash();
  }

  // handling timing reconnecting of mongodb
  Timer? timer;
  int fails = 0;
  void setTimer({bool start = false}) {
    print("tick  [${DateTime.now()}]");
    if (timer == null && !start) {
      return;
    }
    timer?.cancel();
    timer = Timer(Duration(seconds: 15), () async {
      var x = Globals.db!.db;
      var force = await Future.any(<Future<bool>>[
        Future.delayed(Duration(), () {
          x.reconnect123();
          return false;
        }),
        Future.delayed(Duration(minutes: 1), () {
          return true;
        })
      ]);
      if (force || fails >= 2) {
        String reason =
            fails >= 2 ? "[over 1 min timeout]" : "[test fails >= 2]";
        print("timer is forcing reconnect   $reason");
        x.nextReconnect = true;
        fails = 0;
      }
      MongoTest.smallTest(Globals.db!, (i) {
        fails += i as int;
      });
      setTimer(start: false);
    });
  }

  @override
  void initState() {
    super.initState();
    Globals.db = new Mongo();
    bool useDb2 = true; // this control if to use reconnecting model
    mongoConnectFuture = Globals.db!.connect(useDb2: useDb2);
    initFirebase();
    if (useDb2) {
      setTimer(start: true);
      // big test:
      //MongoTest.test(mongo: Globals.db!, shouldRethrow: false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    Globals.db!.db.close();
    print("dispose");
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
                return SplashScreen();
              case ConnectionState.done:
                _id = _prefs.then((prefs) {
                  return (prefs.getString('id') ?? "");
                });
                return FutureBuilder(
                    future: _id,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Not connected - go to Login
                            if (snapshot.data == "") {
                              return Login();
                            }
                            // Connected - update current_user and go to home page
                            else {
                              // ignore: non_constant_identifier_names
                              var current_user =
                                  Globals.db!.getUserByID(snapshot.data!);
                              return FutureBuilder(
                                  future: current_user,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<User> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return const CircularProgressIndicator();
                                      case ConnectionState.done:
                                        Globals.currentUser = snapshot.data;
                                        return HomePage();
                                      //break;
                                      default:
                                        return Text('default');
                                    }
                                  });
                            }
                          }
                        //break;
                        default:
                          return Text('default');
                      }
                    });
              //break;
              default:
                return Text('default');
            }
          },
        ),
      )),
    );
  }
}
