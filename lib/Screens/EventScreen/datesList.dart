import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_time_format/date_time_format.dart';

class DatesList extends StatelessWidget {
  List<dynamic> dates;

  DatesList(this.dates);

  // String b = a.format('d.m.Y, H:i');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'זמני לימוד',
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 5),
        ConstrainedBox(
          constraints: new BoxConstraints(
            maxHeight: 90,
          ),
          child: Scrollbar(
            showTrackOnHover: true,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: dates.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    new Row(
                      children: <Widget>[
                        Text(dates[index] + " ",
                            style: new TextStyle(
                                fontSize: 20.0, color: Colors.grey[600])),
                        Icon(
                          Icons.date_range,
                          color: Colors.teal[200],
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
      ],
    );
  }
}

// OLD VERSION - WITH DATETIME
// Text(dates[index].format('d.m.Y, H:i')
