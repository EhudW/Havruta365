import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DataBase_auth/User.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:havruta_project/main.dart';
import 'dart:async';

class Globals {
  static NewNotificationManager nnim = NewNotificationManager();
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

class MyTimer {
  bool _stop = false;
  Timer? timer;
  int duration;
  int timeout;
  int fails = 0;
  int? failAttempts;
  AsyncCallback? onFail;
  AsyncCallback? onTimeout;
  AsyncValueGetter<bool> function; // true on success; false on error;
  MyTimer({
    required this.duration,
    required this.function,
    this.timeout = 9999999999999,
    this.onTimeout,
    this.failAttempts,
    this.onFail,
  });
  Future<bool> start(bool beforeDuration) async {
    _stop = false;
    _setTimer(start: true);
    if (beforeDuration) {
      return function();
    }
    return true;
  }

  void cancel() {
    _stop = true;
    timer?.cancel();
    timer = null;
  }

  void _setTimer({bool start = false}) {
    if (timer == null && !start && !_stop) {
      return;
    }
    timer?.cancel();
    // set run
    timer = Timer(Duration(seconds: duration), () async {
      // wait to first: result / timeout
      var wasTimeout = false;
      var wasFail =
          await function().timeout(Duration(seconds: duration), onTimeout: () {
        wasTimeout = true;
        return false;
      }).catchError((err) => true);
      // on timeout
      if (wasTimeout && onTimeout != null) {
        await onTimeout!();
      }
      // on fail
      fails += wasFail ? 1 : 0;
      if (failAttempts != null && fails > failAttempts! && onFail != null) {
        await onFail!();
        fails = 0;
      }
      _setTimer(start: false);
    });
  }
}
