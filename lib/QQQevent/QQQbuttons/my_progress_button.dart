import 'package:another_flushbar/flushbar.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/notification.dart';
import 'package:havruta_project/QQQglobals.dart';
import 'package:havruta_project/event/buttons/delete_from_event_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:havruta_project/event/buttons/progress_button.dart';
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
  MyProgressButtonState createState() => MyProgressButtonState();
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

// EventDatesList.dart is assuming time1 is from @event
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

class MyProgressButtonState extends State<MyProgressButton> {
  // Check if current user already sign to the event
  // if user is signed --> stateOnlyText = ButtonState.success;

  ButtonState stateOnlyText = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    decideButtonState();
    // Create fix list of dates - every node: [start, end]
    // for (var i = 0; i < datesDB.length; i += 2) {
    //   dates.add([datesDB[i], datesDB[i + 1]]);
    // }
  }

  void decideButtonState() {
    if (stateOnlyText == ButtonState.loading) return;
    var myMail = Globals.currentUser!.email;
    var iAmCreator = widget.event!.creatorUser == myMail;
    if (iAmCreator) {
      return;
    }
    var iAmParticipant = widget.event!.participants!.contains(myMail);
    var waitingQueue = widget.event!.waitingQueue ?? [];
    var iAmInWaitingQueue = waitingQueue.contains(myMail);
    if (widget.event!.rejectedQueue.contains(myMail)) {
      stateOnlyText = ButtonState.rejected;
      return;
    }
    if (Globals.currentUser!.isTargetedForMe(widget.event!) != true) {
      stateOnlyText = ButtonState.notForMe;
      return;
    }
    // Am I already joined to this event?
    if (iAmParticipant) {
      // Check if there is event NOW
      if (widget.event!.dates!.isNotEmpty &&
          isNow(widget.event!.dates![0], widget.event!.duration!) &&
          widget.event!.link!.trim() != "") {
        stateOnlyText = ButtonState.success;
      } else {
        stateOnlyText = ButtonState.fail;
      }
      // Am I in its waiting queue?
    } else if (iAmInWaitingQueue) {
      stateOnlyText = ButtonState.fail2;
      // Here I am not in the participants/waiting queue:
      // Is the event already full    ?
    } else if (widget.event!.participants!.length /*+ waitingQueue.length*/ >=
        widget.event!.maxParticipants!) {
      stateOnlyText = ButtonState.full;
    } else {
      // lecture-> will automatically join, havruta -> will join when creator accept me
      stateOnlyText =
          widget.event!.type == 'L' ? ButtonState.idle : ButtonState.idle2;
    }
  }

  Widget buildCustomButton() {
    decideButtonState();
    var myMail = Globals.currentUser!.email;
    var iAmCreator = widget.event!.creatorUser == myMail;
    var iAmParticipant = widget.event!.participants!.contains(myMail);
    var iAmInWaitingQueue =
        widget.event!.waitingQueue?.contains(myMail) ?? false;
    // for ButtonState.fail > registered but the lecture/havruta not online right now
    var registered =
        Globals.currentUser!.gender == 'F' ? "הנך רשומה ל" : "הנך רשום ל";
    var message = widget.event!.type == 'H' ? "חברותא זו" : "שיעור זה";
    message = registered + message;
    // for ButtonState.fail2 > request was sent to the havruta creator
    var message2 = "ממתין לאישור בקשה";
    var overlaps = getEventsOverlap(widget.event!, widget.allUserEvents ?? []);
    TextStyle textStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20);
    var forIdle = (txt) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: overlaps.isNotEmpty
            ? [
                Icon(Icons.warning_amber, color: Colors.redAccent),
                Text("  " + txt + "  ",
                    textDirection: ui.TextDirection.rtl, style: textStyle)
              ]
            : [
                Text(txt, textDirection: ui.TextDirection.rtl, style: textStyle)
              ]);
    var progressTextButton = Column(children: [
      iAmCreator
          ? SizedBox()
          : SizedBox(
              width: 360,
              child: ProgressButton(
                stateWidgets: {
                  ButtonState.idle: forIdle("הירשם לשיעור!"),
                  ButtonState.idle2: forIdle("בקש להצטרף לחברותא"),
                  ButtonState.loading: Text(
                    "...עובד",
                    style: textStyle,
                  ),
                  ButtonState.fail: Text(
                    message,
                    textDirection: ui.TextDirection.rtl,
                    style: textStyle,
                  ),
                  ButtonState.fail2: Text(
                    message2,
                    textDirection: ui.TextDirection.rtl,
                    style: textStyle,
                  ),
                  ButtonState.success: Text(
                    widget.event!.type == 'H'
                        ? "!היכנס לחברותא"
                        : "!היכנס לשיעור",
                    style: textStyle,
                  ),
                  ButtonState.full: Text(
                    widget.event!.type == 'H'
                        ? "החברותא בתפוסה מלאה! לא ניתן להירשם"
                        : "השיעור בתפוסה מלאה! לא ניתן להירשם",
                    style: textStyle,
                  ),
                  ButtonState.rejected: Text(
                    'רישומך נדחה ע"י היוזמ/ת',
                    style: textStyle,
                  ),
                  ButtonState.notForMe: Text(
                    "אינך בקהל היעד של ה" + widget.event!.typeAsStr,
                    style: textStyle,
                  )
                },
                stateColors: {
                  ButtonState.idle: Colors.teal[400],
                  ButtonState.idle2: Colors.teal[400],
                  ButtonState.loading: Colors.grey,
                  ButtonState.fail: Colors.green[300],
                  ButtonState.fail2: Colors.orange[300],
                  ButtonState.success: Colors.green,
                  ButtonState.full: Colors.redAccent,
                  ButtonState.rejected: Colors.redAccent,
                  ButtonState.notForMe: Colors.redAccent
                },
                onPressed: onPressedCustomButton,
                state: stateOnlyText,
                padding: EdgeInsets.all(8.0),
              ),
            ),
      iAmParticipant || iAmInWaitingQueue || iAmCreator
          ? Column(
              children: [
                SizedBox(height: Globals.scaler.getHeight(0.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iAmCreator
                        ? SizedBox()
                        : DeleteFromEventButton(widget.event),
                    iAmCreator
                        ? SizedBox()
                        : SizedBox(width: Globals.scaler.getWidth(1)),
                    //Add2Calendar(widget.event)
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

// idleType ==1 > join lecture   idleType ==2 >  send request to join havruta, meanwhile wait in waiting queue
// idleType == 1  <> event.type=='L'
  void idleCase(int idleType) {
    var addMe = idleType == 1 ? widget.event!.join : widget.event!.joinWaiting;
    // ignore: non_constant_identifier_names
    var add_future = addMe(Globals.currentUser!.email!);

    String message =
        idleType == 1 ? "הצטרפ/ה לשיעור שלך" : "רוצה להצטרף לחברותא שלך";
    NotificationUser notification = NotificationUser.fromJson({
      'creatorUser': Globals.currentUser!.email,
      'destinationUser': widget.event!.creatorUser,
      'creationDate': DateTime.now(),
      'message': message,
      'type': idleType == 1 ? 'join' : 'joinRequest',
      'idEvent': widget.event!.id,
      'name': Globals.currentUser!.name,
    });
    Globals.db!.insertNotification(notification);
    add_future.then((value) {
      Globals.db!
          .getCounterOf(widget.event!.id.toString())
          .then((value) => Globals.db!.updateUserSubs_Topics(add: {
                widget.event!.id.toString(): {"seen": value}
              }));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        idleType == 1 ? 'האירוע נוסף בהצלחה לפרופיל האישי' : "הבקשה נשלחה",
        textAlign: TextAlign.center,
      )));
      Globals.updateRec(force: true);
      // ------------------------ Maybe need to DELETE --------------
      widget.notifyParent();
      setState(() {
        // if idleType == 2<>event.type='H' then probably the request not accepted yet.
        if (idleType == 1 &&
            widget.event!.dates!.isNotEmpty &&
            isNow(widget.event!.dates![0], widget.event!.duration!) &&
            widget.event!.link!.trim() != "") {
          stateOnlyText = ButtonState.success;
        } else {
          stateOnlyText = idleType == 1 ? ButtonState.fail : ButtonState.fail2;
        }
      });
    });
    stateOnlyText = ButtonState.loading;
  }

  void onPressedCustomButton() {
    var overlaps = getEventsOverlap(widget.event!, widget.allUserEvents ?? []);
    var isIdle =
        stateOnlyText == ButtonState.idle || stateOnlyText == ButtonState.idle2;
    if (isIdle && overlaps.isNotEmpty) {
      var ok = () => setState(() {
            idleCase(stateOnlyText == ButtonState.idle2 ? 2 : 1);
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
          idleCase(1);
          break;
        case ButtonState.idle2:
          idleCase(2);
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
        case ButtonState.fail2:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "הבקשה נשלחה כבר",
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
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.teal[400],
                    fontSize: Globals.scaler.getTextSize(8))),
            duration: Duration(seconds: 3),
          )..show(context);
          return;
        //break;
        case ButtonState.rejected:
          Flushbar(
            title: 'שגיאה בהרשמה',
            messageText: Text(
                'רישומך נדחה ע"י היוזמ/ת. ניתן לשלוח בקשה בהודעה אישית',
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.teal[400],
                    fontSize: Globals.scaler.getTextSize(8))),
            duration: Duration(seconds: 3),
          )..show(context);
          return;
        case ButtonState.notForMe:
          Flushbar(
            title: 'שגיאה בהרשמה',
            messageText: Text(
                "אינך בקהל היעד המתאים - בגלל ה" +
                    Globals.currentUser!
                        .whyIsNotTargetedForMe(widget.event!)
                        .toString(),
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.teal[400],
                    fontSize: Globals.scaler.getTextSize(8))),
            duration: Duration(seconds: 3),
          )..show(context);
          return;
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
            icon: Icon(FontAwesomeIcons.check),
            onPressed: () {
              ok();
            },
            label: Text("בכל זאת"),
          ),
          TextButton.icon(
            icon: Icon(FontAwesomeIcons.circleXmark),
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
