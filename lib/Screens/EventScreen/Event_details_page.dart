import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'Partcipients_scroller.dart';
import 'Event_detail_header.dart';
import 'story_line.dart';
import 'package:havruta_project/Screens/EventScreen/Progress_State_Button.dart';

class EventDetailsPage extends StatelessWidget {
  EventDetailsPage(this.event);
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventDetailHeader(event),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Storyline(event.description),
            ),
            // Frequency
            SizedBox(height: 20.0),
            ParticipentsScroller(event.participants),
            SizedBox(height: 50.0),
            // Link
          ],
        ),
      ),
    );
  }
}
