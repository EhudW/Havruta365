//import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() async =>
      await _googleSignIn.signIn();

  // static Future<GoogleSignInAccount> login() async{
  //   if (await _googleSignIn.isSignedIn()) {
  //     return _googleSignIn.currentUser;
  //   } else {
  //     return await _googleSignIn.signIn();
  //   }
  // }
  static Future isSignedIn() async => await _googleSignIn.isSignedIn();
  static currentUser() => _googleSignIn.currentUser;

  static Future logout() => _googleSignIn.disconnect();
}
