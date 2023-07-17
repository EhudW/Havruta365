import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/auth/screens/login_screen.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:havruta_project/data_base/auto_reconnect_mongo.dart';
import 'package:havruta_project/notifications/notifications/notification_model.dart';
import 'package:havruta_project/home_page.dart';
import 'package:havruta_project/notifications/push_notifications/fcm.dart';
import 'package:havruta_project/widgets/my_future_builder.dart';
import 'package:mongo_dart/mongo_dart.dart' as mg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'globals.dart';
import 'widgets/splash_screen.dart';
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
    path: "/start",
    builder: (context, state) {
      return MyApp();
    },
  ),
  GoRoute(
    path: "/",
    builder: (context, state) {
      return MyApp();
    },
  ),
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
  static int _checkEveryXSec = MyDebug.MyConsts.checkNewNotificationSec;
  static int _timeoutEveryXSec =
      MyDebug.MyConsts.checkNewNotificationTimeoutSec;
  // model for the notification
  final NotificationModel model = NotificationModel();
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
      duration: _checkEveryXSec,
      function: () async {
        return _updateNotification();
      },
      timeout: _timeoutEveryXSec,
      onTimeout: null,
    );
  }
  Future<bool> start() => _timer.start(true);
  void cancel() => _timer.cancel();

  // for ui update when updateNotification() called
  Map<Object, Function> refreshMe = {};
  int newNotification = 0; // for state
  int _lastTimeRefreshed = 0;
  // refresh needed ui,fcm, without accessing mongoDB;
  //  after nnim.model.remove (modify mongoDb), call this nnim.refreshAll
  // use tryAvoidNext2Sec only on user actions (like dismiss many notification in a row)
  // use force only in user action
  void refreshAll(
      {bool tryAvoidNext2Sec = false,
      String debuglbl = "",
      forceRefresh = false}) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (tryAvoidNext2Sec) _lastTimeRefreshed = now;
    if (now - _lastTimeRefreshed < 2000 && forceRefresh == false) {
      Future.delayed(
          Duration(seconds: 2),
          () => this._lastTimeRefreshed < now
              ? refreshAll(debuglbl: "re:$debuglbl")
              : null);
      return;
    }
    _lastTimeRefreshed = now;
    var oldValue = newNotification;
    newNotification = model.unseenLen;
    MyDebug.myPrint(
        "newNotification: $newNotification  $debuglbl  [${this.hashCode}]",
        MyDebug.MyPrintType.Nnim);
    if (oldValue != newNotification) {
      for (Function refresh in refreshMe.values) {
        refresh();
      }
    }
    if (newNotification == 0) {
      FCM.reset("notis");
    } else {
      var newest = model.getNewest();
      if (newest != null)
        FCM.resetTo(
            "notis", newNotification, newest.name!, newest.message!, "notis");
    }
  }

  // access model(and mongodb), refreshAll if needed
  // true on success; false on error
  Future<bool> _updateNotification() async {
    return await model
        .refresh()
        .then((_) {
          refreshAll(debuglbl: "by timer uN()");
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
  Future? mongoConnectFuture;

  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    //FirebaseCrashlytics.instance.crash();
    await Globals.prefs;
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
    if (Globals.MyAppStarted) return;
    Globals.MyAppStarted = true;
    initFirebase();
    Globals.db = new MongoCommands();
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
    if (Globals.launchLink?.startsWith("/") ?? false) {
      // shift the root, to avoid inf loop when press back button
      Globals.launchLink = Globals.launchLink!.substring(1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 100), () => rconfig.replace("/"));
      });
    }
    var connectionDoneContent = (dynamic snapshot) {
      Future<User?> localUser = _prefs
          // await for shared preferences
          .then((prefs) => prefs.getString('id') ?? "")
          // await for User from mongodb
          .then((id) => id == "" ? null : Globals.db!.getUserByID(id, true));

      return FutureBuilder(
          future: localUser,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  int minVer = Globals.db!.configMap['minAppVersionForce'];
                  int currVer = MyDebug.MyConsts.APP_VERSION;
                  if (minVer > currVer) {
                    return MustUpgradeScreen(
                        minVer: '$minVer', currVer: '$currVer');
                  }
                  // Not connected - go to Login
                  if (snapshot.data == null) {
                    return LoginScreen();
                    // Connected - update current_user and go to home page
                  } else {
                    Globals.onNewLogin(snapshot.data!, inbuild: true);
                    return HomePage();
                  }
                }
              //break;
              default:
                return Text('default');
            }
          });
    };
    return MaterialApp(
      navigatorKey: Globals.navKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
              child: myFutureBuilder(mongoConnectFuture, connectionDoneContent,
                  isCostumise: true,
                  connectionWaitActiveWidget: SplashScreen()))),
    );
  }
}

class MustUpgradeScreen extends StatelessWidget {
  final String minVer;
  final String currVer;
  const MustUpgradeScreen(
      {Key? key, required this.minVer, required this.currVer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var CenteredText = (
            [String txt = "",
            bool alignToCenter = true,
            bool newLine = true]) =>
        Center(
            child: Text(
          txt + (newLine ? "\n" : ""),
          textAlign: alignToCenter ? TextAlign.center : TextAlign.right,
        ));
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Icon(Icons.update)),
          CenteredText(),
          CenteredText("יש לעדכן את גרסת חברותא+ מהגרסא הנוכחית", false),
          CenteredText(currVer),
          CenteredText("לכל הפחות לגרסא", false),
          CenteredText(minVer),
        ],
      ),
    );
  }
}
