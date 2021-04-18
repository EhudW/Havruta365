import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'Event_api.dart';
import 'Event_details_page.dart';

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'פרטי שיעור',
        gradientBegin: Colors.blue,
        gradientEnd: Colors.greenAccent,
      ),
      body: EventDetailsPage(testEvent),
    );
  }
}
