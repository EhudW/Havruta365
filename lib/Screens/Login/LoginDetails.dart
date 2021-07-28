import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/Login/LoginMoreDetails.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:gender_picker/source/gender_picker.dart';

import '../../Globals.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class LoginDetails extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<LoginDetails> {
  final name = TextEditingController();
  String name_str = "";
  final mail = TextEditingController();
  String mail_str = "";
  final password = TextEditingController();
  String password_str = "";
  final password_con = TextEditingController();
  String password_con_str = "";
  final user_name = TextEditingController();
  String user_name_str = "";
  final address = TextEditingController();
  String address_str = "";
  final gender = TextEditingController();
  String gender_str = "";

  DateTime _dateTime;

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
                child:Text("פרטים אישיים   " ,style: GoogleFonts.alef(
                fontSize: 18,
                color: Colors.teal[400]),
    )),
            genderField(gender),
            SizedBox(height: Globals.scaler.getHeight(1)),
            Container(
              height: 60,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime(1969, 1, 1),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  _dateTime = newDateTime;
                },
              ),
            ),
            newFiled(name, name_str, "שם פרטי ושם משפחה", FontAwesomeIcons.user,
                false),
            newFiled(address, address_str, "כתובת מגורים",
                FontAwesomeIcons.home, false),
            newFiled(mail, mail_str, "כתובת המייל", FontAwesomeIcons.mailBulk,
                false),
            SizedBox(height: Globals.scaler.getHeight(1)),
            Align(
                alignment: Alignment.centerRight,
                child:Text("פרטי משתמש   " ,style: GoogleFonts.alef(
                    fontSize: 18,
                    color: Colors.teal[400]),
                )),
            newFiled(
                password, password_str, "סיסמא", FontAwesomeIcons.key, true),
            newFiled(password_con, password_con_str, "אישור סיסמא",
                FontAwesomeIcons.check, true),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "תרשום אותי",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(fontSize: 23, color: Colors.white),
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
                  onPrimary: Colors.teal),
              onPressed: () async {
                gender.text == 'Gender.Female' ? gender_str = 'F' : gender_str = 'M';
                if (_dateTime == null) {
                  _dateTime = DateTime.now();
                }
                ;
                user_name_str = user_name.text;
                address_str = address.text;
                name_str = name.text;
                password_str = password.text;
                password_con_str = password_con.text;
                mail_str = mail.text;
                if (password_con_str.isEmpty ||
                    password_con_str == null ||
                    password_str.isEmpty ||
                    password_str == null ||
                    mail_str.isEmpty ||
                    mail_str == null ||
                    address_str.isEmpty ||
                    address_str == null ||
                    user_name_str.isEmpty ||
                    user_name_str == null ||
                    name_str.isEmpty ||
                    name_str == null) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('ודא שמילאת את כל השדות',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                // Check if the passwords are equals
                if (password_str != password_con_str) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('סיסמאות לא תואמות',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                bool userExist = await Globals.db.isUserExist(mail_str);
                if (userExist) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('קיים חשבון עבור מייל זה',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                User user = new User();
                user.address = address_str;
                user.email = mail_str;
                user.name = name_str;
                user.gender = gender_str;
                user.birthDate = _dateTime;
                user.password = password_str;
                Globals.currentUser = user;
                var res = Globals.db.insertNewUser(user);
                print("Registration Succeeded");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginMoreDetails()),
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
              print(text);
            }),
      ),
    ),
  ]));
}

Widget genderField(gender_str) {
  return Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
    SizedBox(width: Globals.scaler.getWidth(4)),
    Expanded(
      child: GenderPickerWithImage(
        maleText: 'גבר',
        femaleText: 'אישה',
        maleImage: NetworkImage(
            'https://image.flaticon.com/icons/png/512/180/180644.png'),
        femaleImage: NetworkImage(
            'https://image.flaticon.com/icons/png/512/180/180678.png'),
        verticalAlignedText: true,
        selectedGenderTextStyle:
            TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 20),
        unSelectedGenderTextStyle:
            TextStyle(color: Colors.teal, fontWeight: FontWeight.normal),
        onChanged: (Gender gender) {
          gender_str.text = gender.toString();
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

button(name_str) {
  return OutlineButton(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    onPressed: () async {
      print(name_str);
    },
    child: Center(
      child: Text(
        "כניסה",
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    ),
  );
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
          Icon(FontAwesomeIcons.userAlt, size: 20, color: Colors.teal[400])
        ]),
      ));
}
