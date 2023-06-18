// based on https://github.com/firebase/flutterfire/blob/master/LICENSE
import 'dart:async';
import 'dart:convert';

import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/chat/screens/chats_feed_screen.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:havruta_project/globals.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:havruta_project/event/screens/event_page/event_screen.dart';
import 'package:havruta_project/home_page.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/notifications/push_notifications/token_monitor.dart';

import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _emptyFunction(RemoteMessage message) async {}

///class to store / load data from local phone storage
class SPManager {
  late String _topic;
  SPManager(String topic) {
    _topic = "SPManager_$topic";
  }

  /// Add [reload] to have instance updated with Isolate
  Future load() async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.reload();
    data = jsonDecode(instance.getString(_topic) ?? "{}");
  }

  Future save() async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.setString(_topic, jsonEncode(data!));
  }

  Map? data;
  dynamic operator [](dynamic k) {
    return data![k];
  }

  void operator []=(dynamic k, dynamic v) {
    data![k] = v;
  }
}

// on server should check that link is valid one?
@pragma('vm:entry-point')
Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
  String title = message.data["title"] ?? "";
  String body = message.data["body"] ?? "";
  String mgt = message.data["msgGroupType"] ?? "";
  String sender = message.data["sender"] ?? "";
  sender = sender == "" ? "NONE" : sender;
  // FCM.init(); //DEBUG
  // FCM._showFCM(1222, title + "|" + sender, body, ""); //DEBUG
  String notitype = message.data["notitype"] ?? "NONE";
  String link = message.data["link"] ?? "";
  if (!{"events", "msgs", "notis"}.contains(mgt)) return;
  var spm = SPManager("preventDoubleFcmGms");
  await spm.load();
  if (spm[message.messageId] == true) return;
  spm[message.messageId] = true;
  await spm.save();

  var func = () async {
    //spm > spmanger_firebaseMsg > mgt > counter
    //spm > spmanger_firebaseMsg > mgt  > senders > e@e.e
    var spm = SPManager("firebaseMsg");
    await spm.load();
    if (message.data["avoidMyself"] == spm["email"]) return;
    if (mgt == "events") {
      spm['ignoreNextNotis'] = spm['ignoreNextNotis'] ?? {};
      bool ignoreme = (spm['ignoreNextNotis'][sender] ?? false);
      if (ignoreme) return;
    }
    if (mgt == "notis" && notitype != "NONE") {
      spm['ignoreNextNotis'] = spm['ignoreNextNotis'] ?? {};
      bool ignoreme = (spm['ignoreNextNotis'][sender] ?? false);
      bool ignorenext = ignoreme;
      switch (notitype) {
        case "eventDeleted":
        case "joinReject":
        case "eventUpdated:rejected":
          ignorenext = true;
          ignoreme = false;
          break;
        case "joinAccept":
          ignoreme = false;
          ignorenext = false;
          break;
        case "join":
        case "joinRequest":
          ignoreme = false;
          ignorenext = false;
          break;
        case "eventUpdated":
          ignoreme = ignoreme;
          ignorenext = ignorenext;
          break;
        //case "NONE":
        default:
          break;
      }
      spm['ignoreNextNotis'][sender] = ignorenext;

      if (ignoreme) return await spm.save();
    }
    spm[mgt] = spm[mgt] ?? {"counter": 0, "senders": {}};
    spm[mgt]["counter"] = (spm[mgt]["counter"] ?? 0) + 1;
    spm[mgt]["senders"] = spm[mgt]["senders"] ?? {};
    spm[mgt]["senders"][sender] = true;
    await spm.save();

    await FCM.init();
    //FCM._showFCM(1422, title + "|" + JsonEncoder().convert(spm[mgt]["senders"]),
    //    body, ""); //DEBUG
    if (spm[mgt]["senders"].length > 1 && mgt == 'msgs') link = 'msgs';
    FCM.showFCM(
        mgt, spm[mgt]["counter"], title, body, spm[mgt]["senders"], link);
  };
  FCM.tag_applyIfInactive(
      "afi$mgt",
      MyConsts.checkNewMessageOutsideChatSec * 1000 + 2000,
      func); //avoidForegroundInteruption
}

class FCM {
  static Future resetIgnore(List<dynamic> topics) async {
    var spm = SPManager("firebaseMsg");
    await spm.load();
    spm['ignoreNextNotis'] = spm['ignoreNextNotis'] ?? {};
    for (String t in topics) spm['ignoreNextNotis'][t] = false;
    await spm.save();
  }

