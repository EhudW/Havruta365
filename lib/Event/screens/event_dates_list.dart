// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/event/buttons/my_progress_button.dart';
import 'package:havruta_project/event/screens/event_scroller_screen/event_view_feed.dart';
import 'package:intl/intl.dart';
import '../../../globals.dart';
import 'package:flutter/material.dart';

import '../../data_base/data_representations/event.dart';
import 'dart:ui' as ui;

/// helper widget for cusrom filtered events list ui
class EventDatesList extends StatefulWidget {
  final Event event;
  final List<Event> allUserEvents;
  EventDatesList(this.event, this.allUserEvents);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<EventDatesList> {
  List<dynamic> allOverlaps = [];
  @override
  Widget build(BuildContext context) {
    allOverlaps = getEventsOverlap(widget.event, widget.allUserEvents);
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: Colors.teal[100],
        appBar: appBar(context),
        body: Center(
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Column(children: <Widget>[
                SizedBox(
                  height: Globals.scaler.getHeight(2),
                ),
                Expanded(
                    flex: 3,
                    child: EventViewFeed(
                      event: widget.event,
                      noClickAndClock: true,
                    )),
                Expanded(
                  flex: 16,
                  child: ListView.builder(
                    itemCount: widget.event.dates!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(12.0),
                    itemBuilder: _buildDateRow,
                  ),
                )
              ])),
        ));
  }

  String asHebrewDay(DateTime time) {
    var hebrewDays = "ראשון שני שלישי רביעי חמישי שישי שבת".split(" ");
    return hebrewDays[(time.weekday) % 7];
  }

  Widget _buildDateRow(BuildContext ctx, int idx) {
    ScreenScaler scaler = new ScreenScaler();
    DateTime time = widget.event.dates![idx];
    time = time.toLocal();
    final specificOverlaps = findOverlapEvents(allOverlaps, time);
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(60.0),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.teal[400]!,
              offset: const Offset(15, 15),
              blurRadius: 10.0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Container(
            width: scaler.getWidth(12),
            height: scaler.getHeight(specificOverlaps.isEmpty ? 4 : 6),
            child: Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: scaler.getHeight(0.5)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('d-M-yyyy').format(time),
                          // textDirection: TextDirection.RTL,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: scaler.getTextSize(7.5),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "   יום ${asHebrewDay(time)}",
                          // textDirection: TextDirection.RTL,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: scaler.getTextSize(7.5),
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(time.add(
                              Duration(minutes: widget.event.duration ?? 30))),
                          // textDirection: TextDirection.RTL,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: scaler.getTextSize(7.5),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "עד",
                          // textDirection: TextDirection.RTL,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: scaler.getTextSize(7.5),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('HH:mm').format(time),
                          // textDirection: TextDirection.RTL,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: scaler.getTextSize(7.5),
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                  specificOverlaps.isEmpty
                      ? Container()
                      : TextButton(
                          style:
                              TextButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () =>
                              overlapOnPress(specificOverlaps, context),
                          child: Text(
                            specificOverlaps.length == 1
                                ? "נמצאה חפיפה"
                                : "נמצאו חפיפות",
                            style: TextStyle(
                                color: Colors.white, //grey.shade600,
                                fontSize: scaler.getTextSize(6.5)),
                          )),
                ],
              ),
            ),
          )),
          SizedBox(width: scaler.getWidth(3)),
          Column(children: <Widget>[
            Container(
              margin: const EdgeInsets.all(4.0),
              width: scaler.getWidth(5),
              height: scaler.getHeight(3),
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: const BorderRadius.all(
                  Radius.circular(60.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.teal[400]!,
                      offset: const Offset(2, 0),
                      blurRadius: 10.0),
                ],
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Icon(FontAwesomeIcons.clock)),
            ),
          ]),
          SizedBox(width: scaler.getWidth(1))
        ],
      ),
    );
  }

  appBar(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler();

    return new AppBar(
        leadingWidth: 0,
        toolbarHeight: 40,
        elevation: 30,
        shadowColor: Colors.teal[400],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        )),
        backgroundColor: Colors.white,
        title: Container(
          width: scaler.getWidth(50),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "  לוח זמנים מלא  ",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alef(
                      fontWeight: FontWeight.bold,
                      fontSize: Globals.scaler.getTextSize(9),
                      color: Colors.teal[400]),
                ),
                Icon(FontAwesomeIcons.calendar,
                    size: 20, color: Colors.teal[400])
              ]),
        ));
  }
}

List<Event> findOverlapEvents(List<dynamic> overlaps, DateTime findMe) {
  var isEq = (t) => t.isAtSameMomentAs(findMe);
  var contains = (List pair) => pair.any((t) => isEq(t));
  var filteredOverlaps = overlaps.where((overlap) => contains(overlap[1]));
  var filteredOverlapsEventsOnly = filteredOverlaps.map((e) => e[0]);
  return List.from(filteredOverlapsEventsOnly);
}

void overlapOnPress(List<Event> overlaps, BuildContext context) {
  var ignore = () => Navigator.pop(context);
  showModalBottomSheet(
    context: context,
    builder: ((builder) => bottomSheet(overlaps, context, ignore)),
  );
}

Widget bottomSheet(
    List<Event> overlaps, BuildContext context, Function ignore) {
  String formattedText = "";

  if (overlaps.length == 1) {
    Event event = overlaps[0];
    String subject = event.book!;
    subject = subject.trim() == "" ? event.topic! : subject;
    subject = subject.trim();
    String teacher = event.lecturer!;
    teacher = teacher.trim() == "" ? event.creatorName! : teacher;
    teacher = teacher.trim();
    formattedText += overlaps.length == 1
        ? "נמצאה חפיפה עם"
        : "נמצאו ${overlaps.length} חפיפות, עם:";
    formattedText += "\n";
    formattedText += subject;
    formattedText += " - ";
    formattedText += teacher;
  } else {
    formattedText += "נמצאו מספר חפיפות";
  }
  return Container(
    height: Globals.scaler.getHeight(8.5),
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.symmetric(
      horizontal: Globals.scaler.getWidth(3),
      vertical: Globals.scaler.getHeight(1),
    ),
    child: Column(
      children: <Widget>[
        Text(
          formattedText,
          textDirection: ui.TextDirection.rtl,
          style: TextStyle(
            fontSize: Globals.scaler.getTextSize(8.5),
          ),
        ),
        SizedBox(
          height: Globals.scaler.getHeight(1),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          TextButton.icon(
            icon: Icon(FontAwesomeIcons.circleXmark),
            onPressed: () {
              ignore();
            },
            label: Text("אישור"),
          ),
        ])
      ],
    ),
  );
}
