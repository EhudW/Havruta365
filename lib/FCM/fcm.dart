// based on https://github.com/firebase/flutterfire/blob/master/LICENSE
import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:havruta_project/FCM/token_monitor.dart';
import 'package:havruta_project/Globals.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../DataBase_auth/mongo.dart';

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
  if (message.data["avoidMyself"] == Globals.currentUser!.email) return;
  String title = message.data["title"] ?? "";
  String body = message.data["body"] ?? "";
  String mgt = message.data["msgGroupType"] ?? "";
  String sender = message.data["sender"] ?? "";
  String link = message.data["link"] ?? "";
  if (!{"events", "msgs", "notis"}.contains(mgt)) return;
  //spm > spmanger_firebaseMsg > mgt > counter
  //spm > spmanger_firebaseMsg > mgt  > senders > e@e.e
  var spm = SPManager("firebaseMsg");
  await spm.load();
  spm[mgt] = spm[mgt] ?? {"counter": 0, "senders": {}};
  spm[mgt]["counter"] = (spm[mgt]["counter"] ?? 0) + 1;
  spm[mgt]["senders"] = spm[mgt]["senders"] ?? {};
  spm[mgt]["senders"][sender] = true;
  await spm.save();

  await FCM.init();
  FCM.showFCM(mgt, spm[mgt]["counter"], title, body, spm[mgt]["senders"], link);
}

class FCM {
  static reset(String mgt) async {
    if (!{"events", "msgs", "notis"}.contains(mgt)) return;
    var spm = SPManager("firebaseMsg");
    await spm.load();
    spm[mgt] = {"counter": 0, "senders": {}};
    await spm.save();
    await FCM.init();
    flutterLocalNotificationsPlugin.cancel(mgt.hashCode);
  }

  static resetTo(
      String mgt, int counter, String title, String body, String link,
      [List<String> senders = const []]) async {
    if (counter == 0) return reset(mgt);
    if (!{"events", "msgs", "notis"}.contains(mgt)) return;
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
    FCM.showFCM(
        mgt, spm[mgt]["counter"], title, body, spm[mgt]["senders"], link);
  }

  static showFCM(String mgt, int counter, String? title, String body,
      Map senders, String payload) {
    switch (mgt) {
      case "events":
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

    _showFCM(mgt.hashCode, title, body, payload);
  }

  static void _clearAll() => !_isFlutterLocalNotificationsInitialized
      ? null
      : flutterLocalNotificationsPlugin.cancelAll();

  static void onLogin() async {
    _clearAll();
    sub();
  }

  static void onLogout() async {
    unsub();
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
            _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payloadForTap);
  }

  static StreamSubscription<RemoteMessage>? _subs;

  static Future Function(String payload) onMessageTap = (e) async {
    print("object\n\n\n\n\n\n\n\n$e\n\n\n\n\nobject");
    // TODO should be converted to navigator.pushroute && be checked for terminated state
  };
  static Future<dynamic> checkInitMsg(String? payload) async {
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
      topic = Mongo.topicReplace(topic);
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
        onSelectNotification: checkInitMsg);

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
