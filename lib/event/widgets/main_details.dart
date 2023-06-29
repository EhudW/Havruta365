import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/buttons/my_progress_button.dart';
import 'dart:ui' as ui;

class MainDetails extends StatefulWidget {
  Event? event;

  MainDetails(this.event) {}

  @override
  _MainDetailsState createState() => _MainDetailsState();
}

Text strToText(String str, double fontSize, {style = GoogleFonts.secularOne}) {
  if (style == GoogleFonts.secularOne)
    style = GoogleFonts.alef(fontSize: fontSize, color: Colors.grey[700]);

  return Text(
    str,
    style: style,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.rtl,
  );
}

Widget createBox(String header, String content) {
  var boxHeaderStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  var boxContentStyle = TextStyle(
      color: Colors.green.shade800, fontSize: 27, fontWeight: FontWeight.bold);

  return Container(
    decoration: new BoxDecoration(
      color: Colors.grey.shade300,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    width: 120,
    height: 70,
    child: Column(children: [
      strToText(header, 0, style: boxHeaderStyle),
      strToText(content, 0, style: boxContentStyle),
    ]),
  );
}

String createCountdownString(int totalMinutes) {
  String countdownString = "";
  var countdownMinutes = totalMinutes;
  const int minutesInDay = 1440;
  if (countdownMinutes > 0) {
    countdownString = "האירוע יתחיל בעוד ";
    if (countdownMinutes >= 1440) {
      countdownString += (countdownMinutes / 1440).floor().toString();
      countdownString += " ימים";
      countdownString +=
          countdownMinutes % 60 == 0 || totalMinutes > 3 * minutesInDay
              ? "."
              : " ו";
      countdownMinutes = countdownMinutes % minutesInDay;
    }
    if (countdownMinutes >= 60 && totalMinutes < 3 * minutesInDay) {
      countdownString += (countdownMinutes / 60).floor().toString() + " שעות.";
    }
    if (totalMinutes >= 60 &&
        countdownMinutes % 60 != 0 &&
        totalMinutes < 120) {
      countdownString += " ו";
      countdownString += (countdownMinutes % 60).toString() + " דקות.";
    }
    if (totalMinutes % 60 != 0 && totalMinutes < 60) {
      countdownString += countdownMinutes.toString() + " דקות.";
    }
  } else if (countdownMinutes == 0) {
    countdownString = "האירוע מתקיים כעת!";
  } else {
    countdownString = "האירוע נגמר ";
  }
  return countdownString;
}

class _MainDetailsState extends State<MainDetails> {
  List<Widget> formatTimes(time, nextEvent) {
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

    String study =
        (topic != "" && book != "") ? "$topic - $book" : "$topic$book";

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
    String duration = widget.event!.duration.toString();
    duration += " דקות";

    var times = formatTimes(time, nextEvent);

    int countdownMinutes = widget.event!.startIn;
    String countdownString = createCountdownString(countdownMinutes);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(children: [
          strToText("לימוד:", 16.0),
          strToText(study, 20.0, style: GoogleFonts.secularOne(fontSize: 20.0)),
          times[0],
          times[1],
          // countdown
          strToText(countdownString, 16.0,
              style: GoogleFonts.alef(
                  fontSize: 16.0, color: Colors.green.shade800)),
          strToText("תיאור:", 16.0),
          strToText(widget.event!.description.toString(), 23,
              style: GoogleFonts.secularOne(fontSize: 23.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const SizedBox(width: 40.0),
              createBox("תפוסה:", capacity),
              const SizedBox(width: 15.0),
              createBox("משך הלימוד:", duration),
            ],
          ),
        ]));
  }
}
