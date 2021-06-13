import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

class NotificationView extends StatelessWidget {
  final NotificationUser notification;

  const NotificationView({Key key, @required this.notification})
      : assert(notification != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String mes;
    if (notification.type == 'E') {
      icon = FontAwesomeIcons.user;
      mes = notification.creatorUser + " " + notification.message;
    } else {
      icon = FontAwesomeIcons.book;
      mes = notification.message;
    }

    ScreenScaler scaler = new ScreenScaler();
    return InkWell(
        splashColor: Colors.teal[400],
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        onTap: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => EventScreen(event)));
        },
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Expanded(
              child: Container(
                  height: scaler.getHeight(3),
                  // color: Colors.grey[200],
                  decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(0.0),
                      )),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: <
                          Widget>[
                    SizedBox(width: scaler.getWidth(0.5)),
                    Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                          SizedBox(height: scaler.getHeight(1)),
                          Center(
                              child: Row(children: <Widget>[
                            Text(
                              notification.message,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: scaler.getTextSize(7)),
                            ),
                            Text(
                              notification.creatorUser + " ",
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: scaler.getTextSize(7),
                                  fontWeight: FontWeight.bold),
                            )
                          ]))
                        ])),
                    SizedBox(width: scaler.getWidth(0.5)),
                    Icon(icon, size: scaler.getTextSize(8), color: Colors.teal),
                    SizedBox(width: scaler.getWidth(1))
                  ])))
        ]));
  }
}
