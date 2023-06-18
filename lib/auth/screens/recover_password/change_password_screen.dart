import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/auth/screens/login_screen.dart';
import '../../../globals.dart';
import 'package:havruta_project/auth/widgets/fade_animation.dart';
import 'package:flutter/material.dart';

// Screen to change password, using code from user's email
class ChangePasswordScreen extends StatefulWidget {
  final String code;
  final String mail;

  ChangePasswordScreen(this.code, this.mail);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ChangePasswordScreen> {
  final code = TextEditingController();
  String codeStr = "";
  final password = TextEditingController();
  String passwordStr = "";
  final passwordCon = TextEditingController();
  String passwordConStr = "";

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
            newFiled(
                code, codeStr, "הקוד שנשלח למייל", FontAwesomeIcons.code, true),
            newFiled(password, passwordStr, "סיסמא חדשה", FontAwesomeIcons.key,
                true),
            newFiled(passwordCon, passwordConStr, "אישור סיסמא",
                FontAwesomeIcons.check, true),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "שנה את הסיסמא",
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
                  backgroundColor: Colors.red,
                  // <-- Button color
                  foregroundColor: Colors.red),
              onPressed: () async {
                codeStr = code.text;
                passwordStr = password.text;
                passwordConStr = passwordCon.text;
                if (codeStr != this.widget.code) {
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
                if (passwordStr.length < 6) {
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
                if (passwordStr != passwordConStr) {
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
                Globals.db!.changePasswordUser(this.widget.mail, passwordStr);
                Flushbar(
                  title: 'בוצע החלפת סיסמא',
                  messageText: Text('הסיסמא שונתה בהצלחה !',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.teal[400], fontSize: 20)),
                  duration: Duration(seconds: 3),
                )..show(context);
                Future.delayed(Duration(seconds: 3), () {
                  setState(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
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

// format row of TextBox & label & icon
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
