import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../Globals.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'Login.dart';

class ForgetPassword1 extends StatefulWidget {

  String code;
  String mail;

  ForgetPassword1(this.code,this.mail);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ForgetPassword1> {
  final code = TextEditingController();
  String code_str = "";
  final password = TextEditingController();
  String password_str = "";
  final password_con = TextEditingController();
  String password_con_str = "";




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Globals.scaler.getHeight(4)),
            newFiled(code, code_str, "הקוד שנשלח למייל",
                FontAwesomeIcons.code, true),
            newFiled(password, password_str, "סיסמא חדשה",
                FontAwesomeIcons.key, true),
            newFiled(password_con, password_con_str, "אישור סיסמא",
                FontAwesomeIcons.check, true),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "שנה את הסיסמא",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(fontSize: Globals.scaler.getTextSize(8), color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize:
                  Size(Globals.scaler.getWidth(32), Globals.scaler.getHeight(3)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(38.0),
                  ),
                  primary: Colors.red,
                  // <-- Button color
                  onPrimary: Colors.red),
              onPressed: () async {
                code_str = code.text;
                password_str = password.text;
                password_con_str = password_con.text;
                if(code_str != this.widget.code){
                  Flushbar(
                    title: 'שגיאה בהחלפת סיסמא',
                    messageText: Text('הקוד לא תואם ',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                if (password_str.length < 6) {
                  Flushbar(
                    title: 'שגיאה בהחלפת סיסמא ',
                    messageText: Text('אורך סיסמא חייב להיות לפחות 6 תווים ',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                // Check if the passwords are equals
                if (password_str != password_con_str) {
                  Flushbar(
                    title: 'שגיאה בהחלפת סיסמא',
                    messageText: Text('סיסמאות לא תואמות',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                Globals.db!.changePasswordUser(this.widget.mail, password_str);
                Flushbar(
                  title: 'בוצע החלפת סיסמא',
                  messageText: Text('הסיסמא שונתה בהצלחה !',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: Colors.teal[400], fontSize: 20)),
                  duration: Duration(seconds: 3),
                )..show(context);
                Future.delayed(Duration(seconds: 3),()
                {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Login()),
                    );
                  });
                });
              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1))
          ],
        ),
      ),
    );
  }
}

newFiled(controller, str, text, icon, cover) {
  return new  FadeAnimation(
      1.7, Column(children: <Widget>[
    SizedBox(height: Globals.scaler.getHeight(1)),
    Center(
      child: Container(
        alignment: AlignmentDirectional.center,
        width: Globals.scaler.getWidth(32),
        height: Globals.scaler.getHeight(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(1),
                offset: const Offset(0, 2),
                blurRadius: 8.0),
          ],
        ),
        child: TextField(
            textAlign: TextAlign.center,
            controller: controller,
            obscureText: cover,
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
                suffixIcon: Icon(
                  icon,
                  size: Globals.scaler.getTextSize(8),
                  color: Colors.red,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: text),
            onChanged: (text) {
              str = controller.text;
            }),
      ),
    ),
  ]));
}


appBar(BuildContext context) {
  ScreenScaler scaler = new ScreenScaler();

  return new AppBar(
      leadingWidth: 0,
      toolbarHeight: 40,
      elevation: 30,
      shadowColor: Colors.teal[400],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(0),
      )),
      backgroundColor: Colors.white,
      title: Container(
        width: scaler.getWidth(50),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            "שחזור סיסמא  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(
                fontWeight: FontWeight.bold,
                fontSize: Globals.scaler.getTextSize(9),
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.key, size: Globals.scaler.getTextSize(8), color: Colors.teal[400])
        ]),
      ));
}
