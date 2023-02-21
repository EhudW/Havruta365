import 'dart:convert';
import 'dart:math';

//import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
//import 'package:crypto/crypto.dart';

import '../../Globals.dart';
import '../../main.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'ForgetPassword1.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ForgetPassword> {
  final address = TextEditingController();
  // ignore: non_constant_identifier_names
  String address_str = "";

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
            newFiled(address, address_str, "כתובת המייל",
                FontAwesomeIcons.envelopesBulk, false),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "שנה את הסיסמא שלי",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(
                    fontSize: Globals.scaler.getTextSize(8),
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize: Size(
                      Globals.scaler.getWidth(32), Globals.scaler.getHeight(3)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(38.0),
                  ),
                  backgroundColor: Colors.teal,
                  // <-- Button color
                  foregroundColor: Colors.teal),
              onPressed: () async {
                address_str = address.text;
                if (!(address_str.contains("@") && address_str.contains("."))) {
                  Toast.show('כתובת המייל לא חוקית',
                      gravity: Toast.center, duration: 30);
                  //duration: Toast.center, gravity: 30);
                  return;
                }
                bool check = await Globals.db!.isUserExist(address_str);
                if (check == true) {
                  bool checkPass = await Globals.db!.isPassNull(address_str);
                  if (checkPass == true) {
                    var code = getRandString(6);
                    sendMail(address_str, code);
                    Toast.show('נשלח מייל לכתובת זו עם קוד לשינוי הסיסמא',
                        gravity: Toast.bottom, duration: 30);
                    //duration: Toast.bottom, gravity: 30);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ForgetPassword1(code, address_str)),
                    );
                  } else {
                    Toast.show('Google' + 'יש לשנות את הסיסמא בפרופיל ',
                        gravity: Toast.center, duration: 30);
                    //duration: Toast.CENTER, gravity: 30);
                  }
                } else {
                  Toast.show('כתובת המייל לא קיימת',
                      gravity: Toast.center, duration: 30);
                  //Toast.show('כתובת המייל לא קיימת', context,duration: Toast.CENTER,gravity: 30);
                }
              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1))
          ],
        ),
      ),
    );
  }
}

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

newFiled(controller, str, text, icon, cover) {
  return new FadeAnimation(
      1.7,
      Column(children: <Widget>[
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

sendMail(String mailUser, String code) async {
  var url = Uri.parse('http://yonatangat.pythonanywhere.com/mail');
  var x = {
    "subject": "שינוי סיסמא - פרוייקט חברותא",
    "body": "הקוד שלך לשינוי סיסמא הוא :    " + code,
    "src": "havrutaproject@gmail.com",
    "src_pass": "havruta365",
    "dst": mailUser
  };
  var response = await http.post(url,
      body: json.encode(x), headers: {'Content-Type': 'application/json'});
  myPrint('Response status: ${response.statusCode}', MyPrintType.None);
  myPrint('Response body: ${response.body}', MyPrintType.None);
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
          Icon(FontAwesomeIcons.key,
              size: Globals.scaler.getTextSize(8), color: Colors.teal[400])
        ]),
      ));
}
