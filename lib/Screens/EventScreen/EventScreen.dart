import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Globals.dart';
import 'Event_details_page.dart';

class EventScreen extends StatelessWidget {
  final Event event;
  EventScreen(this.event);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'פרטי שיעור',
        gradientBegin: Colors.blue,
        gradientEnd: Colors.greenAccent,
      ),
      body: EventDetailsPage(this.event),
    );
  }
}
