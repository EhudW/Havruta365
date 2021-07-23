import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {

  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount> login() => _googleSignIn.signIn();

  static Future logout() {
    try {
      return _googleSignIn.disconnect();
    } on Exception catch (e) {
      print("No Google Account $e");
      // throw Exception("Error on server");
    }
  }

  static Future getGoogleCurrentUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    return user;
  }

}


