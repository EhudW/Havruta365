import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/auth/screens/sign_up/sign_up_further_details.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:gender_picker/source/gender_picker.dart';
import 'package:crypto/crypto.dart';

import '../../../Globals.dart';
import 'package:havruta_project/auth/widgets/fade_animation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

// Screen for step 1 in creatrion of new user, using email-pass
class CreateUserScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<CreateUserScreen> {
  final name = TextEditingController();
  String nameStr = "";
  final mail = TextEditingController();
  String mailStr = "";
  final password = TextEditingController();
  String passwordStr = "";
  final passwordCon = TextEditingController();
  String passwordConStr = "";
  final address = TextEditingController();
  String addressStr = "";
  final gender = TextEditingController();
  String genderStr = ""; // F or M

  DateTime _dateTime = DateTime(1940, 1, 1);

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
            SizedBox(height: Globals.scaler.getHeight(1)),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "פרטים אישיים   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            genderField(gender),
            SizedBox(height: Globals.scaler.getHeight(1)),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "תאריך לידה   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(1)),
            Container(
              height: 60,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                minimumDate: DateTime(1900, 1, 1),
                initialDateTime: DateTime(1980, 1, 1),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  _dateTime = newDateTime;
                },
              ),
            ),
            SizedBox(height: Globals.scaler.getHeight(1)),
            newFiled(name, nameStr, "שם פרטי ושם משפחה", FontAwesomeIcons.user,
                false, TextDirection.rtl),
            newFiled(address, addressStr, "כתובת מגורים",
                FontAwesomeIcons.house, false, TextDirection.rtl),
            newFiled(mail, mailStr, "כתובת המייל",
                FontAwesomeIcons.envelopesBulk, false, TextDirection.ltr),
            SizedBox(height: Globals.scaler.getHeight(1)),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "אבטחה   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            newFiled(
                password, passwordStr, "סיסמא", FontAwesomeIcons.key, true),
            newFiled(passwordCon, passwordConStr, "אישור סיסמא",
                FontAwesomeIcons.check, true),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "המשך", // signup is done only in next step(screen)!
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(fontSize: 23, color: Colors.white),
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
                gender.text == 'Gender.Female'
                    ? genderStr = 'F'
                    : genderStr = 'M';

                _dateTime = DateTime.now();

                addressStr = address.text;
                nameStr = name.text;
                passwordStr = password.text;
                passwordConStr = passwordCon.text;
                mailStr = mail.text;
                if (passwordConStr.isEmpty ||
                    passwordStr.isEmpty ||
                    mailStr.isEmpty ||
                    addressStr.isEmpty ||
                    nameStr.isEmpty) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('ודא שמילאת את כל השדות',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                if (passwordStr.length < 6) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('אורך סיסמא חייב להיות לפחות 6 תווים ',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                // Check if the passwords are equals
                if (passwordStr != passwordConStr) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('סיסמאות לא תואמות',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                bool userExist = await Globals.db!.isUserExist(mailStr);
                if (userExist) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('קיים חשבון עבור מייל זה',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                User user = new User();
                user.name = nameStr;
                user.address = addressStr;
                user.email = mailStr;
                user.gender = genderStr;
                user.name = nameStr;
                user.birthDate = _dateTime;
                var bytes = utf8.encode(passwordStr);
                var digest = sha1.convert(bytes);
                // print("Digest as bytes: ${digest.bytes}");
                // print("Digest as hex string: $digest");
                user.password = digest.toString();
                //user.password = passwordStr;

                // Globals.tmpNextUser keep data between step 1 [this screen]
                // & step 2 of the sign up process
                Globals.tmpNextUser = user;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpFurtherDetails()),
                );
              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1))
          ],
        ),
      ),
    );
  }
}

// ui row for field, with textbox, text is hintText, cover is true for hide password with *
newFiled(controller, str, text, icon, cover, [TextDirection? dir]) {
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
                textDirection: dir,
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

Widget genderField(genderStr) {
  return Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
    SizedBox(width: Globals.scaler.getWidth(4)),
    Expanded(
      child: GenderPickerWithImage(
        maleText: 'גבר',
        femaleText: 'אישה',
        maleImage: NetworkImage(Globals.boyAvatar),
        //'https://image.flaticon.com/icons/png/512/180/180644.png'),
        femaleImage: NetworkImage(Globals.femaleAvatar),
        //'https://image.flaticon.com/icons/png/512/180/180678.png'),
        verticalAlignedText: true,
        selectedGenderTextStyle: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        unSelectedGenderTextStyle:
            TextStyle(color: Colors.teal, fontWeight: FontWeight.normal),
        onChanged: (Gender? gender) {
          genderStr.text = gender.toString();
        },

        equallyAligned: true,
        animationDuration: Duration(milliseconds: 300),
        isCircular: true,
        // default : true,
        opacityOfGradient: 0.4,
        padding: const EdgeInsets.all(1),
        size: 100, //default : 40
      ),
    ),
  ]);
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
            "משתמש חדש  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(
                fontWeight: FontWeight.bold,
                fontSize: Globals.scaler.getTextSize(9),
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.userLarge, size: 20, color: Colors.teal[400])
        ]),
      ));
}
