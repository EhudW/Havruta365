import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DatesList extends StatelessWidget {
  List<dynamic> datesDB;

  DatesList(this.datesDB);

  // String b = a.format('d.m.Y, H:i');

  @override
  Widget build(BuildContext context) {
    List<dynamic> dates = [];
    for (var i = 0; i < datesDB.length; i += 2) {
      dates.add([datesDB[i], datesDB[i + 1]]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text(
        //   'זמני לימוד',
        //   style: GoogleFonts.secularOne(fontSize: 20.0),
        //   textAlign: TextAlign.end,
        // ),
        ConstrainedBox(
          constraints: new BoxConstraints(
            maxHeight: 100,
          ),
          child: Scrollbar(
            showTrackOnHover: true,
            child: ListView.builder(
              //physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              //shrinkWrap: true,
              itemCount: dates.length,
              itemBuilder: (BuildContext context, int index) {
                var date = DateFormat('d-M-yyyy').format(dates[index][0]);
                var start = DateFormat('kk:mm').format(dates[index][0]);
                var end = DateFormat('kk:mm').format(dates[index][1]);
                return Column(
                  children: [
                    new Row(
                      children: <Widget>[
                        Text(start + " - " + end,
                            style: new TextStyle(
                                fontSize: 17.0, color: Colors.grey[600])),
                        SizedBox(width: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 5),
                            Icon(
                              Icons.date_range,
                              color: Colors.amber[600],
                              size: 34,
                            ),
                            SizedBox(width: 5),
                            Text(
                                date,
                                style: new TextStyle(
                                    fontSize: 18.0, color: Colors.grey[700],
                                fontWeight: FontWeight.bold)),
                          ],
                        ),


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
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// OLD VERSION - WITH DATETIME
// Text(dates[index].format('d.m.Y, H:i')
