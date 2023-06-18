import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/auth/widgets/fade_animation.dart';
import 'package:havruta_project/auth/screens/sign_up/sign_up_further_details.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:gender_picker/source/gender_picker.dart';

import '../../../Globals.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

// Screen for step 1 in creatrion of new user, using Google auth
class CreateUserAuthScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<CreateUserAuthScreen> {
  final address = TextEditingController();
  String addressStr = "";
  final gender = TextEditingController();
  String genderStr = "";

  DateTime? _dateTime;

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
                alignment: Alignment.center,
                child: Text(
                  Globals.tmpNextUser!.email!,
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
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
            Container(
              height: 60,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime(1969, 1, 1),
                minimumDate: DateTime(1900, 1, 1),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  _dateTime = newDateTime;
                },
              ),
            ),
            newFiled(address, addressStr, "כתובת מגורים",
                FontAwesomeIcons.house, false, TextDirection.rtl),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "המשך", // sign up is done only in next screen!
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
                if (_dateTime == null) {
                  _dateTime = DateTime.now();
                }
                addressStr = address.text;
                if (addressStr.isEmpty) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('יש להכניס כתובת מגורים',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }
                // Globals.tmpNextUser keep data between step 1 [this screen]
                // & step 2 of the sign up process
                User user = Globals.tmpNextUser!;
                user.address = addressStr;
                user.gender = genderStr;
                user.birthDate = _dateTime;
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

// create new field row.  text is hint.  cover is bool if to hide with * the textbox
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