  static Future tag_applyIfInactive(
      String subject, int nextMilSecInactive, Function func,
      [bool tryAgain = true]) async {
    var spm = SPManager("fcm_tag$subject");
    await spm.load();
    int lastActive = spm["lastActive"] ?? 0;
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now > lastActive + nextMilSecInactive)
      func();
    else if (tryAgain) {
      await Future.delayed(Duration(milliseconds: nextMilSecInactive));
      await tag_applyIfInactive(subject, nextMilSecInactive, func, false);
    }
  }

  static Future tag_setActiveNow(String subject) async {
    var spm = SPManager("fcm_tag$subject");
    await spm.load();
    int now = DateTime.now().millisecondsSinceEpoch;
    spm["lastActive"] = now;
    await spm.save();
  }

  static reset(String mgt) async {
    if (!{"events", "msgs", "notis"}.contains(mgt)) return;
    if (mgt == "msgs") {
      var spm = SPManager("preventDoubleFcmGms");
      await spm.load();
      spm.data = {};
      await spm.save();
    }
    await tag_setActiveNow("afi$mgt");
    var spm = SPManager("firebaseMsg");
    await spm.load();
    spm[mgt] = {"counter": 0, "senders": {}};
    await spm.save();
    await FCM.init();
    flutterLocalNotificationsPlugin.cancel(lastMgtFcmNotificationId[mgt] ?? 0);
  }

  static resetTo(
      String mgt, int counter, String title, String body, String link,
      [List<String> senders = const []]) async {
    if (counter == 0) return reset(mgt);
    if (!{"events", "msgs", "notis"}.contains(mgt)) return;
    /*if (senders.isNotEmpty) {
      await FCM.init();
      FCM._showFCM(1223, title + "|" + senders.first, body, ""); //DEBUG
    }*/
    await tag_setActiveNow("afi$mgt");
    //spm > spmanger_firebaseMsg > mgt > counter
    //spm > spmanger_firebaseMsg > mgt  > senders > e@e.e
    var spm = SPManager("firebaseMsg");
    await spm.load();
    Set x = (spm[mgt]?["senders"] ?? {}).keys.toSet();
    if ((spm[mgt]?["counter"] ?? 0) == counter && // same counter
            x.length == senders.length && // same size
            x.union(senders.toSet()).length ==
                x.length //union not affect -> same
        ) return;
    spm[mgt] = {"counter": counter, "senders": Map.fromIterable(senders)};
    await spm.save();

    await FCM.init();
    if (senders.length > 1 && mgt == 'msgs') link = 'msgs';
    FCM.showFCM(
        mgt, spm[mgt]["counter"], title, body, spm[mgt]["senders"], link);
  }

  static showFCM(String mgt, int counter, String? title, String body,
      Map senders, String payload) {
    switch (mgt) {
      case "events":
        int? n = int.tryParse(body);
        if (n == null) return;
        DateTime startD = DateTime.fromMillisecondsSinceEpoch(n);
        if (DateTime.now().isAfter(startD.add(Duration(minutes: 5)))) return;
        String start = DateTimeFormat.format(startD.toLocal(), format: "H:i");
        start = "התחלה ב $start";
        String shortStr = title ?? "יש לך שיעור";
        body = start;
        title = shortStr;
        break;
      case "notis":
        body = counter == 1 ? body : "יש לך $counter התראות";
        title = counter == 1 ? title : null;
        break;
      case "msgs":
        int x = senders.length;
        body = counter == 1 ? body : "$counter הודעות שלא נקראו ב$x שיחות";
        title = counter == 1 ? title : null;
        break;
      default:
        return;
    }
    flutterLocalNotificationsPlugin.cancel(lastMgtFcmNotificationId[mgt] ?? 0);
    lastMgtFcmNotificationId[mgt] =
        DateTime.now().millisecondsSinceEpoch.toSigned(32);
    _showFCM(lastMgtFcmNotificationId[mgt]!, title, body, payload);
  }

  static Map<String, int> lastMgtFcmNotificationId = {};
  static void _clearAll() => !_isFlutterLocalNotificationsInitialized
      ? null
      : flutterLocalNotificationsPlugin.cancelAll();

  static void onLogin() async {
    _clearAll();
    var spm = SPManager("firebaseMsg");
    await spm.load();
    spm['email'] = Globals.currentUser!.email;
    await spm.save();
    sub();
  }

  static Future onLogout() async {
    await unsub();
    var spm = SPManager("firebaseMsg");
    await spm.load();
    spm['email'] = null;
    await spm.save();
    _clearAll();
  }

  // show the notification right now;
  static void _showFCM(
      int id, String? title, String? body, String payloadForTap) {
    flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payloadForTap);
  }

  static StreamSubscription<RemoteMessage>? _subs;
