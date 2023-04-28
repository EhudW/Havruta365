import 'package:havruta_project/FCM/fcm.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:havruta_project/rec_system.dart';

import 'DataBase_auth/Event.dart';
import 'mytimer.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DataBase_auth/User.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'dart:async';
import 'mydebug.dart' as MyDebug;

// see also mydebug.dart
class Globals {
  static void onNewLogin(User user) {
    // new login
    // Update current user
    Globals.currentUser = user;
    Globals.updateRec();
    Globals.msgWithFriends.restart([], true);
    FCM.onLogin();
  }

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
      var x = await db!.getAllMyLastMessageWithEachFriend(
          Globals.currentUser!.email!,
          fetchDstUserData: true);
      msgWithFriendsUnread = x.fold(0, (s, c) => s + c.value);
      //hasNewMsg = x.any((element) => element.value != 0);
      setter(x);
      return true;
    },
    oneLoadOnly: false,
    waitAutoStart: false,
    // this is how much to wait before each attempt , but no timeout is set
    duration: MyDebug.MyConsts.checkNewMessageOutsideChatSec,
  );

  static Mongo? db;
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
  static Future<SharedPreferences> prefs = SharedPreferences.getInstance();
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
