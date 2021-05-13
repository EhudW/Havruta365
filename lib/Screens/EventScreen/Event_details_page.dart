import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'package:havruta_project/Screens/EventScreen/datesList.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Partcipients_scroller.dart';
import 'Event_detail_header.dart';
import 'story_line.dart';


class EventDetailsPage extends StatefulWidget {
  Event event;
  EventDetailsPage(Event event){
    this.event = event;
  }

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventDetailHeader(widget.event),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Storyline(widget.event.description),
            ),
            // Frequency
            SizedBox(height: 20.0),
            // TODO INSERT DATES FOR THE EVENT
            // DatesList(widget.event.dates),
            SizedBox(height: 20.0),
            MyProgressButton(title: 'tani', link: widget.event.link),
            SizedBox(height: 20.0),
            ParticipentsScroller(widget.event.participants),
            SizedBox(height: 10.0),
            // Link
          ],
        ),
      ),
    );
  }
}
