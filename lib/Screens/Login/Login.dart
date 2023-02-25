// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:havruta_project/Screens/Login/ForgetPassword.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havruta_project/DataBase_auth/Google_sign_in.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/LoginDetails.dart';
import 'package:havruta_project/Screens/Login/LoginDetailsGmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../Globals.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class Login extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Login> {
  final mail = TextEditingController();
  String mail_str = "";
  final password = TextEditingController();
  String password_str = "";
  Future<SharedPreferences> _prefs = Globals.prefs;

  @override
  Widget build(BuildContext context) {
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
                                  image: NetworkImage(
                                      'https://breastfeedinglaw.com/wp-content/uploads/2020/06/book.jpeg')),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FadeAnimation(
                        1.5,
                        Text(
                          "פרוייקט חברותא",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alef(
                              fontSize: Globals.scaler.getTextSize(10)),
                        )),
                    SizedBox(
                      height: Globals.scaler.getHeight(1),
                    ),
                    FadeAnimation(
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
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onChanged: (String text) {
                                      mail_str = mail.text;
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
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onChanged: (String text) {
                                      password_str = password.text;
                                    }),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(
                      height: Globals.scaler.getHeight(2),
                    ),
                    FadeAnimation(
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
                              FocusScope.of(context).requestFocus(FocusNode());
                              var coll = Globals.db!.db.collection('Users');
                              var bytes = utf8.encode(password_str);
                              password_str = sha1.convert(bytes).toString();
                              var user_json = await coll.findOne({
                                'email':
                                    mail_str.replaceAll(new RegExp(r"\s+"), ""),
                                'password': password_str
                              });
                              if (user_json == null) {
                                Flushbar(
                                  title: 'שגיאה בהתחברות',
                                  message: 'פרטי התחברות אינם נכונים',
                                  duration: Duration(seconds: 3),
                                )..show(context);
                                return;
                              }
                              // Update current user
                              Globals.currentUser = User.fromJson(user_json);
                              Globals.updateRec();
                              // This is ObjectID!!
                              var id = user_json['_id'];
                              final SharedPreferences prefs = await _prefs;
                              await prefs.setString('id', id.toString());
                              // Go to HomePage
                              Navigator.push(
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
                      height: Globals.scaler.getHeight(1),
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
                    SizedBox(
                      height: Globals.scaler.getHeight(1),
                    ),
                    FadeAnimation(
                        2,
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginDetails()),
                                  );
                                },
                                child: Center(
                                    child: Text(
                                  "משתמש חדש",
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: Globals.scaler.getTextSize(7)),
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
                                        builder: (context) => ForgetPassword()),
                                  );
                                },
                                child: Center(
                                    child: Text(
                                  "שכחתי סיסמא",
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: Globals.scaler.getTextSize(7)),
                                )),
                              )
                            ])),
                    SizedBox(
                      height: Globals.scaler.getHeight(1),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    // Try to connect via Google_Sign_In
    final google_user = await GoogleSignInApi.login();
    if (google_user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('התחברות נכשלה')));
    } else {
      // if user exist --> HomePage
      bool userExist = await Globals.db!.isUserExist(google_user.email);
      if (userExist) {
        // Update current user
        Globals.currentUser = await Globals.db!.getUser(google_user.email);
        Globals.updateRec();
        // Save a token in user device
        Globals.db!.saveIdLocally();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
        // New user --> LoginDetailsGmail
      } else {
        GoogleSignInAccount g_user = google_user;
        User user = new User();
        user.avatar = g_user.photoUrl;
        user.name = g_user.displayName;
        user.email = g_user.email;
        Globals.currentUser = user;
        // TODO - GO TO NEW SCREEN - SPECIFIC FOR GOOGLE
        // TODO - JUST REMOVE EMAIL AND NAME
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginDetailsGmail()));
      }
    }
  }
}
