import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/buttons/my_progress_button.dart';
import 'package:havruta_project/widgets/Texts.dart';

class MainDetails extends StatefulWidget {
  Event? event;

  MainDetails(this.event) {}

  @override
  _MainDetailsState createState() => _MainDetailsState();
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
      strToText(header, style: boxHeaderStyle),
      strToText(content, style: boxContentStyle),
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
    List<dynamic> dates = widget.event!.dates!;
    int duration = widget.event!.duration ?? 0;
    String eventTimePrefix = (dates.isNotEmpty && isNow(dates[0], duration))
        ? "   האירוע מתקיים כעת ב:    "
        : "   האירוע מתקיים ב:    ";

    String eventTimeSuffix = time == ""
        ? ""
        : (isNow(dates[0], duration)
            ? nextEvent + "    בשעה  " + time
            : nextEvent + "   בשעה  " + time);
    return [
      strToText(eventTimePrefix, style: GoogleFonts.secularOne(fontSize: 14.0)),
      strToText(
        eventTimeSuffix,
        style: GoogleFonts.secularOne(fontSize: 20.0),
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
          strToText("לימוד:", fontSize: 16.0),
          strToText(study,
              fontSize: 20.0, style: GoogleFonts.secularOne(fontSize: 20.0)),
          times[0],
          times[1],
          // countdown
          strToText(countdownString,
              fontSize: 16.0,
              style: GoogleFonts.alef(
                  fontSize: 16.0, color: Colors.green.shade800)),
          strToText("תיאור:", fontSize: 16.0),
          strToText(widget.event!.description.toString(),
              fontSize: 23, style: GoogleFonts.secularOne(fontSize: 23.0)),
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
