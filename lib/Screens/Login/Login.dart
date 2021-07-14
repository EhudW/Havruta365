import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/google_sign_in.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/Login/LoginDetails.dart';

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
                height: 250,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: -70,
                      height: 300,
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
                          child: Image.network(
                            'https://breastfeedinglaw.com/wp-content/uploads/2020/06/book.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
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
                          style: GoogleFonts.alef(fontSize: 30),
                        )),
                    SizedBox(
                      height: 30,
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
                                        bottom:
                                            BorderSide(color: Colors.grey[200]))),
                                child: TextField(
                                    controller: mail,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "שם משתמש",
                                        hintStyle: TextStyle(color: Colors.grey)),
                                    onChanged: (String text) {
                                      mail_str = mail.text;
                                    }),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                    obscureText:  true,
                                    controller: password,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "סיסמא",
                                        hintStyle: TextStyle(color: Colors.grey)),
                                    onChanged: (String text) {
                                      password_str = password.text;
                                    }),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FadeAnimation(
                        1.9,
                        Container(
                          height: 50,
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
                          child: OutlineButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            onPressed: () async {
                              var res = await Globals.db.checkNewUser(mail_str);
                              print(res);
                              // User not exist
                              if (res == 'User not exist!') {
                                Flushbar(
                                  title: 'שגיאה בהתחברות',
                                  message: 'משתמש לא קיים',
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              } else {
                                // Update current user
                                Globals.currentUser = res;
                                // Go to HomePage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );
                              }
                            },
                            child: Center(
                              child: Text(
                                "כניסה",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    FadeAnimation(
                        1.9,
                        OutlineButton(
                          splashColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          highlightElevation: 0,
                          borderSide: BorderSide(color: Colors.grey),
                          onPressed: () {
                            GoogleLogIn g = new GoogleLogIn();
                            g.login();
                            Navigator.of(context).pushNamed('/homeScreen');
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                      height: 25,
                    ),
                    FadeAnimation(
                        2,
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginDetails()),
                            );
                          },
                          child: Center(
                              child: Text(
                            "משתמש חדש",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          )),
                        )),
                    SizedBox(
                      height: 20,
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
}
