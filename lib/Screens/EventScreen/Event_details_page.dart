//import 'dart:html';

import 'package:another_flushbar/flushbar.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/DeleteFromEventButton.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta1.dart';
//import 'package:havruta_project/Screens/EventScreen/progress_button.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../DataBase_auth/Notification.dart';
import 'EventDatesList.dart';
import 'Partcipients_scroller.dart';
import 'Event_detail_header.dart';
import 'story_line.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class EventDetailsPage extends StatefulWidget {
  Event? event;
  List<Event>? allUserEvents;
  EventDetailsPage(this.event, this.allUserEvents);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  /*isNeedDeleteButton() {
    var myMail = Globals.currentUser!.email;
    var iAmParticipant = widget.event!.participants!.contains(myMail);
    var iAmInWaitingQueue =
        widget.event!.waitingQueue?.contains(myMail) ?? false;
    if (iAmParticipant || iAmInWaitingQueue) {
      DeleteFromEventButton(widget.event);
    }
  }*/

  // To make setState from children
  refresh() {
    setState(() {});
  }

  _deleteEvent() async {
    // notify persons who joined/waiting to be joined
    var toNotify = [];
    toNotify.addAll(widget.event!.participants ?? []);
    toNotify.addAll(widget.event!.waitingQueue ?? []);
    var t = widget.event!.type == 'H' ? "חברותא" : "שיעור";
    var g = Globals.currentUser!.gender == 'F' ? "ביטלה" : "ביטל";
    var msg = g + " " + t;
    // try to delete event
    var succeed = await Globals.db!.deleteEvent(widget.event!.id);
    // notify the people
    if (succeed) {
      for (String personToNotify in toNotify) {
        Globals.db!.insertNotification(NotificationUser.fromJson({
          'creatorUser': Globals.currentUser!.email,
          'destinationUser': personToNotify,
          'creationDate': DateTime.now(),
          'message': msg,
          'type': 'eventDeleted',
          'idEvent': null,
          'name': Globals.currentUser!.name,
        }));
      }
    }
    // show flushbar to the creator
    if (!succeed) {
      Flushbar(
        title: 'מחיקת אירוע',
        messageText: Text('אירעה שגיאה בתהליך המחיקה !',
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.teal[400], fontSize: 20)),
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      Flushbar(
        title: 'האירוע נמחק',
        messageText: Text('מיד תועבר לעמוד הבית !',
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.teal[400], fontSize: 20)),
        duration: Duration(seconds: 2),
      )..show(context);
    }
    // move creator to the home page
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    });
  }

  deleteButton() {
    if (Globals.currentUser!.email == widget.event!.creatorUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FindMeAChavruta1(
                          initEvent: widget.event,
                        )),
              );
            },
            icon: Icon(FontAwesomeIcons.penToSquare, size: 18),
            label: Text("ערוך אירוע"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange[400])),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet(
                      context,
                      () {
                        Navigator.pop(context);
                        _deleteEvent();
                      },
                      () => Navigator.pop(context),
                    )),
              );
            },
            icon: Icon(FontAwesomeIcons.trashCan, size: 18),
            label: Text("מחק אירוע"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red[700])),
          ),
        ],
      );
    }
    return SizedBox();
  }

  dates(Event event) {
    String nextEvent = "-נגמר-";
    String time = '';
    if (event.dates!.isNotEmpty) {
      nextEvent = DateFormat('dd - MM - yyyy')
          .format((event.dates![0] as DateTime).toLocal());
      time =
          DateFormat('HH:mm').format((event.dates![0] as DateTime).toLocal());
    }
    return Column(
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nextEvent,
              style: GoogleFonts.secularOne(fontSize: 20.0),
              //textAlign: TextAlign.end,
            ),
            Text(
              (event.dates!.isNotEmpty &&
                      isNow(event.dates![0], event.duration ?? 0))
                  ? "   האירוע מתקיים כעת ב:    "
                  : "   האירוע הקרוב יתקיים ב:    ",
              style: GoogleFonts.secularOne(fontSize: 20.0),
              //textAlign: TextAlign.end,
              textDirection: ui.TextDirection.rtl,
            ),
          ],
        ),
        Text(
          time == ""
              ? ""
              : (isNow(event.dates![0], event.duration ?? 0)
                  ? "   התחיל בשעה  $time"
                  : "   בשעה  $time"),
          style: GoogleFonts.secularOne(fontSize: 20.0),
          textAlign: TextAlign.end,
        ),
        (widget.event!.creatorUser == Globals.currentUser!.email &&
                (widget.event!.link?.trim() ?? "") != "")
            ? InkWell(
                child: Text(
                  widget.event!.link!.trim(),
                  style: GoogleFonts.secularOne(
                      fontSize: 20.0,
                      color: Colors.blueAccent[100],
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationThickness: 2),
                  textDirection: ui.TextDirection.ltr,
                ),
                onTap: () async {
                  var urlStr = widget.event!.link!;
                  var prefixes = ["", "https://"];
                  for (String prefix in prefixes) {
                    var uri =
                        Uri.parse(prefix + urlStr); // throw on format error
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                      return;
                    }
                  }
                  throw 'Could not launch $urlStr';
                },
              )
            : SizedBox(),
        Text(
          widget.event!.type == 'L'
              ? "משך השיעור: " + event.duration.toString() + " דקות"
              : "משך החברותא: " + event.duration.toString() + " דקות",
          style: GoogleFonts.secularOne(fontSize: 20.0),
          textDirection: ui.TextDirection.rtl,
        ),
        Text(
          "עד ${(event.maxParticipants ?? 100)} משתתפים",
          style: GoogleFonts.secularOne(fontSize: 20.0),
          textDirection: ui.TextDirection.rtl,
        ),
        event.dates!.isEmpty
            ? Container()
            : ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventDatesList(event, widget.allUserEvents ?? []),
                    ),
                  );
                },
                icon: Icon(FontAwesomeIcons.clock, size: 18),
                label: Text("לוח זמנים מלא"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.amber)),
              )
      ],
    );
  }

  Widget bottomSheet(BuildContext context, Function ok, Function ignore) {
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
            "אתה בטוח",
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
              label: Text("בטוח"),
            ),
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.circleXmark),
              onPressed: () {
                ignore();
              },
              label: Text("בטל פעולה"),
            ),
          ])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myMail = Globals.currentUser!.email;
    var iAmParticipant = widget.event!.participants!.contains(myMail);
    var iAmCreator = widget.event!.creatorUser == myMail;
    var waitingQueue = widget.event!.waitingQueue ?? [];
    var iAmInWaitingQueue = waitingQueue.contains(myMail);
    var num = widget.event!.maxParticipants! -
        widget.event!.participants!.length -
        waitingQueue.length;
    var rejectOrAcceptFactory = (func) => (userMail) {
          showModalBottomSheet(
            context: context,
            builder: ((builder) => bottomSheet(context, () {
                  Navigator.pop(context);
                  func(userMail);
                  refresh();
                }, () => Navigator.pop(context))),
          );
        };
    var reject = rejectOrAcceptFactory((userMail) {
      Globals.db!.deleteFromEventWaitingQueue(widget.event!.id, userMail);
      NotificationUser notification = NotificationUser.fromJson({
        'creatorUser': Globals.currentUser!.email,
        'destinationUser': userMail,
        'creationDate': DateTime.now(),
        'message': "לצערי דחיתי את בקשתך לחברותא",
        'type': 'joinReject',
        'idEvent': widget.event!.id,
        'name': Globals.currentUser!.name,
      });
      Globals.db!.insertNotification(notification);
      if (widget.event!.waitingQueue == null) {
        widget.event!.waitingQueue = [];
      }
      widget.event!.waitingQueue!.remove(userMail);
    });
    var accept = rejectOrAcceptFactory((userMail) {
      Globals.db!.deleteFromEventWaitingQueue(widget.event!.id, userMail);
      Globals.db!.addParticipant(userMail, widget.event!.id);
      NotificationUser notification = NotificationUser.fromJson({
        'creatorUser': Globals.currentUser!.email,
        'destinationUser': userMail,
        'creationDate': DateTime.now(),
        'message': "אישרתי את בקשתך לחברותא",
        'type': 'joinAccept',
        'idEvent': widget.event!.id,
        'name': Globals.currentUser!.name,
      });
      Globals.db!.insertNotification(notification);
      if (widget.event!.waitingQueue == null) {
        widget.event!.waitingQueue = [];
      }
      widget.event!.waitingQueue!.remove(userMail);
      widget.event!.participants!.add(userMail);
    });
    String? storyline = widget.event!.description;
    String location = widget.event!.location?.trim() ?? "";
    location = location == "" ? "" : "\n" + location;
    storyline = storyline == null
        ? widget.event!.location?.trim()
        : storyline + location;
    bool notMyTarget = !Globals.currentUser!.isTargetedForMe(widget.event!);
    return Scaffold(
      // floatingActionButton: isCreatorWidget(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventDetailHeader(widget.event),
            Storyline(
                storyline,
                widget.event!.type == 'L'
                    ? FontAwesomeIcons.graduationCap
                    : FontAwesomeIcons.users),
            dates(widget.event!),
            Divider(),
            widget.event!.dates!.isEmpty
                ? Container()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (iAmParticipant ||
                              iAmInWaitingQueue ||
                              num <= 0 ||
                              notMyTarget)
                          ? Container()
                          : Text("!מהרו להירשם",
                              style: GoogleFonts.alef(
                                  fontSize: 22.0,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold)),
                      Text(
                          num <= 0
                              ? "תפוסה מלאה"
                              : "נשארו" + " $num " + "מקומות פנויים",
                          style: GoogleFonts.suezOne(
                              fontSize: 20.0, color: Colors.grey[700])),
                      Row(
                        textDirection: ui.TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("גברים/נשים: ",
                              textDirection: ui.TextDirection.rtl,
                              style: GoogleFonts.suezOne(
                                  fontSize: 20.0, color: Colors.grey[700])),
                          Text(widget.event!.targetGender!,
                              textDirection: ui.TextDirection.rtl,
                              style: GoogleFonts.suezOne(
                                  fontSize: 20.0, color: Colors.grey[700])),
                        ],
                      )
                    ],
                  ),
            widget.event!.dates!.isEmpty || notMyTarget
                ? Container()
                : SizedBox(height: 8),
            widget.event!.dates!.isEmpty || notMyTarget
                ? Container()
                : MyProgressButton(
                    event: widget.event,
                    allUserEvents: widget.allUserEvents,
                    notifyParent: refresh),
            SizedBox(height: 8.0),
            Divider(),
            // widget.event.participants.contains(Globals.currentUser.email) ?
            //   DeleteFromEventButton(widget.event) : SizedBox(),
            widget.event!.type == "L" || iAmParticipant || iAmCreator
                ? ParticipentsScroller(
                    widget.event!.participants,
                    title: "משתתפים",
                  )
                : Container(),
            iAmCreator && widget.event!.type == 'H'
                ? ParticipentsScroller(
                    widget.event!.waitingQueue,
                    title: "ממתינים לאישור",
                    accept: accept,
                    reject: reject,
                  )
                : Container(),
            SizedBox(height: Globals.scaler.getHeight(1)),
            deleteButton(),
            // Link
          ],
        ),
      ),
    );
  }
}
