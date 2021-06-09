import 'package:google_sign_in/google_sign_in.dart';
import 'package:havruta_project/DataBase_auth/google_sign_in.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';

class GoogleLogIn {
  bool _isLoggedIn = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  void login() async {
    try {
      await _googleSignIn.signIn();
      _isLoggedIn = true;
      Mongo m = new Mongo();
      m.connectGoogle(_googleSignIn.currentUser.displayName,
          _googleSignIn.currentUser.email);
    } catch (err) {
      print(err);
    }
  }

  void logOut() {
    _googleSignIn.signOut();
    _isLoggedIn = false;
  }
}
