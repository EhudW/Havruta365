import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:havruta_project/Screens/ProfileScreen/Events_scroller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailsColumn extends StatefulWidget {
  ProfileDetailsColumn(this.user);

  final User user;

  @override
  _ProfileDetailsColumnState createState() => _ProfileDetailsColumnState();
}

class _ProfileDetailsColumnState extends State<ProfileDetailsColumn> {
  bool _lesson_expanded = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    var size_header = Globals.scaler.getTextSize(8.5);
    var icon_size = Globals.scaler.getTextSize(11);
    return Expanded(
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
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
                  body: EventsScroller(Globals.currentUser.email),
                  isExpanded: _lesson_expanded,
                  canTapOnHeader: true,
                ),
              ],
              expansionCallback: (panelIndex, isExpanded) {
                _lesson_expanded = !_lesson_expanded;
                setState(() {});
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO open box with all events of the user
            },
            child: Container(
              height: Globals.scaler.getHeight(3),
              width: Globals.scaler.getWidth(32.5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(width: 0.5, color: Colors.grey[350]),
                  color: Colors.white),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(left: Globals.scaler.getWidth(0))),
                    Text("עדכון פרטים",
                        style: GoogleFonts.secularOne(
                            fontSize: size_header,
                            fontWeight: FontWeight.bold,
                            textStyle: TextStyle(
                                color: Colors.black, letterSpacing: .5)),
                        textDirection: TextDirection.rtl),
                    SizedBox(width: Globals.scaler.getWidth(1.5)),
                    Icon(
                      FontAwesomeIcons.userEdit,
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
            onTap: () async {
              // TODO remove mail from local phone and go to Login page
              final SharedPreferences prefs = await _prefs;
              await prefs.setString('id', "");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Container(
              height: Globals.scaler.getHeight(3),
              width: Globals.scaler.getWidth(32.5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(width: 1, color: Colors.grey[350]),
                  color: Colors.white),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(left: Globals.scaler.getWidth(3))),
                    Text("התנתק",
                        style: GoogleFonts.secularOne(
                            fontSize: size_header, fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl),
                    SizedBox(width: Globals.scaler.getWidth(5)),
                    Icon(
                      FontAwesomeIcons.signOutAlt,
                      size: icon_size,
                      color: Colors.brown[400],
                    ),
                  ]),
            ),
          )
        ]),
      ),
    );
  }
}
