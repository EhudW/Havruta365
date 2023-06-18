import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:havruta_project/auth/screens/recover_password/forgot_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/auth/functions/google_sign_in.dart';
import 'package:havruta_project/auth/screens/sign_up/create_user_auth_screen.dart';
import 'package:havruta_project/auth/screens/sign_up/create_user_screen.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/home_page.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../Globals.dart';
import 'package:havruta_project/auth/widgets/fade_animation.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

// Screen to login or sign-up or forget password
// for now only login/signup using google is shown when !kDebugMode
// if login using google and the user isn't exist, it will count as signup using google
// flows:
// signup using google steps:      LoginScreen > CreateUserAuthScreen > SignUpFurtherDetails > HomePage
// signup using email-pass steps:  LoginScreen > CreateUserScreen > SignUpFurtherDetails > HomePage
// login using google or email-pass : LoginScreen > HomePage
// reset password : LoginScreen > ForgotPasswordScreen > ChangePasswordScreen > LoginScreen
class LoginScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<LoginScreen> {
  final mail = TextEditingController();
  String mailStr = "";
  final password = TextEditingController();
  String passwordStr = "";
  Future<SharedPreferences> _prefs = Globals.prefs;

  @override
  Widget build(BuildContext context) {
    final bool showRegularMailPassSignin = kDebugMode;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: Globals.scaler.getHeight(13),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: -70,
                      height: Globals.scaler.getHeight(16),
                      width: width,
                      child: FadeAnimation(
                        1,
                        Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                      NetworkImage(MyConsts.LOGIN_SCREEN_IMG)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(50),
                                  blurRadius: 5,
                                  offset: Offset(0, 10),
                                )
                              ]),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: Globals.scaler.getHeight(1),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FadeAnimation(
                          1.5,
                          Text(
                            "פרוייקט חברותא+",
                            textDirection: ui.TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.alef(
                                fontSize: Globals.scaler.getTextSize(10)),
                          )),
                      !showRegularMailPassSignin
                          ? SizedBox()
                          : SizedBox(
                              height: Globals.scaler.getHeight(1),
                            ),
                      !showRegularMailPassSignin
                          ? SizedBox()
                          : FadeAnimation(
                              1.7,
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal,
                                        blurRadius: 10,
                                        offset: Offset(0, 10),
                                      )
                                    ]),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]!))),
                                      child: TextField(
                                          controller: mail,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "כתובת המייל",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey)),
                                          onChanged: (String text) {
                                            mailStr = mail.text;
                                          }),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: TextField(
                                          obscureText: true,
                                          controller: password,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "סיסמא",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey)),
                                          onChanged: (String text) {
                                            passwordStr = password.text;
                                          }),
                                    ),
                                  ],
                                ),
                              )),
                      !showRegularMailPassSignin
                          ? SizedBox()
                          : SizedBox(
                              height: Globals.scaler.getHeight(2),
                            ),
                      !showRegularMailPassSignin
                          ? SizedBox()
                          : FadeAnimation(
                              1.9,
                              Container(
                                height: Globals.scaler.getHeight(2.5),
                                width: Globals.scaler.getWidth(19),
                                margin: EdgeInsets.symmetric(horizontal: 60),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 10,
                                      offset: Offset(0, 10),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.red,
                                ),
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    // try to get user with the hash(pass)
                                    var coll =
                                        Globals.db!.db.collection('Users');
                                    var bytes = utf8.encode(passwordStr);
                                    passwordStr =
                                        sha1.convert(bytes).toString();
                                    var userJson = await coll.findOne({
                                      'email': mailStr.replaceAll(
                                          new RegExp(r"\s+"), ""),
                                      'password': passwordStr
                                    });
                                    // no user or wrong pass
                                    if (userJson == null) {
                                      Flushbar(
                                        title: 'שגיאה בהתחברות',
                                        message: 'פרטי התחברות אינם נכונים',
                                        duration: Duration(seconds: 3),
                                      )..show(context);
                                      return;
                                    }
                                    Globals.onNewLogin(User.fromJson(userJson));
                                    // This is ObjectID!!
                                    var id = userJson['_id'];
                                    final SharedPreferences prefs =
                                        await _prefs;
                                    await prefs.setString('id', id.toString());
                                    // Go to HomePage
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      "כניסה",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              )),
                      SizedBox(
                        height: Globals.scaler
                            .getHeight(!showRegularMailPassSignin ? 6 : 1),
                      ),
                      FadeAnimation(
                          1.9,
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              // not suppurted:  splashColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              elevation: 0,
                              side: BorderSide(color: Colors.grey),
                            ),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              signIn();
                            },
                            child: Container(
                              height: Globals.scaler.getHeight(2.5),
                              width: Globals.scaler.getWidth(16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                      image: NetworkImage(
                                          "https://assets.materialup.com/uploads/82eae29e-33b7-4ff7-be10-df432402b2b6/preview"),
                                      width: 30,
                                      height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                      !showRegularMailPassSignin
                          ? SizedBox()
                          : SizedBox(
                              height: Globals.scaler.getHeight(1),
                            ),
                      !showRegularMailPassSignin
                          ? SizedBox()
                          : FadeAnimation(
                              2,
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateUserScreen()),
                                        );
                                      },
                                      child: Center(
                                          child: Text(
                                        "משתמש חדש",
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize:
                                                Globals.scaler.getTextSize(7)),
                                      )),
                                    ),
                                    SizedBox(
                                      width: Globals.scaler.getWidth(3),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPasswordScreen()),
                                        );
                                      },
                                      child: Center(
                                          child: Text(
                                        "שכחתי סיסמא",
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize:
                                                Globals.scaler.getTextSize(7)),
                                      )),
                                    )
                                  ])),
                      SizedBox(
                        height: Globals.scaler.getHeight(1),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Try to connect via Google_Sign_In
  // in app logic terms = login / signup with the given email
  Future signIn() async {
    try {
      await GoogleSignInApi.logout();
    } catch (e) {}
    final googleUser = await GoogleSignInApi.login();
    if (googleUser == null) {
      // on error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('התחברות נכשלה')));
    } else {
      User? user = await Globals.db!.getUser(googleUser.email);
      if (user != null) {
        // if user exist = login --> HomePage
        Globals.onNewLogin(user);
        // Save a token in user device         X
        // Save the email info in user device  V
        Globals.db!.saveIdLocally();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        // New user = signup --> CreateUserAuthScreen
        User user = new User();
        user.avatar = googleUser.photoUrl;
        user.name = googleUser.displayName;
        user.email = googleUser.email;
        // Globals.tmpNextUser keep data between step 1[CreateUserAuthScreen] [this is step 0]
        // & step 2 of the sign up process
        Globals.tmpNextUser = user;
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreateUserAuthScreen()));
      }
    }
  }
}
