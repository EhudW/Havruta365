// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';

class UserDetailsColumn extends StatelessWidget {
  UserDetailsColumn(this.user);

  final User? user;

  gender() {
    if (user!.gender == 'M') {
      return "גבר";
    }
    return "אשה";
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    var size_field = Globals.scaler.getTextSize(8);
    var size_header = Globals.scaler.getTextSize(8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Text(user!.yeshiva!,
                style: GoogleFonts.alef(
                    fontSize: size_field, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl),
            SizedBox(width: Globals.scaler.getWidth(0.5)),
            Text("למד ב-",
                style: GoogleFonts.alef(fontSize: size_header),
                textDirection: TextDirection.rtl),
            SizedBox(width: Globals.scaler.getWidth(0.5)),
            Icon(
              FontAwesomeIcons.userGraduate,
              size: 26.0,
              color: Colors.grey[600],
            ),
          ]),
          SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Text(user!.address!,
                style: GoogleFonts.alef(
                    fontSize: size_field, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl),
            SizedBox(width: 5.0),
            Text("גר ב-",
                style: GoogleFonts.alef(fontSize: size_header),
                textDirection: TextDirection.rtl),
            SizedBox(width: 10.0),
            Icon(
              FontAwesomeIcons.locationDot,
              size: 26.0,
              color: Colors.grey[600],
            ),
          ]),
          SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Text(gender(),
                style: GoogleFonts.alef(
                    fontSize: size_field, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl),
            SizedBox(width: 10.0),
            Icon(
              FontAwesomeIcons.restroom,
              size: 26.0,
              color: Colors.grey[600],
            ),
          ]),
          SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Text("בגיל " + user!.age.toString(),
                style: GoogleFonts.alef(
                    fontSize: size_field, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl),
            SizedBox(width: 10.0),
            Icon(
              FontAwesomeIcons.calendarDay,
              size: 26.0,
              color: Colors.grey[600],
            ),
          ]),
          user!.heightcm != null ? SizedBox(height: 15.0) : SizedBox(),
          user!.heightcm != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                      Text(user!.heightcm!.toString(),
                          style: GoogleFonts.alef(
                              fontSize: size_field,
                              fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr),
                      SizedBox(width: Globals.scaler.getWidth(0.5)),
                      Text("גובה - ס\"מ",
                          style: GoogleFonts.alef(fontSize: size_header),
                          textDirection: TextDirection.rtl),
                      SizedBox(width: Globals.scaler.getWidth(0.5)),
                      Icon(
                        FontAwesomeIcons.rulerVertical,
                        size: 26.0,
                        color: Colors.grey[600],
                      ),
                    ])
              : SizedBox(),
          SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Text(user!.status!,
                style: GoogleFonts.alef(
                    fontSize: size_field, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl),
            SizedBox(width: 10.0),
            Icon(
              FontAwesomeIcons.heart,
              size: 26.0,
              color: Colors.grey[600],
            ),
          ]),
          SizedBox(height: 15.0),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Text(user!.description!,
                style: GoogleFonts.alef(
                    fontSize: size_field, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl),
            SizedBox(width: 10.0),
            Icon(
              FontAwesomeIcons.circleInfo,
              size: 26.0,
              color: Colors.grey[600],
            ),
          ])
        ],
      ),
    );
  }
}
