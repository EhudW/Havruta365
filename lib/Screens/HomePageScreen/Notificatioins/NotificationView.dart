import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';

class NotificationView extends StatelessWidget {
  final NotificationUser notification;

  const NotificationView({Key? key, required this.notification})
      : assert(notification != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (notification.type == 'join') {
      icon = FontAwesomeIcons.user;
    } else {
      icon = FontAwesomeIcons.book;
    }

    return InkWell(
        splashColor: Colors.teal[400],
        onTap: () async {
           Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserScreen(notification.creatorUser)));
        },
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Expanded(
              child: Container(
                  height: Globals.scaler.getHeight(3),
                  decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                  ),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: <
                          Widget>[
                    SizedBox(width: Globals.scaler.getWidth(0.5)),
                    Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                          SizedBox(height: Globals.scaler.getHeight(1)),
                          Center(
                              child: Row(children: <Widget>[
                            Text(
                              notification.message!,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: Globals.scaler.getTextSize(7)),
                            ),
                            Text(
                              notification.name! + " ",
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: Globals.scaler.getTextSize(7),
                                  fontWeight: FontWeight.bold),
                            )
                          ]))
                        ])),
                    SizedBox(width: Globals.scaler.getWidth(0.5)),
                    Icon(icon, size: Globals.scaler.getTextSize(8), color: Colors.teal),
                    SizedBox(width: Globals.scaler.getWidth(1))
                  ])))
        ]));
  }
}
