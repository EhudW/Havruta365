import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:havruta_project/data_base/data_representations/chat_message.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:havruta_project/main.dart';
import 'package:havruta_project/notifications/push_notifications/fcm.dart';
import 'package:havruta_project/event/recommendation_system/example_rec_eval_usage.dart';

import 'mytimer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'dart:async';
import 'mydebug.dart' as MyDebug;

// see also mydebug.dart
class Globals {
  static const String Server = "https://adorable-crab-outfit.cyclic.app/";
  static const String ServerIcon = Server + "images/AppIcon2.png";
  static const String ServerFCM = Server + "FCM";
  static const String _ServerCampaign = Server + "campaign";
  // done via firebase dynamic links console
  // fallback url = Server+start
  static String ServerManuallyDynamicCampaign = "https://havruta.page.link/go";
  static String _ServerEventLink(Event e) =>
      "${Server}inapp/event/${e.id.$oid}";

  // https://firebase.google.com/docs/dynamic-links/create-links
  static Future<String> serverDynamicLink(String link, String description) =>
      FirebaseDynamicLinks.instance
          .buildShortLink(
            DynamicLinkParameters(
              longDynamicLink: Uri.parse(Uri.encodeFull(
                  "https://havruta.page.link/" +
                      "?st=חברותא פלוס" +
                      "&sd=$description" +
                      "&si=$ServerIcon" +
                      "&link=$link" +
                      "&ofl=$_ServerCampaign" +
                      "&afl=$_ServerCampaign" +
                      "&apn=com.havruta" +
                      "&amv=1")),
              link: Uri.parse(link),
              uriPrefix: "https://havruta.page.link/",
            ),
          )
          .then((link) => link.shortUrl.toString());
  static Future<String> ServerDynamicEventLink(Event e) =>
      serverDynamicLink(_ServerEventLink(e), e.shortStr);
  static String? launchLink;
  static bool MyAppStarted = false;
  static GlobalKey<NavigatorState> navKey = GlobalKey();
  // if using in Widget.build() then pass inbuild=true to avoid too many refresh
  static void onNewLogin(User user, {bool inbuild = false}) {
    bool same = user.email == currentUser?.email;
    // new login
    // Update current user
    Globals.currentUser = user;
    Globals.updateRec();
    // can be with old things for build() widget: msgCheckService, fcm state, notisCheckService
    if (!same || !inbuild) {
      Globals.msgWithFriends.restart([], true);
      FCM.onLogin();
      NewNotificationManager();
      NewNotificationManager.onlyLast?.start();
    }
    Future.delayed(Duration(milliseconds: 300), () => FCM.checkInitMsg());
  }

  static User? tmpNextUser; //only for tmp use in the sign-up new user
  // one time heavy calc;
  static LoadProperty<List<Event>> rec = LoadProperty(
    (setter) async {
      var top10events = await ExampleRecommendationSystem.calcAndGetTop10(
          Globals.currentUser!.email!);
      setter(top10events);
      return true;
    },
    oneLoadOnly: true,
    waitAutoStart: false,
    // this is how much to wait before each attempt , but no timeout is set
    duration: MyDebug.MyConsts.loadPropertyDelaySec,
  );
  static Function()? onUpdateRec;
  // ignore calling this function unless force==true,
  //which should be called EACH,but ONLY in Events.dart
  static void updateRec({bool force = false}) {
    if (force) {
      // second param is false, so it will wait  duration: MyDebug.MyConsts.loadPropertyDelaySec
      rec.restart([], false);
      var tmp = onUpdateRec;
      if (tmp != null) {
        tmp();
      }
    } else {
      MyDebug.myPrint(
          "updateRec() called with force=false; so the call is ignored.",
          MyDebug.MyPrintType.None);
    }
  }

