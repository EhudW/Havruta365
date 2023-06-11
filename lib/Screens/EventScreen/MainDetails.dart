import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'dart:ui' as ui;

class MainDetails extends StatefulWidget {
  Event? event;

  MainDetails(this.event) {}

  @override
  _MainDetailsState createState() => _MainDetailsState();
}

String FormatCountdownString(BuildContext context, int total_minutes) {
  String countdown_string = "";
  var countdown_minutes = total_minutes;
  int minutes_in_day = 1440;
  if (countdown_minutes > 0) {
    countdown_string = "האירוע יתחיל בעוד ";
    if (countdown_minutes >= 1440) {
      countdown_string += (countdown_minutes / 1440).floor().toString();
      countdown_string += " ימים";
      countdown_string +=
          countdown_minutes % 60 == 0 || total_minutes > 3 * minutes_in_day
              ? "."
              : " ו";
      countdown_minutes = countdown_minutes % minutes_in_day;
    }
    if (countdown_minutes >= 60 && total_minutes < 3 * minutes_in_day) {
      countdown_string +=
          (countdown_minutes / 60).floor().toString() + " שעות.";
    }
    if (total_minutes >= 60 &&
        countdown_minutes % 60 != 0 &&
        total_minutes < 120) {
      countdown_string += " ו";
      countdown_string += (countdown_minutes % 60).toString() + " דקות.";
    }
    if (total_minutes % 60 != 0 && total_minutes < 60) {
      countdown_string += countdown_minutes.toString() + " דקות.";
    }
    //countdown_string += countdown_minutes.toString() + " דקות";
  } else if (countdown_minutes == 0) {
    countdown_string = "האירוע מתקיים כעת!";
  } else {
    countdown_string = "האירוע נגמר ";
  }
  return countdown_string;
}

class _MainDetailsState extends State<MainDetails> {
  List<Widget> FormatTimes(time, nextEvent) {
    return [
      Text(
        (widget.event!.dates!.isNotEmpty &&
                isNow(widget.event!.dates![0], widget.event!.duration ?? 0))
            ? "   האירוע מתקיים כעת ב:    "
            : "   האירוע מתקיים ב:    ",
        style: GoogleFonts.secularOne(fontSize: 14.0),
        //textAlign: TextAlign.end,
        textDirection: ui.TextDirection.rtl,
      ),
      Text(
        time == ""
            ? ""
            : (isNow(widget.event!.dates![0], widget.event!.duration ?? 0)
                ? nextEvent + "    בשעה  " + time
                : nextEvent + "   בשעה  " + time),
        style: GoogleFonts.secularOne(fontSize: 20.0),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.rtl,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    String book = widget.event?.book?.trim() ?? "";
    String topic = widget.event?.topic?.trim() ?? "";

    String study = book != "" ? topic : "";

    String nextEvent = "-נגמר-";

    String time = '';
    String capacity = widget.event!.participants!.length.toString() +
        "/" +
        widget.event!.maxParticipants.toString();

    if (widget.event!.dates!.isNotEmpty) {
      nextEvent = DateFormat('yyyy - MM - dd')
          .format((widget.event!.dates![0] as DateTime).toLocal());
      time = DateFormat('HH:mm')
          .format((widget.event!.dates![0] as DateTime).toLocal());
    }
    String duration = widget.event!.duration.toString() + " שעות";

    var times = FormatTimes(time, nextEvent);

    int countdown_minutes = widget.event!.startIn;
    String countdown_string = FormatCountdownString(context, countdown_minutes);

    return Container(
        child: Column(children: [
      Text("לימוד:",
          textDirection: ui.TextDirection.rtl,
          style: GoogleFonts.alef(fontSize: 16.0, color: Colors.grey[700])),
      Text(study,
          textDirection: ui.TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 20.0)),
      times[0],
      times[1],
      // countdown
      Text(countdown_string,
          textDirection: ui.TextDirection.rtl,
          style:
              GoogleFonts.alef(fontSize: 16.0, color: Colors.green.shade800)),
      Text("תיאור:",
          textDirection: ui.TextDirection.rtl,
          style: GoogleFonts.alef(fontSize: 16.0, color: Colors.grey[700])),
      Text(widget.event!.description.toString(),
          textDirection: ui.TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 23.0)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //const SizedBox(width: 40.0),
          Container(
            decoration: new BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            width: 120,
            height: 70,
            child: Column(children: [
              Text(
                "תפוסה:",
                textAlign: TextAlign.center,
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                capacity,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 27,
                    fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          const SizedBox(width: 15.0),
          Container(
            decoration: new BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            width: 120,
            height: 70,
            child: Column(children: [
              Text(
                "משך הלימוד:",
                textAlign: TextAlign.center,
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                duration,
                textAlign: TextAlign.center,
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 27,
                    fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        ],
      ),
    ]));
  }
}
