// based on https://github.com/firebase/flutterfire/blob/master/LICENSE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/EventsSelectorBuilder.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notificationModel.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/mytimer.dart';

class FCM {
  static List<MapEntry<ChatMessage, int>> _msgs = [];
  static NotificationUser? _noti;
  static NotificationUser? get noti => _noti;
  static set noti(NotificationUser? v) {
    if (_noti?.id == v?.id) return;
    var lastId = _noti?.id;
    _noti = v;
    var currId = _noti?.id;
    _refreshUI("noti", currId, lastId);
  }

  static Event? _event;
  static Event? get event => _event;
  static set event(Event? v) {
    if (_event?.id == v?.id) return;
    var lastId = _event?.id;
    _event = v;
    var currId = _event?.id;
    _refreshUI("event", currId, lastId);
  }

  static void clearAll() => !_isFlutterLocalNotificationsInitialized
      ? null
      : flutterLocalNotificationsPlugin.cancelAll();
  static List<MapEntry<ChatMessage, int>> get msgs => _msgs;
  static set msgs(List<MapEntry<ChatMessage, int>> v) {
    if (v.isEmpty && _msgs.isEmpty) return;
    var a = _msgs.map((e) => e.key.id).toSet();
    var b = v.map((e) => e.key.id).toSet();
    if (a.length == b.length && a.intersection(b).length == a.length) return;
    var lastId = msgs.isEmpty ? null : msgs.first.key.id;
    _msgs = v;
    var currId = msgs.isEmpty ? null : msgs.first.key.id;
    _refreshUI("msgs", currId, lastId);
  }

  static Future background() async {}
  static Future foreground() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }
    await _setupFlutterNotifications();
    MyTimer(
        duration: MyConsts.checkNewMessageOutsideChatSec,
        function: () async {
          var tmp = await Globals.db!.getAllMyLastMessageWithEachFriend(
              Globals.currentUser!.email!,
              biDirectional: false,
              fetchDstUserData: true);
          msgs = tmp.where((element) => element.value != 0).toList();
          return true;
        }).start(true);
    MyTimer(
        duration: MyConsts.checkNewNotificationSec,
        function: () async {
          var l = await Globals.db!.getNotifications();
          if (l.isEmpty) {
            noti = null;
          } else if (noti == null) {
            noti = l.last;
          } else {
            var next = l.last;
            noti =
                next.creationDate!.isAfter(noti!.creationDate!) ? next : noti;
          }
          return true;
        }).start(true);
    MyTimer(
        duration: 60 * 5,
        function: () async {
          var l = await EventsSelectorBuilder.fetchFrom(
              withParticipant: Globals.currentUser!.email, maxEvents: 100);
          l.sort((a, b) => a.dates![0].compareTo(b.dates![0]));
          event = l.isNotEmpty && l.first.startIn <= 120 && l.first.startIn >= 0
              ? l.first
              : null;

          return true;
        }).start(true);
  }

  static int _lastTag = 0;
  static Map<String, int> _lastTags = {"event": 0, "msgs": 0, "noti": 0};
  static _refreshUI(String what, dynamic currId, dynamic lastId) {
    if (kIsWeb) return;
    int nowTag = DateTime.now().millisecondsSinceEpoch;
    if (nowTag - _lastTag < 1000 * 5) {
      _lastTags[what] = nowTag;
      Future.delayed(
          Duration(seconds: 5),
          () => _lastTags[what]! >
                  nowTag // ignore this request if there is future request
              ? null
              : _refreshUI(what, currId, lastId));
    }
    _lastTag = nowTag;
    flutterLocalNotificationsPlugin.cancel(lastId.hashCode);
    if (currId != null) {
      String? msgBody = null;
      String? msgTitle = null;
      if (msgs.isNotEmpty) {
        int total = msgs.fold(0, (p, e) => p + e.value);
        if (total == 1) {
          msgTitle = msgs.first.key.otherPersonName;
          msgBody = msgs.first.key.message;
        } else if (total > 0) {
          msgTitle = null;
          var x = msgs.length;
          msgBody = "$total הודעות שלא נקראו ב$x שיחות";
        }
      }
      var title = {
        "event": event?.shortStr,
        "noti": noti?.name,
        "msgs":
            msgTitle //null //msgs.isEmpty ? null : msgs.first.key.otherPersonName
      }[what];
      var time = "${event?.typeAsStr} בעוד ${event?.startIn} דקות";
      var now = "${event?.typeAsStr} חל";
      now += event?.type == 'H' ? "ה" : "";
      now += "כרגע";

      var body = {
        "event": event?.startIn == 0 ? now : time,
        "noti": noti?.message,
        "msgs": msgBody //msgs.isEmpty ? null : msgs.first.key.message
      }[what];

      _showFCM(currId, title, body);
    }
  }

  static void _showFCM(dynamic currId, String? title, String? body) {
    flutterLocalNotificationsPlugin.show(
      currId.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name, _channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          //icon: 'launch_background',
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
/*
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    await setupFlutterNotifications();
    showFlutterNotification(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
  }*/

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel _channel;

  static bool _isFlutterLocalNotificationsInitialized = false;

  static Future<void> _setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }
    _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title

      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _isFlutterLocalNotificationsInitialized = true;
  }

  /*void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            _channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
    
  }*/

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
}
