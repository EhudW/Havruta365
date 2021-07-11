


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:progress_state_button/progress_button.dart';

class MyProgressButton extends StatefulWidget {
  MyProgressButton({Key key, this.event}) : super(key: key);

  final Event event;

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
    if (widget.event.participants.contains(Globals.currentUser.email)) {
      stateOnlyText = ButtonState.success;
    }
  }

  Widget buildCustomButton() {
    TextStyle textStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20);
    var progressTextButton = ProgressButton(
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
          "הרשמה נכשלה",
          style: textStyle,
        ),
        ButtonState.success: Text(
          "!נרשמת בהצלחה",
          style: textStyle,
        )
      },
      stateColors: {
        ButtonState.idle: Colors.teal[400],
        ButtonState.loading: Colors.grey,
        ButtonState.fail: Colors.red.shade300,
        ButtonState.success: Colors.green.shade400,
      },
      onPressed: onPressedCustomButton,
      state: stateOnlyText,
      padding: EdgeInsets.all(8.0),
    );
    return Column(
      children: [
        progressTextButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildCustomButton();
  }



  void onPressedCustomButton() {
    setState(() {
      switch (stateOnlyText) {
        case ButtonState.idle:
          var add_future =
          Globals.db.addParticipant(Globals.currentUser.email, widget.event.id);
          /*
          creatorUser = json['creatorUser'],
        creationDate = json['creationDate'],
        message = json['message'],
        type = json['type'],
        idEvent = json['idEvent'],
  name = json['name'];
           */
          String message;
          message = widget.event.type == 'H'
              ? "הצטרפ/ה לחברותא שלך"
              : "הצטרפ/ה לשיעור שלך!";
          NotificationUser notification = NotificationUser.fromJson({
            'creatorUser': Globals.currentUser.email,
            'creationDate': DateTime.now(),
            'message': message,
            'type': 'join',
            'idEvent' : widget.event.id,
            'name' : Globals.currentUser.name,
          });
          Globals.db.insertNotification(notification);
          add_future.then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'האירוע נוסף בהצלחה לפרופיל האישי',
                  textAlign: TextAlign.center,
                )));
            setState(() {
              stateOnlyText = ButtonState.success;
            });
          });
          stateOnlyText = ButtonState.loading;
          break;
        case ButtonState.loading:
        // stateOnlyText = ButtonState.fail;
          break;
        case ButtonState.success:
          break;
        case ButtonState.fail:
        // stateOnlyText = ButtonState.success;
          break;
      }
    });
  }

}