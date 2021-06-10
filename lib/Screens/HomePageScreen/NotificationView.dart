import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

class NotificationView extends StatelessWidget {
  final NotificationUser notification;

  const NotificationView({
    Key key,
    @required this.notification,
  })  : assert(notification != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler();
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Expanded(
          child: Container(
              width: scaler.getWidth(12),
              height: scaler.getHeight(3),
              color: Colors.grey[200],
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ///SizedBox(height: scaler.getHeight(0.5)),
                          Text(
                            notification.message,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: scaler.getTextSize(7),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            notification.message,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: scaler.getTextSize(6)),
                          ),
                        ])
                  ])))
    ]);
  }
}