// myUser is null / false / ""   >  no matter the current login state
  // myUser is true   >  need to be login to some user
  // myUser is "mail@gmail.com"   >  need to be login to specific user
  // retry = true so it will wait until login in order to move to page,
  // for now it's false since it's done in main.dart
  // (only then the parse will happen or it will happen twice: ontap on fcm notification && on main.dart)
  static Future push(myUser, builder, [bool retry = true]) async {
    bool condition1 = myUser != null && myUser != false && myUser != "";
    bool condition2 = myUser == true && Globals.currentUser == null;
    bool condition3 = myUser != true && myUser != Globals.currentUser;
    bool problem = condition1 && (condition2 || condition3);
    if (problem && !retry) return;
    if (problem && retry) {
      await Future.delayed(Duration(seconds: 1));
      return push(myUser, builder, retry);
    }
    var state = Globals.navKey.currentState;
    if (state != null) {
      state.push(MaterialPageRoute(builder: builder));
    } else {
      await Future.delayed(Duration(seconds: 1));
      return push(myUser, builder, retry);
    }
  }

  static Future onMessageTap(String payload) async {
    // e = "msgs" v
    //payload = "msg::::e2@e.e::::חשבון פיתוח";
    //payload =
    //    "msg::::ObjectId(\"64208b342fb621f911f3aa52\")::::שיעור בנביאים בשמואל ב::::forum";
    //payload = "event::::ObjectId(\"64208b342fb621f911f3aa52\")";
    // payload = "notis";
    List<String> parts = payload.split("::::");

    switch (parts.first) {
      case "msgs":
        push(true, (context) => ChatsFeedScreen());
        break;
      case "msg":
        push(
            true,
            (context) => SingleChatScreen(
                  otherPerson: parts[1],
                  otherPersonName: parts[2],
                  forumName: parts.length == 3 ? null : parts[2],
                ));
        break;
      case "event":
        push(true, (context) => EventScreen.fromString(parts[1]));
        break;
      case "notis":
        push(
            true,
            (context) => HomePage(
                //openNotificationOnStart: false, // to avoid inf loop
                ));
        break;
      default:
        break;
    }
  }

  static Set<int?> ignoreNR = Set<int?>();
  static Future<dynamic> checkInitMsg([NotificationResponse? r]) async {
    await FCM.init();
    r = r ??
        (await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails())
            ?.notificationResponse;
    if (ignoreNR.contains(r?.id)) r = null;
    ignoreNR.add(r?.id);
    String? payload = r?.payload;
    payload = payload ?? Globals.launchLink;
    Globals.launchLink = null;
    //await _setupFlutterNotifications();
    // var m =
    //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    // if (m?.payload != null && m!.didNotificationLaunchApp)
    //   onMessageTap(m.payload!);
    if (payload != null && payload != "") onMessageTap(payload);
  }

  static List _lastTopics = [];
// subscribe to my topics, in-app && background
// TODO handle special chars in topics
// TODO currUser.getMySubscriptions
  static Future _setHandler(bool subMyTopics) async {
    Future<void> Function(RemoteMessage) handler =
        subMyTopics ? _firebaseMessagingHandler : _emptyFunction;
    FirebaseMessaging.onBackgroundMessage(handler);
    await _setupFlutterNotifications();
    _subs?.onData(handler);

    if (_subs == null) {
      _subs = FirebaseMessaging.onMessage.listen(handler);
    }

    var myTopics = subMyTopics
        ? Globals.currentUser!.subs_topics.keys.toList()
        : List.of(_lastTopics);
    for (String topic in myTopics) {
      topic = MongoCommands.topicReplace(topic);
      if (subMyTopics) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        _lastTopics.add(topic);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        _lastTopics.remove(topic);
      }
    }
  }

  static Future init() => _setupFlutterNotifications();
  static Future sub() async {
    // TODO ? need
    TokenMonitor.onLogin();
    _setHandler(true);
  }

  static Future unsub() => _setHandler(false);

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel _channel;

  static bool _isFlutterLocalNotificationsInitialized = false;

  static Future<void> _setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }
    await Firebase.initializeApp();
    _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title

      description:
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
    flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onDidReceiveNotificationResponse: checkInitMsg);

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

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
}
