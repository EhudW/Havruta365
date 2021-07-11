import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:havruta_project/Screens/ProfileScreen/Events_scroller.dart';

class ProfileDetailsColumn extends StatefulWidget {
  ProfileDetailsColumn(this.user);

  final User user;

  @override
  _ProfileDetailsColumnState createState() => _ProfileDetailsColumnState();
}

class _ProfileDetailsColumnState extends State<ProfileDetailsColumn> {
  bool _lesson_expanded = false;

  @override
  Widget build(BuildContext context) {
    var size_header = 24.0;
    var icon_size = 35.0;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: ExpansionPanelList(
              animationDuration: Duration(milliseconds: 500),
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("השיעורים שלי",
                            style: GoogleFonts.secularOne(
                                fontSize: size_header,
                                fontWeight: FontWeight.bold),
                            textDirection: TextDirection.rtl),
                        SizedBox(width: 20.0),
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
              height: 55,
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(width: 1, color: Colors.grey[350]),
                  color: Colors.white),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("עדכון פרטים",
                        style: GoogleFonts.secularOne(
                            fontSize: size_header,
                            fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl),
                    SizedBox(width: 20.0),
                    Icon(
                      FontAwesomeIcons.userEdit,
                      size: icon_size,
                      color: Colors.brown[400],
                    ),
                  ]),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              // TODO remove mail from local phone and go to Login page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Container(
              height: 55,
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(width: 1, color: Colors.grey[350]),
              color: Colors.white),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("התנתק",
                        style: GoogleFonts.secularOne(
                            fontSize: size_header,
                            fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl),
                    SizedBox(width: 20.0),
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
