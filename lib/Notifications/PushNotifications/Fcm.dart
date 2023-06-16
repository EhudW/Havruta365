// based on https://github.com/firebase/flutterfire/blob/master/LICENSE
import 'dart:async';
import 'dart:convert';

import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:havruta_project/Notifications/PushNotifications/TokenMonitor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase/MongoCommands.dart';
import 'package:havruta_project/Event/Screens/EventPage/EventScreen.dart';
import 'package:havruta_project/Globals.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:havruta_project/HomePage.dart';
import 'package:havruta_project/Chat/Screens/SingleChatScreen.dart';
import 'package:havruta_project/Chat/Screens/ChatsFeedScreen.dart';
import 'package:havruta_project/mydebug.dart';

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
    Set x = (spm[mgt]["senders"] ?? {}).keys.toSet();
    if ((spm[mgt]["counter"] ?? 0) == counter && // same counter
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

/*@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print(
        "Native called background task: $backgroundTask"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}
@pragma('vm:entry-point')
Future<void> _emptyFunction(RemoteMessage message) async {}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var lastTag = int.tryParse(await FCM.get("FCM_Tag") ?? "0")!;
  var currTag = message.data["FCM_Tag"];
  if (lastTag > currTag) return;
  await FCM.set("FCM_Tag", currTag.toString());
  await Firebase.initializeApp();
  await FCM._setupFlutterNotifications();
  FCM._showFCM(message.data["tagName"].hashCode, message.data["title"],
      message.data["body"]);
  //showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

class FCM {
  /// Add [reload] to have instance updated with Isolate
  static Future<SharedPreferences> _getSharedPreference() async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.reload();
    return instance;
  }

  static Future<String?> get(String key) async {
    var x = await _getSharedPreference();
    return x.getString(key);
  }

  static Future set(String key, String val) async {
    var x = await _getSharedPreference();
    return x.setString(key, val);
  }

  static Future<String?> replace(String key, String val) async {
    var x = await _getSharedPreference();
    var r = await x.getString(key);
    x.setString(key, val);
    return r;
  }

  static List<MapEntry<ChatMessage, int>> _msgs = [];
  static List<NotificationUser> _notis = [];
  static List<Event> _events = [];
  static bool _sameIDLists(Iterable<dynamic> a, Iterable<dynamic> b) {
    var al = a.toList();
    var bl = b.toList();
    if (al.length != bl.length) return false;
    for (int i = 0; i < al.length; i++) {
      if (al[i] != bl[i]) return false;
    }
    return true;
  }

  static List<NotificationUser> _getLatestNotisList(
          List<NotificationUser> next) =>
      _sameIDLists(_notis.map((e) => e.id), next.map((e) => e.id))
          ? _notis
          : next;

  static List<Event> _getLatestEventsList(List<Event> next) =>
      _sameIDLists(_events.map((e) => e.id), next.map((e) => e.id))
          ? _events
          : next;

  static int _sumUnreads(List<MapEntry<ChatMessage, int>> a) {
    return a.fold(0, (p, e) => p + e.value);
  }

  static List<MapEntry<ChatMessage, int>> _getLatestMsgsList(
          List<MapEntry<ChatMessage, int>> next) =>
      _sumUnreads(_msgs) == _sumUnreads(next) &&
              _sameIDLists(
                  _msgs.map((e) => e.key.id), next.map((e) => e.key.id))
          ? _msgs
          : next;
  static void _setNotis(List<NotificationUser> next) {
    String tagName = "notis";
    if (_notis == _getLatestNotisList(next)) return;
    int? _notisSum = _notis.length != 0
        ? _notis.fold<int>(0, (p, e) => p ^ e.id.hashCode)
        : null;
    int nextSum = next.fold(0, (p, e) => p ^ e.id.hashCode);
    // logic: counter=0 none; 1 alert; 2 counter
    if (next.length == 0) {
      _notisSum == null
          ? null
          : flutterLocalNotificationsPlugin.cancel(tagName.hashCode);
      _notis = next;
      return;
    }
    var title = next.last.name;
    var body = next.last.message;
    if (next.length > 1) {
      title = null;
      body = "יש לך ${next.length} התראות";
    }
    _notis = next;
    _refreshUI(tagName, _notisSum, nextSum, title, body);
  }

  static Event? _getFirstEvent(List<Event> l) {
    l = List.of(l);
    l.sort((a, b) => a.dates![0].compareTo(b.dates![0]));
    return l.isNotEmpty && l.first.startIn <= 120 && l.first.startIn >= 0
        ? l.first
        : null;
  }

  static void _setEvents(List<Event> next) {
    String tagName = "events";
    if (_events == _getLatestEventsList(next)) return;
    int? _eventsId = _getFirstEvent(_events)?.id.hashCode;
    Event? nextFirst = _getFirstEvent(next);
    if (nextFirst == null) {
      _eventsId == null
          ? null
          : flutterLocalNotificationsPlugin.cancel(tagName.hashCode);

      _events = next;
      return;
    }
    var title = nextFirst.shortStr;
    var time = "${nextFirst.typeAsStr} בעוד ${nextFirst.startIn} דקות";
    var now = "${nextFirst.typeAsStr} חל";
    now += nextFirst.type == 'H' ? "ה" : "";
    now += "כרגע";
    var body = nextFirst.startIn == 0 ? now : time;

    _events = next;
    _refreshUI(tagName, _eventsId, nextFirst.id.hashCode, title, body);
  }

  static void _clearAll() => !_isFlutterLocalNotificationsInitialized
      ? null
      : flutterLocalNotificationsPlugin.cancelAll();

  static void _setMsgs(List<MapEntry<ChatMessage, int>> next) {
    String tagName = "msgs";
    if (_msgs == _getLatestMsgsList(next)) return;

    FCM.set("FCM_Tag", DateTime.now().millisecondsSinceEpoch.toString());

    int? _msgsSum = _msgs.length != 0
        ? _msgs.fold<int>(0, (p, e) => p ^ e.key.id.hashCode ^ e.value)
        : null;
    int nextSum = next.fold(0, (p, e) => p ^ e.key.id.hashCode ^ e.value);
    // logic: counter=0 none; 1 alert; 2 counter
    if (next.length == 0) {
      _msgsSum == null
          ? null
          : flutterLocalNotificationsPlugin.cancel(tagName.hashCode);
      _msgs = next;
      return;
    }

    String? body = null;
    String? title = null;
    if (next.isNotEmpty) {
      int total = _sumUnreads(next);
      if (total == 1) {
        title = next.first.key.otherPersonName;
        body = next.first.key.message;
      } else if (total > 0) {
        title = null;
        var x = next.length;
        body = "$total הודעות שלא נקראו ב$x שיחות";
      }
    }

    _msgs = next;
    _refreshUI(tagName, _msgsSum, nextSum, title, body);
  }

  static void onLogin() async {
    if (_isFlutterLocalNotificationsInitialized) {
      await _foreground();
    }
    await _background(true);
    _clearAll();
    _timers.forEach((t) => t.start(true));
    TokenMonitor.onLogin();
  }

  static void onLogout() async {
    await _background(false);
    _timers.forEach((t) => t.cancel());
    _clearAll();
  }

  static List<MyTimer> _timers = [];
  static Future _foreground() async {
    await _setupFlutterNotifications();
    var t1 = MyTimer(
        duration: MyConsts.checkNewMessageOutsideChatSec,
        function: () async {
          var tmp = await Globals.db!.getAllMyLastMessageWithEachFriend(
              Globals.currentUser!.email!,
              biDirectional: false,
              fetchDstUserData: true);
          var next = tmp.where((element) => element.value != 0).toList();
          _setMsgs(next);
          return true;
        });
    var t2 = MyTimer(
        duration: MyConsts.checkNewNotificationSec,
        function: () async {
          var next = await Globals.db!.getNotifications();
          _setNotis(next);
          return true;
        });
    var t3 = MyTimer(
        duration: 60 * 5,
        function: () async {
          var next = await EventsSelectorBuilder.fetchFrom(
              withParticipant: Globals.currentUser!.email, maxEvents: 100);
          _setEvents(next);
          return true;
        });
    _timers = [t1, t2, t3];
  }

  static int _lastTag = 0;
  static Map<String, int> _lastTags = {"events": 0, "msgs": 0, "notis": 0};
  // force refresh; now or in few seconds
  static _refreshUI(
      String tagName, int? currId, int nextId, String? title, String? body) {
    if (kIsWeb) return;
    int nowTag = DateTime.now().millisecondsSinceEpoch;
    if (nowTag - _lastTag < 1000 * 5) {
      _lastTags[tagName] = nowTag;
      return Future.delayed(
          Duration(seconds: 5),
          () => _lastTags[tagName]! >
                  nowTag // ignore this request if there is future request
              ? null
              : _refreshUI(tagName, currId, nextId, title, body));
    }
    // else:
    _lastTag = nowTag;
    if (nextId != currId && currId != null) {
      flutterLocalNotificationsPlugin.cancel(currId);
    }
    _showFCM(tagName.hashCode, title, body);
  }

  // show the notification right now;
  static void _showFCM(int id, String? title, String? body) {
    flutterLocalNotificationsPlugin.show(
      id,
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

  static Future _background(bool on) async {
    /*
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
      
    Workmanager().registerPeriodicTask("task-identifier", "simpleTask");*/
    if (on) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } else {
      FirebaseMessaging.onBackgroundMessage(_emptyFunction);
    }
  }

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
*/
