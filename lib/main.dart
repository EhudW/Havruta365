import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notificationModel.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'Globals.dart';
import 'Widgets/SplashScreen.dart';
import 'mytimer.dart';

enum MyPrintType { None, TimerTick, Mongo2, Mongo2Test, Nnim, Rethrow }

Map<MyPrintType, bool> myPrintTypes = {
  MyPrintType.None: true,
  MyPrintType.TimerTick: true,
  MyPrintType.Mongo2: true,
  MyPrintType.Mongo2Test: true,
  MyPrintType.Nnim: true,
  MyPrintType.Rethrow: true,
};
myPrint(Object? obj, MyPrintType type) =>
    (myPrintTypes[type] ?? false) ? print(obj) : null;

void main() async {
  runApp(MyApp());
}

class NewNotificationManager {
  // model for the notification
  final notificationModel model = notificationModel();
  // for ui update when updateNotification() called
  Map<Object, Function> refreshMe = {};
  bool newNotification = false; // for state
  // refresh needed ui, without accessing model
  void refreshAll() {
    for (Function refresh in refreshMe.values) {
      refresh();
    }
  }

  // access model(and mongodb), refreshAll if needed
  // true on success; false on error
  Future<bool> updateNotification() async {
    return await model
        .refresh()
        .then((_) {
          var oldValue = newNotification;
          newNotification = !model.isDataEmpty;
          myPrint("newNotification: $newNotification", MyPrintType.Nnim);
          if (oldValue != newNotification) {
            refreshAll();
          }
          return true;
        })
        .catchError((err) => false)
        .whenComplete(() {});
  }
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
  MyTimer? timer;

  @override
  void initState() {
    super.initState();
    Globals.db = new Mongo();
    bool useDb2 = true; // this control if to use reconnecting model
    mongoConnectFuture = Globals.db!.connect(useDb2: useDb2);
    initFirebase();
    if (useDb2) {
      timer = MyTimer(
        duration: 15,
        function: () async {
          return Globals.nnim.updateNotification();
        },
        failAttempts: 3,
        onFail: () async {
          Globals.db!.db.nextReconnect = true;
        },
        timeout: 60,
        onTimeout: () async {
          Globals.db!.db.nextReconnect = true;
        },
      );
      timer!.start(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    Globals.db!.db.close();
    myPrint("dispose", MyPrintType.None);
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