  static int _msgWithFriendsUnread = 0;
  static int get msgWithFriendsUnread => _msgWithFriendsUnread;
  static set msgWithFriendsUnread(int v) {
    if (v != _msgWithFriendsUnread) {
      _msgWithFriendsUnread = v;
      if (onNewMsg != null) onNewMsg!();
    }
  }

  static Function()? onNewMsg;
  static bool get hasNewMsg => msgWithFriendsUnread != 0;
  static LoadProperty<List<MapEntry<ChatMessage, int>>> msgWithFriends =
      LoadProperty(
    (setter) async {
      //var x = await db!.getAllMyLastMessageWithEachFriend(
      var x = await db!.getAllMyLastMessageWithEachFriendAndForums(
          Globals.currentUser!.email!,
          fetchDstUserData: true);
      msgWithFriendsUnread = x.fold(0, (s, c) => s + c.value);
      // ignore all unread msg from opened chat, for fcm
      var spm = SPManager("openChat");
      String? chat;
      await spm.load();
      int now = DateTime.now().millisecondsSinceEpoch;
      int curr = spm['time'] ?? 0;
      int extra = 1000 * (MyDebug.MyConsts.checkNewMessageOutsideChatSec);
      if (curr + extra < now) {
        chat = spm['chat'];
      }
      var unreadMsgEntries =
          x.where((e) => e.value > 0 && e.key.dst_mail != chat).toList();
      var unreadSenders =
          unreadMsgEntries.map((e) => e.key.otherPersonMail).toList();
      if (unreadMsgEntries.isNotEmpty) {
        var rslt = await MongoCommands.sendMessageNodeJS(
            dry: true, message: unreadMsgEntries.first.key);
        FCM.resetTo(
            "msgs",
            unreadMsgEntries.fold(
                0, (s, c) => s + c.value), // <= msgwithFriendsUnread
            rslt['title']!,
            rslt['body'],
            rslt['link'],
            unreadSenders);
      } else
        FCM.reset("msgs");
      //hasNewMsg = x.any((element) => element.value != 0);
      setter(x);
      return true;
    },
    oneLoadOnly: false,
    waitAutoStart: false,
    // this is how much to wait before each attempt , but no timeout is set
    duration: MyDebug.MyConsts.checkNewMessageOutsideChatSec,
  );

  static MongoCommands? db;
  static bool isDbConnect = false;
  static User? currentUser;
  static BuildContext? context;
  static ScreenScaler scaler = new ScreenScaler();
  // ?????
  static CustomAppBar customAppBar = new CustomAppBar(
    gradientBegin: Colors.green,
    gradientEnd: Colors.blue,
    title: "",
  );
  static SharedPreferences? prefsReadyOrNull;
  static Future<SharedPreferences> prefs =
      SharedPreferences.getInstance().then((v) {
    prefsReadyOrNull = v;
    return v;
  });
  static const String DEFAULT_USER_AVATAR =
      "https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png";
  static String maleAvatar =
      'https://mpng.subpng.com/20180418/whw/kisspng-computer-icons-professional-clipart-5ad7f6c3aafc17.2777946215241028517004.jpg';
  static String femaleAvatar =
      'https://i.pinimg.com/originals/a6/58/32/a65832155622ac173337874f02b218fb.png';
  static String boyAvatar =
      'https://www.clipartmax.com/png/middle/258-2582267_circled-user-male-skin-type-1-2-icon-male-user-icon.png';
  static String girlAvatar =
      'https://png.pngtree.com/element_our/20190529/ourmid/pngtree-circular-pattern-user-cartoon-avatar-image_1200102.jpg';
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double _pefferedHeight = 80.0;
  final String title;
  final Color gradientBegin, gradientEnd;

  CustomAppBar(
      {required this.title,
      required this.gradientBegin,
      required this.gradientEnd});

  Widget build(BuildContext context) {
    return Container(
      height: _pefferedHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 20.0),
      decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: <Color>[gradientBegin, gradientEnd])),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          letterSpacing: 10.0,
          fontSize: 30.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(_pefferedHeight);
}
