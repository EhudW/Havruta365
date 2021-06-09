import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'dart:async';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class MyProgressButton extends StatefulWidget {
  MyProgressButton({Key key, this.id, this.link}) : super(key: key);

  final String id;
  final String link;

  @override
  _MyProgressButtonState createState() => _MyProgressButtonState();
}

class _MyProgressButtonState extends State<MyProgressButton> {
  ButtonState stateOnlyText = ButtonState.idle;
  //Widget linkText = Text('');
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

  _launchURL(String link) async {
    print(link);
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> addParticipant(String mail, String id) async {
    var collection = Globals.db.db.collection('Events');
    // Get event by id and Add mail to participants array
    var res = await collection.updateOne(
        where.eq('id', id), ModifierBuilder().push('participants', mail));
  }

  void onPressedCustomButton() {
    setState(() {
      switch (stateOnlyText) {
        case ButtonState.idle:
          var add_future = addParticipant(Globals.currentUser.email, widget.id);
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
