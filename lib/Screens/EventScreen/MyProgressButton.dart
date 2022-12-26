import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/Add2Calendar.dart';
import 'package:havruta_project/Screens/EventScreen/DeleteFromEventButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:havruta_project/Screens/EventScreen/progress_button.dart';

class MyProgressButton extends StatefulWidget {
  MyProgressButton({Key? key, this.event, required this.notifyParent})
      : super(key: key);
  final Function() notifyParent;
  final Event? event;

  @override
  _MyProgressButtonState createState() => _MyProgressButtonState();
}

class _MyProgressButtonState extends State<MyProgressButton> {
  // Check if current user already sign to the event
  // if user is signed --> stateOnlyText = ButtonState.success;

  ButtonState stateOnlyText = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    // Create fix list of dates - every node: [start, end]
    // for (var i = 0; i < datesDB.length; i += 2) {
    //   dates.add([datesDB[i], datesDB[i + 1]]);
    // }
    if (widget.event!.participants!.contains(Globals.currentUser!.email)) {
      // Check if there is event NOW
      if (isNow(widget.event!.dates![0])) {
        stateOnlyText = ButtonState.success;
      }
      stateOnlyText = ButtonState.fail;
    } else if (widget.event!.participants!.length >=
        widget.event!.maxParticipants!) {
      stateOnlyText = ButtonState.full;
    }
  }

  // Check if there is a event that happen right now
  bool isNow(dynamic date) {
    DateTime now = DateTime.now();
      if ((now.isAfter(date) && now.isBefore(date) ||
          now.isAtSameMomentAs(date) ||
          now.isAtSameMomentAs(date))) {
        return true;
      }
    return false;
  }

  Widget buildCustomButton() {
    var message = widget.event!.type == 'H'
        ? "הנך רשומ/ה לחברותא זו"
        : "הנך רשומ/ה לשיעור זה";
    TextStyle textStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20);
    var progressTextButton = Column(children: [
      ProgressButton(
        stateWidgets: {
          ButtonState.idle: Text(
            "!הירשם לשיעור",
            style: textStyle,
          ),
          ButtonState.loading: Text(
            "...עובד",
            style: textStyle,
          ),
          ButtonState.fail: Text(
            message,
            style: textStyle,
          ),
          ButtonState.success: Text(
            "!היכנס לשיעור",
            style: textStyle,
          ),
          ButtonState.full: Text(
            "השיעור בתפוסה מלאה! לא ניתן להירשם",
            style: textStyle,
          )
        },
        stateColors: {
          ButtonState.idle: Colors.teal[400],
          ButtonState.loading: Colors.grey,
          ButtonState.fail: Colors.green[300],
          ButtonState.success: Colors.green,
          ButtonState.full: Colors.redAccent
        },
        onPressed: onPressedCustomButton,
        state: stateOnlyText,
        padding: EdgeInsets.all(8.0),
      ),
      widget.event!.participants!.contains(Globals.currentUser!.email)
          ? Column(
            children: [
              SizedBox(height: Globals.scaler.getHeight(0.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DeleteFromEventButton(widget.event),
                  SizedBox(width: Globals.scaler.getWidth(1)),
                  Add2Calendar(widget.event)
                ],
              ),
            ],
          )
          : SizedBox(),
    ]);
    return progressTextButton;
  }

  @override
  Widget build(BuildContext context) {
    return buildCustomButton();
  }

  void onPressedCustomButton() {
    setState(() {
      switch (stateOnlyText) {
        case ButtonState.idle:
          var add_future = Globals.db!
              .addParticipant(Globals.currentUser!.email, widget.event!.id);
          String message;
          message = widget.event!.type == 'H'
              ? "הצטרפ/ה לחברותא שלך"
              : "הצטרפ/ה לשיעור שלך";
          NotificationUser notification = NotificationUser.fromJson({
            'creatorUser': Globals.currentUser!.email,
            'destinationUser': widget.event!.creatorUser,
            'creationDate': DateTime.now(),
            'message': message,
            'type': 'join',
            'idEvent': widget.event!.id,
            'name': Globals.currentUser!.name,
          });
          Globals.db!.insertNotification(notification);
          add_future.then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              'האירוע נוסף בהצלחה לפרופיל האישי',
              textAlign: TextAlign.center,
            )));
            // ------------------------ Maybe need to DELETE --------------
            widget.event!.participants!.add(Globals.currentUser!.email);
            widget.notifyParent();
            setState(() {
              if (isNow(widget.event!.dates![0])) {
                stateOnlyText = ButtonState.success;
              }
              stateOnlyText = ButtonState.fail;
            });
          });
          stateOnlyText = ButtonState.loading;
          break;
        case ButtonState.loading:
          // stateOnlyText = ButtonState.fail;
          break;
        case ButtonState.success:
          _launchURL();
          break;
        case ButtonState.fail:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            'אין שיעור בזמן הנוכחי',
            textAlign: TextAlign.center,
          )));
          break;
        case ButtonState.full:
          Flushbar(
            title: 'שגיאה בהרשמה',
            messageText: Text('השיעור בתפוסה מלאה! לא ניתן להצטרף!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.teal[400],
                    fontSize: Globals.scaler.getTextSize(8))),
            duration: Duration(seconds: 3),
          )..show(context);
          return;
          break;
      }
    });
  }

  _launchURL() async {
    var url = widget.event!.link!;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
