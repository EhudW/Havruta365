import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/DeleteFromEventButton.dart';
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

  isNeedDeleteButton(){
    if (widget.event.participants.contains(Globals.currentUser.email)) {
      DeleteFromEventButton(widget.event);
    }
  }

  @override
  Widget build(BuildContext context) {
    var num = widget.event.maxParticipants - widget.event.participants.length;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventDetailHeader(widget.event),
            Storyline(widget.event.description),
            Divider(),
            Text(
              'זמני לימוד',
              style: GoogleFonts.secularOne(fontSize: 20.0),
              textAlign: TextAlign.end,
            ),
            DatesList(widget.event.dates),
            Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("!מהרו להירשם",
                    style: GoogleFonts.alef(
                        fontSize: 22.0, color: Colors.grey[700],
                        fontWeight: FontWeight.bold)),
                Text("נשארו" + " $num " + "מקומות פנויים",
                    style: GoogleFonts.suezOne(
                        fontSize: 20.0, color: Colors.grey[700]))
              ],
            ),
            SizedBox(height: 8),
            MyProgressButton(event: widget.event),
            SizedBox(height: 20.0),
            // widget.event.participants.contains(Globals.currentUser.email) ?
            //   DeleteFromEventButton(widget.event) : SizedBox(),
            ParticipentsScroller(widget.event.participants),
            SizedBox(height: 10.0),
            // Link
          ],
        ),
      ),
    );
  }
}
