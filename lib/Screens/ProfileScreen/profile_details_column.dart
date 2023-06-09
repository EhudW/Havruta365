// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Google_sign_in.dart';
import 'package:havruta_project/FCM/fcm.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/Events/MyEventsPage.dart';
import 'package:havruta_project/Screens/HomePageScreen/Events/modelsHomePages.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:havruta_project/Screens/UserChanges/ChangesDetails.dart';
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
  bool _lesson_expanded = false;
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

  @override
  Widget build(BuildContext context) {
    var size_header = Globals.scaler.getTextSize(8.5);
    var icon_size = Globals.scaler.getTextSize(11);

    var create_button_container = (Text text, IconData icon) => Container(
          height: Globals.scaler.getHeight(3),
          width: Globals.scaler.getWidth(26),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                  width: Globals.scaler.getWidth(0.1),
                  color: Colors.grey[350]!),
              color: Colors.white),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: Globals.scaler.getWidth(0))),
                text,
                SizedBox(width: Globals.scaler.getWidth(1.5)),
                Icon(
                  icon,
                  size: icon_size,
                  color: Colors.brown[400],
                ),
              ]),
        );
    return Expanded(
      child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          /*GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyEventsPage(
                            title: "נרשמתי/בהמתנה ל",
                            logic: PullingLogic(
                                withParticipant: Globals.currentUser!.email,
                                createdBy: null),
                            icon: FontAwesomeIcons.handshake, //bookBookmark,
                          )));
            },
            child: Container(
              height: Globals.scaler.getHeight(3),
              width: Globals.scaler.getWidth(26),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                      width: Globals.scaler.getWidth(0.1),
                      color: Colors.grey[350]!),
                  color: Colors.white),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(left: Globals.scaler.getWidth(0))),
                    Text("נרשמתי ל...",
                        style: GoogleFonts.secularOne(
                            fontSize: size_header,
                            fontWeight: FontWeight.bold,
                            textStyle: TextStyle(
                                color: Colors.black,
                                letterSpacing: Globals.scaler.getWidth(.5))),
                        textDirection: TextDirection.rtl),
                    SizedBox(width: Globals.scaler.getWidth(1.5)),
                    Icon(
                      FontAwesomeIcons.handshake, //bookBookmark,
                      size: icon_size,
                      color: Colors.brown[400],
                    ),
                  ]),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(0.8),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyEventsPage(
                            title: "יזמתי את",
                            logic: PullingLogic(
                              withParticipant: null,
                              createdBy: Globals.currentUser!.email,
                            ),
                            icon: FontAwesomeIcons.personChalkboard,
                          )));
            },
            child: Container(
              height: Globals.scaler.getHeight(3),
              width: Globals.scaler.getWidth(26),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                      width: Globals.scaler.getWidth(0.1),
                      color: Colors.grey[350]!),
                  color: Colors.white),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(left: Globals.scaler.getWidth(0))),
                    Text("יזמתי את...",
                        style: GoogleFonts.secularOne(
                            fontSize: size_header,
                            fontWeight: FontWeight.bold,
                            textStyle: TextStyle(
                                color: Colors.black,
                                letterSpacing: Globals.scaler.getWidth(.5))),
                        textDirection: TextDirection.rtl),
                    SizedBox(width: Globals.scaler.getWidth(1.5)),
                    Icon(
                      FontAwesomeIcons.personChalkboard,
                      size: icon_size,
                      color: Colors.brown[400],
                    ),
                  ]),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(0.8),
          ),*/
          /*Container(
            margin: EdgeInsets.fromLTRB(
                Globals.scaler.getWidth(2.5),
                Globals.scaler.getHeight(0),
                Globals.scaler.getWidth(2.5),
                Globals.scaler.getHeight(0.8)),
            child: ExpansionPanelList(
              animationDuration: Duration(milliseconds: 500),
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: Globals.scaler.getWidth(2.5))),
                        Text("השיעורים שלי",
                            style: GoogleFonts.secularOne(
                                textStyle: TextStyle(
                                    color: Colors.black, letterSpacing: .5),
                                fontSize: size_header,
                                fontWeight: FontWeight.bold),
                            textDirection: TextDirection.rtl),
                        SizedBox(width: Globals.scaler.getWidth(1)),
                        Icon(
                          FontAwesomeIcons.graduationCap,
                          size: icon_size,
                          color: Colors.brown[400],
                        )
                      ],
                    );
                  },
                  body: EventsScroller(Globals.currentUser!.email),
                  isExpanded: _lesson_expanded,
                  canTapOnHeader: true,
                ),
              ],
              expansionCallback: (panelIndex, isExpanded) {
                _lesson_expanded = !_lesson_expanded;
                setState(() {});
              },
            ),
          ),*/
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChangesDetails()));
            },
            child: create_button_container(
                Text("עדכון פרטים",
                    style: GoogleFonts.secularOne(
                        fontSize: size_header,
                        fontWeight: FontWeight.bold,
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: Globals.scaler.getWidth(.5))),
                    textDirection: TextDirection.rtl),
                FontAwesomeIcons.userPen),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(0.8),
          ),
          GestureDetector(
            onTap: () {
              Share.share(
                  "היי! הייתי רוצה להמליץ לך על האפליקציה חברותא+" +
                      "\n${Globals.ServerCampaign}",
                  //   "\n https://play.google.com/store/apps/details?id=not.exist.yet.main",
                  subject: Globals.ServerCampaign);
            },
            child: create_button_container(
                Text("המלץ לחבר",
                    style: GoogleFonts.secularOne(
                        fontSize: size_header,
                        fontWeight: FontWeight.bold,
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: Globals.scaler.getWidth(.5))),
                    textDirection: TextDirection.rtl),
                FontAwesomeIcons.shareNodes),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(0.8),
          ),
          GestureDetector(
            onTap: () async {
              // ignore: unused_local_variable
              var currentUser;
              // new logout
              Globals.currentUser = null;
              Globals.rec.cancel([]);
              Globals.msgWithFriends.cancel([]);
              await FCM.onLogout();
              if (await (GoogleSignInApi.isSignedIn())) {
                currentUser = GoogleSignInApi.currentUser();
                await GoogleSignInApi.logout();
              }
              final SharedPreferences prefs = await _prefs;
              await prefs.setString('id', "");
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()));
            },
            child: create_button_container(
                Text("התנתק",
                    style: GoogleFonts.secularOne(
                        fontSize: size_header, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl),
                FontAwesomeIcons.rightFromBracket),
          )
        ]),
      ),
    );
  }
}
