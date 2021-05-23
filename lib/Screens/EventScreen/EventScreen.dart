import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'Event_details_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventScreen extends StatelessWidget {
  final Event event;

  EventScreen(this.event);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          elevation: 20,
          shadowColor: Colors.teal[400],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              )),
          backgroundColor: Colors.white,
          title: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Havruta  ',
                      style: TextStyle(fontWeight:FontWeight.bold, color: Colors.teal[400]),
                    ),
                    Icon(FontAwesomeIcons.book, size: 25, color: Colors.teal[400])
                  ]))),

      body: EventDetailsPage(this.event),
    );
  }
}
