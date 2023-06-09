import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/DataBase_auth/mongo2.dart';
import 'package:havruta_project/FCM/fcm.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notificationModel.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:mongo_dart/mongo_dart.dart' as mg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'Globals.dart';
import 'Widgets/SplashScreen.dart';
import 'mytimer.dart';
import 'mydebug.dart' as MyDebug;
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';

// put / at start of launchLink to make sure "/" is in the root rather than /inapp/...
final rconfig = GoRouter(routes: [
  GoRoute(
    path: "/inapp/event/:fid",
    builder: (context, state) {
      String hex = state.location.replaceAll("/inapp/event/", "");
      try {
        mg.ObjectId.fromHexString(hex);
        Globals.launchLink = "/" /*<--this*/ + "event::::$hex";
      } catch (e) {
        Globals.launchLink = null;
      }
      return MyApp();
    },
  ),
  GoRoute(
    path: "/",
    builder: (context, state) {
      return MyApp();
    },
  )
]);
void main() async {
  initializeDateFormatting().then((_) => runApp(MaterialApp.router(
        routerConfig: rconfig,
        debugShowCheckedModeBanner: false,
      )));
}

class NewNotificationManager {
  // dispose on state not always work in time
  static NewNotificationManager? onlyLast;
  static int checkEveryXSec = MyDebug.MyConsts.checkNewNotificationSec;
  static int timeoutEveryXSec = MyDebug.MyConsts.checkNewNotificationTimeoutSec;
  // model for the notification
  final notificationModel model = notificationModel();
  late MyTimer _timer;
  NewNotificationManager() {
    // This istance is the new
    var last = onlyLast;
    onlyLast = this;
    // handle last NewNotificationManager instance, by disable its effectiveness
    last?.cancel();
    last?.model.ignoreRequests = true;
    last?.refreshMe = {};

    _timer = MyTimer(
      myDebugLabel: "nnim ${this.hashCode}",
      duration: checkEveryXSec,
      function: () async {
        return updateNotification();
      },
      timeout: timeoutEveryXSec,
      onTimeout: null,
    );
  }
  Future<bool> start() => _timer.start(true);
  void cancel() => _timer.cancel();

  // for ui update when updateNotification() called
  Map<Object, Function> refreshMe = {};
  int newNotification = 0; // for state
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
          newNotification = model.unseenLen;
          MyDebug.myPrint(
              "newNotification: $newNotification    [${this.hashCode}]",
              MyDebug.MyPrintType.Nnim);
          if (oldValue != newNotification) {
            refreshAll();
          }
          if (newNotification == 0) {
            FCM.reset("notis");
          } else {
            var newest = model.getNewest();
            if (newest != null)
              FCM.resetTo("notis", newNotification, newest.name!,
                  newest.message!, "notis");
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

  Future getMgFuture() async {
    if (Globals.isDbConnect == false) {
      await Future.delayed(Duration(milliseconds: 300));
      return await getMgFuture();
    }
  }

  @override
  void initState() {
    super.initState();
    Globals.navKey = GlobalKey();
    mongoConnectFuture = getMgFuture();
    if (Globals.launchLink?.startsWith("/") ?? false) {
      // shift the root, to avoid inf loop when press back button
      Globals.launchLink = Globals.launchLink!.substring(1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 100), () => rconfig.replace("/"));
      });
    }
    if (Globals.MyAppStarted) return;
    Globals.MyAppStarted = true;
    initFirebase();
    Globals.db = new Mongo();
    bool useDb2 =
        MyDebug.MyConsts.useDb2; // this control if to use reconnecting model
    mongoConnectFuture = Globals.db!.connect(useDb2: useDb2);
    if (useDb2 && MyDebug.MyConsts.testConnection) {
      timer = MyTimer(
        myDebugLabel: "MyApp.initState() db refresh",
        duration: MyDebug.MyConsts.testConnectionEveryXSec,
        function: () async {
          return MongoTest.connectionTest(Globals.db!.db);
        },
        failAttempts: MyDebug.MyConsts.testConnectionFailsAttempts,
        onFail: () async {
          if (MyDebug.MyConsts.testConnectionForceReconnectNow) {
            Globals.db!.db.nextReconnect = true;
            Globals.db!.db.reconnect123();
          }
        },
        timeout: MyDebug.MyConsts.testConnectionTimeoutXSec,
        onTimeout: () async {
          if (MyDebug.MyConsts.testConnectionForceReconnectNow) {
            Globals.db!.db.nextReconnect = true;
            Globals.db!.db.reconnect123();
          }
        },
      );
      timer!.start(false);
    }
  }

  @override
  void dispose() {
    // the only case for dispose is if another MyApp is inserted to widget tree instead,
    // but we handled it in initState with Globals.MyAppStarted
    //timer?.cancel();
    //Globals.db!.db.close();
    //MyDebug.myPrint("MyApp dispose", MyDebug.MyPrintType.None);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Globals.navKey,
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
                                  Globals.db!.getUserByID(snapshot.data!, true);
                              return FutureBuilder(
                                  future: current_user,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<User> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return const CircularProgressIndicator();
                                      case ConnectionState.done:
                                        Globals.onNewLogin(snapshot.data!);
                                        Future.delayed(
                                            Duration(milliseconds: 300),
                                            () => FCM.checkInitMsg());
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
