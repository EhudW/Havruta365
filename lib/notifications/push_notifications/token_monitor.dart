// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/globals.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Manages & returns the users FCM token.
class TokenMonitor {
  static String? _token;
  static User? _user;
  static Stream<String>? _tokenStream;
  static Future Function(String?)? onChange;

  static void _setToken(String? token) {
    onChange == null ? null : onChange!(token);
    return;
    if (_token == token && _user?.email == Globals.currentUser?.email) return;
    _token = token;
    _user = Globals.currentUser;
    if (_user == null) return;
    var db = Globals.db!.db as Db;
    var res = db.collection("Users").updateOne(where.eq('email', _user!.email),
        ModifierBuilder().push('fcmToken', _token));
  }

  static void _init() {
    FirebaseMessaging.instance.getToken().then(_setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream!.listen(_setToken);
  }

  static bool _wasInit = false;
  static void onLogin() {
    if (_wasInit) {
      _setToken(_token);
    } else {
      _init();
      _wasInit = true;
    }
  }
}
