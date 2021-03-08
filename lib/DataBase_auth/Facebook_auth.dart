import 'dart:math';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';



void facebook_login(){
  FacebookLogin fbLogin = new FacebookLogin();
  fbLogin.logIn(['email', 'public_profile']).then((result) {
    print('result is:$result');

  })
      .catchError((e) {
    print(e);
  });
}