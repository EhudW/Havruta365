import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/Login/Login.dart';
import 'package:havruta_project/Screens/ProfileScreen/Events_scroller.dart';

class ProfileDetailsColumn extends StatelessWidget {
  ProfileDetailsColumn(this.user);

  final User user;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    var size_field = 20.0;
    var size_header = 24.0;
    var icon_size = 35.0;
    return Align(
      alignment: AlignmentDirectional.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: (){
              // TODO open box with all events of the user
            },
            child: Container(
              height: 65,
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.grey)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text("השיעורים שלי",
                    style: GoogleFonts.secularOne(fontSize: size_header, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl),
                SizedBox(width: 20.0),
                Icon(
                  FontAwesomeIcons.graduationCap,
                  size: icon_size,
                  color: Colors.brown[400],
                ),
              ]),
            ),
          ),
          SizedBox(height: 10,),
          GestureDetector(
            onTap: (){
              // TODO open box with all events of the user
            },
            child: Container(
              height: 65,
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.grey)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text("עדכון פרטים",
                    style: GoogleFonts.secularOne(fontSize: size_header, fontWeight: FontWeight.bold),
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
          SizedBox(height: 10,),
          GestureDetector(
            onTap: (){
              // TODO remove mail from local phone and go to Login page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Container(
              height: 65,
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.grey)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text("התנתק",
                    style: GoogleFonts.secularOne(fontSize: size_header, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl),
                SizedBox(width: 20.0),
                Icon(
                  FontAwesomeIcons.signOutAlt,
                  size: icon_size,
                  color: Colors.brown[400],
                ),
              ]),
            ),
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}
