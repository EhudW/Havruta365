import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'FireBaseUser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create fire based user obj based on firebase user

  FireBaseUser _userFromFireBaseUser(User user) {
    return user != null ? FireBaseUser(uid: user.uid) : null;
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFireBaseUser(user);
    } catch (e) {
      return null;
    }
  }
}
