import 'package:another_flushbar/flushbar.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/Add2Calendar.dart';
import 'package:havruta_project/Screens/EventScreen/DeleteFromEventButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:havruta_project/Screens/EventScreen/progress_button.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

class MyProgressButton extends StatefulWidget {
  MyProgressButton(
      {Key? key, this.event, required this.notifyParent, this.allUserEvents})
      : super(key: key);
  final Function() notifyParent;
  final List<Event>? allUserEvents;
  final Event? event;
  @override
  _MyProgressButtonState createState() => _MyProgressButtonState();
}

// Check if there is a event that happen right now
bool isNow(dynamic date, int duration) {
  DateTime now = DateTime.now();
  DateTime start = date;
  DateTime end = start.add(Duration(minutes: duration));
  return now.isAfter(start) && now.isBefore(end);
}

// check if there is overlap between 2 times
bool isOverlap(DateTime? first, int? firstDuration, DateTime? second,
    int? secondDuration) {
  if (first == null || second == null) {
    return false;
  }
  //            x------y
  //        a------b
  //    x------y
  DateTime a = first;
  DateTime b = a.add(Duration(minutes: firstDuration ?? 0));
  DateTime x = second;
  DateTime y = x.add(Duration(minutes: secondDuration ?? 0));
  var between = (a, x, b) {
    return (x.isAfter(a) || x.isAtSameMomentAs(a)) &&
        (x.isBefore(b) || x.isAtSameMomentAs(b));
  };
  return between(a, x, b) || between(x, a, y);
}

// get overlaps between event and its dates, and specific other time(date+duration)
List<DateTime> getTimesOverlap(Event event, DateTime? date, int? duration) {
  return List.from(
      event.dates!.where((e) => isOverlap(e, event.duration, date, duration)));
}

List<DateTime> getTimesOverlap2(Event event1, Event event2) {
  List<DateTime> rslt = [];
  if (event1.id == event2.id) {
    return [];
  }
  for (DateTime event2date in event2.dates!) {
    rslt.addAll(getTimesOverlap(event1, event2date, event2.duration));
  }
  return rslt;
}

// get overlaps between events, and specific other event
// [ ['eventA', [time1, time2]]
//   ['eventB', [time1, time2]] ... ]
List<dynamic> getEventsOverlap(Event event, List<Event> events) {
  var pairs = [];
  for (Event other in events) {
    var overlapDates = getTimesOverlap2(event, other);
    if (overlapDates.isNotEmpty) {
      pairs.add([other, overlapDates]);
    }
  }
  return pairs;
}

class _MyProgressButtonState extends State<MyProgressButton> {
  // Check if current user already sign to the event
  // if user is signed --> stateOnlyText = ButtonState.success;

