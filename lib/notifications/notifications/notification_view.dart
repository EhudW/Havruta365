import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/data_base/data_representations/notification.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/users/screens/user_screen/user_screen.dart';
import 'package:havruta_project/event/screens/event_page/event_screen.dart';

class NotificationView extends StatelessWidget {
  final NotificationUser notification;

  const NotificationView({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = <String?, IconData>{
          "join": FontAwesomeIcons.plus,
          "joinAccept": FontAwesomeIcons.thumbsUp,
          "joinReject": FontAwesomeIcons.thumbsDown,
          "joinRequest": FontAwesomeIcons.ellipsis,
          "eventDeleted": FontAwesomeIcons.triangleExclamation,
          "eventUpdated": FontAwesomeIcons.triangleExclamation,
          "eventUpdated:rejected": FontAwesomeIcons.triangleExclamation,
        }[notification.type] ??
        FontAwesomeIcons.book; //or .user

    return InkWell(
        splashColor: Colors.teal[400],
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            if (notification.idEvent != null &&
                notification.type != "eventDeleted") {
              return EventScreen(notification.idEvent!);
            }
            return UserScreen(notification.creatorUser);
          }));
        },
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Expanded(
              child: Container(
                  height: Globals.scaler.getHeight(4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                  ),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(width: Globals.scaler.getWidth(0.5)),
                            Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                  SizedBox(height: Globals.scaler.getHeight(1)),
                                  Center(
                                      child: Row(children: <Widget>[
                                    Text(
                                      notification.name! + " ",
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize:
                                              Globals.scaler.getTextSize(7),
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]))
                                ])),
                            SizedBox(width: Globals.scaler.getWidth(0.5)),
                            Icon(icon,
                                size: Globals.scaler.getTextSize(8),
                                color: Colors.teal),
                            SizedBox(width: Globals.scaler.getWidth(1))
                          ]),
                      Text(
                        notification.message!,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.start,
                        style:
                            TextStyle(fontSize: Globals.scaler.getTextSize(7)),
                      ),
                    ],
                  )))
        ]));
  }
}
