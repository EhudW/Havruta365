//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:date_time_format/date_time_format.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class InterestsList extends StatelessWidget {
  List<dynamic> interests;

  InterestsList(this.interests);

  // String b = a.format('d.m.Y, H:i');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Text('תחומי ענין',
              style:
                  GoogleFonts.alef(fontSize: 20.0, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl),
          SizedBox(width: 10.0),
          Icon(
            FontAwesomeIcons.star,
            size: 26.0,
            color: Colors.grey[600],
          ),
        ]),
        ConstrainedBox(
          constraints: new BoxConstraints(
            maxHeight: 90,
          ),
          child: ListView.builder(
            // physics: ClampingScrollPhysics(),
            // scrollDirection: Axis.vertical,
            // shrinkWrap: true,
            itemCount: interests.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  new Row(
                    children: <Widget>[
                      Text(interests[index][1],
                          style: GoogleFonts.alef(
                              fontSize: 20.0, fontWeight: FontWeight.normal),
                          textDirection: TextDirection.rtl),
                      Text("|  ",
                          style: GoogleFonts.alef(
                              fontSize: 20.0, fontWeight: FontWeight.normal),
                          textDirection: TextDirection.rtl),
                      SizedBox(width: 10.0),
                      Text(interests[index][0],
                          style: GoogleFonts.alef(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.rtl),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  SizedBox(
                    height: 7,
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// OLD VERSION - WITH DATETIME
// Text(dates[index].format('d.m.Y, H:i')