  ButtonState stateOnlyText = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    // Create fix list of dates - every node: [start, end]
    // for (var i = 0; i < datesDB.length; i += 2) {
    //   dates.add([datesDB[i], datesDB[i + 1]]);
    // }
    if (widget.event!.participants!.contains(Globals.currentUser!.email)) {
      // Check if there is event NOW
      if (isNow(widget.event!.dates![0], widget.event!.duration!) &&
          widget.event!.link!.trim() != "") {
        stateOnlyText = ButtonState.success;
      } else {
        stateOnlyText = ButtonState.fail;
      }
    } else if (widget.event!.participants!.length >=
        widget.event!.maxParticipants!) {
      stateOnlyText = ButtonState.full;
    }
  }

  Widget buildCustomButton() {
    var message = widget.event!.type == 'H'
        ? "הנך רשומ/ה לחברותא זו"
        : "הנך רשומ/ה לשיעור זה";
    TextStyle textStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20);
    var progressTextButton = Column(children: [
      ProgressButton(
        stateWidgets: {
          ButtonState.idle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                getEventsOverlap(widget.event!, widget.allUserEvents ?? [])
                        .isNotEmpty
                    ? [
                        Icon(Icons.warning_amber, color: Colors.redAccent),
                        Text(
                          "  " +
                              (widget.event!.type == 'H'
                                  ? "!הירשם לחברותא"
                                  : "!הירשם לשיעור"),
                          style: textStyle,
                        ),
                      ]
                    : [
                        Text(
                          widget.event!.type == 'H'
                              ? "!הירשם לחברותא"
                              : "!הירשם לשיעור",
                          style: textStyle,
                        ),
                      ],
          ),
          ButtonState.loading: Text(
            "...עובד",
            style: textStyle,
          ),
          ButtonState.fail: Text(
            message,
            style: textStyle,
          ),
          ButtonState.success: Text(
            widget.event!.type == 'H' ? "!היכנס לחברותא" : "!היכנס לשיעור",
            style: textStyle,
          ),
          ButtonState.full: Text(
            widget.event!.type == 'H'
                ? "החברותא בתפוסה מלאה! לא ניתן להירשם"
                : "השיעור בתפוסה מלאה! לא ניתן להירשם",
            style: textStyle,
          )
        },
        stateColors: {
          ButtonState.idle: Colors.teal[400],
          ButtonState.loading: Colors.grey,
          ButtonState.fail: Colors.green[300],
          ButtonState.success: Colors.green,
          ButtonState.full: Colors.redAccent
        },
        onPressed: onPressedCustomButton,
        state: stateOnlyText,
        padding: EdgeInsets.all(8.0),
      ),
      widget.event!.participants!.contains(Globals.currentUser!.email)
          ? Column(
              children: [
                SizedBox(height: Globals.scaler.getHeight(0.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DeleteFromEventButton(widget.event),
                    SizedBox(width: Globals.scaler.getWidth(1)),
                    Add2Calendar(widget.event)
                  ],
                ),
              ],
            )
          : SizedBox(),
    ]);
    return progressTextButton;
  }

  @override
  Widget build(BuildContext context) {
    return buildCustomButton();
  }

  void idleCase() {
    // ignore: non_constant_identifier_names
    var add_future = Globals.db!
        .addParticipant(Globals.currentUser!.email, widget.event!.id);
    String message;
    message = widget.event!.type == 'H'
        ? "הצטרפ/ה לחברותא שלך"
        : "הצטרפ/ה לשיעור שלך";
    NotificationUser notification = NotificationUser.fromJson({
      'creatorUser': Globals.currentUser!.email,
      'destinationUser': widget.event!.creatorUser,
      'creationDate': DateTime.now(),
      'message': message,
      'type': 'join',
      'idEvent': widget.event!.id,
      'name': Globals.currentUser!.name,
    });
    Globals.db!.insertNotification(notification);
    add_future.then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'האירוע נוסף בהצלחה לפרופיל האישי',
        textAlign: TextAlign.center,
      )));
      // ------------------------ Maybe need to DELETE --------------
      widget.event!.participants!.add(Globals.currentUser!.email);
      widget.notifyParent();
      setState(() {
        if (isNow(widget.event!.dates![0], widget.event!.duration!) &&
            widget.event!.link!.trim() != "") {
          stateOnlyText = ButtonState.success;
        } else {
          stateOnlyText = ButtonState.fail;
        }
      });
    });
    stateOnlyText = ButtonState.loading;
  }

  void onPressedCustomButton() {
    var overlaps = getEventsOverlap(widget.event!, widget.allUserEvents ?? []);
    if (stateOnlyText == ButtonState.idle && overlaps.isNotEmpty) {
      var ok = () => setState(() {
            idleCase();
            Navigator.pop(context);
          });
      var ignore = () => setState(() {
            Navigator.pop(context);
          });
      showModalBottomSheet(
        context: context,
        builder: ((builder) => bottomSheet(overlaps, context, ok, ignore)),
      );
      return;
    }

    setState(() {
      switch (stateOnlyText) {
        case ButtonState.idle:
          idleCase();
          break;
        case ButtonState.loading:
          // stateOnlyText = ButtonState.fail;
          break;
        case ButtonState.success:
          _launchURL();
          break;
        case ButtonState.fail:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            widget.event!.type == 'H'
                ? 'אין חברותא בזמן הנוכחי'
                : 'אין שיעור בזמן הנוכחי',
            textAlign: TextAlign.center,
          )));
          break;
        case ButtonState.full:
          Flushbar(
            title: 'שגיאה בהרשמה',
            messageText: Text(
                widget.event!.type == 'H'
                    ? 'החברותא בתפוסה מלאה! לא ניתן להצטרף!'
                    : 'השיעור בתפוסה מלאה! לא ניתן להצטרף!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.teal[400],
                    fontSize: Globals.scaler.getTextSize(8))),
            duration: Duration(seconds: 3),
          )..show(context);
          return;
        //break;
      }
    });
  }

  _launchURL() async {
    var urlStr = widget.event!.link!;
    var prefixes = ["", "https://"];
    for (String prefix in prefixes) {
      var uri = Uri.parse(prefix + urlStr); // throw on format error
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }
    throw 'Could not launch $urlStr';
  }
}

Widget bottomSheet(List<dynamic> overlaps, BuildContext context, Function ok,
    Function ignore) {
  String formattedText = "";

  if (overlaps.length == 1) {
    Event event = (overlaps[0][0] as Event);
    List<DateTime> list = (overlaps[0][1] as List<DateTime>);
    DateTime date = list[0];
    String subject = event.book!;
    subject = subject.trim() == "" ? event.topic! : subject;
    subject = subject.trim();
    String teacher = event.lecturer!;
    teacher = teacher.trim() == "" ? event.creatorName! : teacher;
    teacher = teacher.trim();
    formattedText += list.length == 1
        ? "נמצאה חפיפה עם"
        : "נמצאו ${list.length} חפיפות, עם:";
    formattedText += "\n";
    formattedText += subject;
    formattedText += " - ";
    formattedText += teacher;
    if (list.length == 1) {
      formattedText += "\n";
      formattedText += DateFormat('d-M-yyyy').format(date.toLocal());
      formattedText += "   ";
      formattedText += DateFormat('HH:mm').format(date.toLocal());
    }
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
            icon: Icon(FontAwesomeIcons.v),
            onPressed: () {
              ok();
            },
            label: Text("בכל זאת"),
          ),
          TextButton.icon(
            icon: Icon(FontAwesomeIcons.x),
            onPressed: () {
              ignore();
            },
            label: Text("בטל"),
          ),
        ])
      ],
    ),
  );
}
