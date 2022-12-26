import 'package:another_flushbar/flushbar.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/DeleteFromEventButton.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'Partcipients_scroller.dart';
import 'Event_detail_header.dart';
import 'story_line.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class EventDetailsPage extends StatefulWidget {
  Event? event;
  EventDetailsPage(Event? event) {
    this.event = event;
  }

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  isNeedDeleteButton() {
    if (widget.event!.participants!.contains(Globals.currentUser!.email)) {
      DeleteFromEventButton(widget.event);
    }
  }

  // To make setState from children
  refresh() {
    setState(() {});
  }

  isCreatorWidget() {
    if (Globals.currentUser!.email == widget.event!.creatorUser) {
      return Container(
          height: Globals.scaler.getHeight(4.5),
          width: Globals.scaler.getWidth(4.5),
          child: FittedBox(
              child: FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  tooltip: "מחק אירוע",
                  child: Icon(FontAwesomeIcons.trashCan),
                  onPressed: () async {
                    var succeed =
                        await Globals.db!.deleteEvent(widget.event!.id);
                    if (!succeed) {
                      Flushbar(
                        title: 'מחיקת אירוע',
                        messageText: Text('אירעה שגיאה בתהליך המחיקה !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.teal[400], fontSize: 20)),
                        duration: Duration(seconds: 3),
                      )..show(context);
                    }
                    Flushbar(
                      title: 'האירוע נמחק',
                      messageText: Text('מיד תועבר לעמוד הבית !',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.teal[400], fontSize: 20)),
                      duration: Duration(seconds: 2),
                    )..show(context);
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      });
                    });
                  })));
    }
    return null;
  }

  deleteButton() {
    if (Globals.currentUser!.email == widget.event!.creatorUser) {
      return ElevatedButton.icon(
        onPressed: () {
          Globals.db!
              .deleteFromEvent(widget.event!.id, Globals.currentUser!.email);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        icon: Icon(FontAwesomeIcons.trashCan, size: 18),
        label: Text("מחק אירוע"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red[700])),
      );
    }
    return SizedBox();
  }

  dates(Event event) {
    var nextEvent = DateFormat('dd - MM - yyyy').format(event.dates![0]);
    var time = DateFormat('HH:mm').format(event.dates![0]);
    return Column(
      children: [
        Divider(),
        Text(
          "   האירוע הקרוב יתקיים ב: $nextEvent",
          style: GoogleFonts.secularOne(fontSize: 20.0),
          textAlign: TextAlign.end,
        ),
        Text(
          "   בשעה  $time",
          style: GoogleFonts.secularOne(fontSize: 20.0),
          textAlign: TextAlign.end,
        ),
        Text(
          "משך השיעור: " + event.duration.toString() + " דקות",
          style: GoogleFonts.secularOne(fontSize: 20.0),
          textDirection: ui.TextDirection.rtl,
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO Go to Yaniv page!!
          },
          icon: Icon(FontAwesomeIcons.clock, size: 18),
          label: Text("לוח זמנים מלא"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.amber)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var num =
        widget.event!.maxParticipants! - widget.event!.participants!.length;
    return Scaffold(
      // floatingActionButton: isCreatorWidget(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventDetailHeader(widget.event),
            Storyline(widget.event!.description),
            dates(widget.event!),
            Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("!מהרו להירשם",
                    style: GoogleFonts.alef(
                        fontSize: 22.0,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold)),
                Text("נשארו" + " $num " + "מקומות פנויים",
                    style: GoogleFonts.suezOne(
                        fontSize: 20.0, color: Colors.grey[700]))
              ],
            ),
            SizedBox(height: 8),
            MyProgressButton(event: widget.event, notifyParent: refresh),
            SizedBox(height: 8.0),
            Divider(),
            // widget.event.participants.contains(Globals.currentUser.email) ?
            //   DeleteFromEventButton(widget.event) : SizedBox(),
            ParticipentsScroller(widget.event!.participants),
            SizedBox(height: Globals.scaler.getHeight(1)),
            deleteButton(),
            // Link
          ],
        ),
      ),
    );
  }
}
