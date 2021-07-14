import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'Event_details_page.dart';

class EventScreen extends StatelessWidget {
  final Event event;
  EventScreen(this.event);
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          return false;
        },
      child: Scaffold(
      body: EventDetailsPage(this.event),
    )
    );
  }
}
