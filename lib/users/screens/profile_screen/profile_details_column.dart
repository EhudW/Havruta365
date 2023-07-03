// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/auth/functions/google_sign_in.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/users/screens/changes_details.dart';
import 'package:havruta_project/auth/screens/login_screen.dart';
import 'package:havruta_project/main.dart';
import 'package:havruta_project/notifications/push_notifications/fcm.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProfileDetailsColumn extends StatefulWidget {
  ProfileDetailsColumn(this.user);

  var user;

  @override
  _ProfileDetailsColumnState createState() => _ProfileDetailsColumnState();
}

class _ProfileDetailsColumnState extends State<ProfileDetailsColumn> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future getGoogleCurrentUser() async {
    var user = auth.currentUser!;
    if (!user.emailVerified) {
      return null;
    }
    return user;
  }

  alertMessage(String text) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "!הודעת מערכת",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      content: Text(text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget create_button_container(Text text, IconData icon) {
    var icon_size = Globals.scaler.getTextSize(11);
    return Container(
      height: Globals.scaler.getHeight(3),
      width: Globals.scaler.getWidth(26),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
              width: Globals.scaler.getWidth(0.1), color: Colors.grey[350]!),
          color: Colors.white),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Padding(padding: EdgeInsets.only(left: Globals.scaler.getWidth(0))),
        text,
        SizedBox(width: Globals.scaler.getWidth(1.5)),
        Icon(
          icon,
          size: icon_size,
          color: Colors.brown[400],
        ),
      ]),
    );
  }

  Widget createGestureButton(String text, icon, onTap,
      {shouldHaveSpaces = true}) {
    var size_header = Globals.scaler.getTextSize(8.5);
    return GestureDetector(
      onTap: onTap,
      child: create_button_container(
          Text(text,
              style: GoogleFonts.secularOne(
                  fontSize: size_header,
                  fontWeight: FontWeight.bold,
                  textStyle: shouldHaveSpaces
                      ? TextStyle(
                          color: Colors.black,
                          letterSpacing: Globals.scaler.getWidth(.5))
                      : TextStyle()),
              textDirection: TextDirection.rtl),
          icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          createGestureButton("עדכון פרטים", FontAwesomeIcons.userPen, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChangesDetails()));
          }),
          SizedBox(
            height: Globals.scaler.getHeight(0.8),
          ),
          createGestureButton("המלץ לחבר", FontAwesomeIcons.shareNodes, () {
            Share.share(
                "היי! הייתי רוצה להמליץ לך על האפליקציה חברותא+" +
                    "\n${Globals.ServerManuallyDynamicCampaign}",
                //   "\n https://play.google.com/store/apps/details?id=not.exist.yet.main",
                subject: "כדאי לך לנסות את חברותא פלוס");
          }),
          SizedBox(
            height: Globals.scaler.getHeight(0.8),
          ),
          createGestureButton("התנתק", FontAwesomeIcons.rightFromBracket,
              () async {
            // ignore: unused_local_variable
            var currentUser;
            // new logout
            Globals.currentUser = null;
            Globals.rec.cancel([]);
            Globals.msgWithFriends.cancel([]);
            NewNotificationManager.onlyLast?.cancel();
            await FCM.onLogout();
            if (await (GoogleSignInApi.isSignedIn())) {
              currentUser = GoogleSignInApi.currentUser();
              await GoogleSignInApi.logout();
            }
            final SharedPreferences prefs = await _prefs;
            await prefs.setString('id', "");
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()));
          }, shouldHaveSpaces: false),
        ]),
      ),
    );
  }
}
