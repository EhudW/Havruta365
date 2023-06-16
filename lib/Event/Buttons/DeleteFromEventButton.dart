//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase/DataRepresentations/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/HomePage.dart';

class DeleteFromEventButton extends StatefulWidget {
  DeleteFromEventButton(this.event);

  final Event? event;

  @override
  _DeleteFromEventButtonState createState() => _DeleteFromEventButtonState();
}

class _DeleteFromEventButtonState extends State<DeleteFromEventButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        var myMail = Globals.currentUser!.email;
        widget.event?.leave(myMail!);
        Globals.db!
            .updateUserSubs_Topics(remove: [widget.event!.id.toString()]);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      icon: Icon(Icons.remove_circle_outline, size: 18),
      label: Text("בטל רישום"),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
    );
  }
}
