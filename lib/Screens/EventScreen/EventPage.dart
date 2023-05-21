import 'package:another_flushbar/flushbar.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/DeleteFromEventButton.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta1.dart';
//import 'package:havruta_project/Screens/EventScreen/progress_button.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' as query;
import 'package:url_launcher/url_launcher.dart';
import '../../DataBase_auth/Notification.dart';
import 'arc_banner_image.dart';
import 'EventDatesList.dart';
import 'Partcipients_scroller.dart';
import 'Event_detail_header.dart';
import 'story_line.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class EventPage extends StatefulWidget {
  Event? event;
  List<Event>? allUserEvents;
  var userColl;
  EventPage(this.event, this.allUserEvents) {
    this.userColl = Globals.db!.db.collection('Users');
  }

  Future getUser(String? userMail) async {
    var user = await userColl.findOne(query.where.eq('email', '$userMail'));
    return user;
  }

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  refresh() {
    setState(() {});
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
            Globals.currentUser!.gender == 'F' ? "את בטוחה?" : "אתה בטוח?",
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

  String FormatCountdownString(BuildContext context, int countdown_minutes) {
    String countdown_string = "";
    if (countdown_minutes > 0) {
      countdown_string = "האירוע יתחיל בעוד ";
      if (countdown_minutes >= 1440) {
        countdown_string +=
            (countdown_minutes / 1440).floor().toString() + " ימים ו ";
        countdown_minutes = countdown_minutes % 1440;
      }
      if (countdown_minutes >= 60) {
        countdown_string +=
            (countdown_minutes / 60).floor().toString() + " שעות.";
        //countdown_minutes = countdown_minutes % 60;
      }
      //countdown_string += countdown_minutes.toString() + " דקות";
    } else if (countdown_minutes == 0) {
      countdown_string = "האירוע מתקיים כעת!";
    } else {
      countdown_string = "האירוע נגמר ";
    }
    return countdown_string;
  }

  @override
  Widget build(BuildContext context) {
    Future creator = widget.getUser(widget.event!.creatorUser);

    int countdown_minutes = widget.event!.startIn;
    String countdown_string = FormatCountdownString(context, countdown_minutes);
    String type = widget.event?.type == "H" ? "חברותא" : "שיעור";
    String topic = widget.event?.topic?.trim() ?? "";
    String book = widget.event?.book?.trim() ?? "";
    String t_event_type = widget.event!.type == "H" ? "חברותא" : "שיעור";
    String t_book_name =
        widget.event!.book != "" ? " ב" + widget.event!.book! : "";
    String t_topic =
        widget.event!.topic != "" ? " ב" + widget.event!.topic! : "";
    String study = book == "" ? topic : "";
    study = topic != "" && book != "" ? topic + "/ " + book : topic + book;
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
    String duration = widget.event!.duration.toString() + " דקות";
    var myMail = Globals.currentUser!.email;
    bool notMyTarget = !Globals.currentUser!.isTargetedForMe(widget.event!);
    var amIParticipant = widget.event!.participants!.contains(myMail);
    var amICreator = widget.event!.creatorUser == myMail;
    var remainedPlaces = widget.event!.maxParticipants! -
        widget.event!.participants!.length; /*-waitingQueue.length*/
    String t_pre = "*הודעת תפוצה*" + "\n";
    String t_suffix = t_event_type + t_topic + t_book_name + ":\n";

    var initPub =
        (bool wq) => t_pre + (wq ? "למבקשים להצטרף ל" : "למשתתפי ה") + t_suffix;

    var rejectOrAcceptFactory = (func) => (userMail) {
          showModalBottomSheet(
            context: context,
            builder: ((builder) => bottomSheet(context, () async {
                  Navigator.pop(context);
                  await func(userMail);
                  refresh();
                }, () => Navigator.pop(context))),
          );
        };
    var reject = rejectOrAcceptFactory((userMail) async {
      await widget.event!.reject(userMail);
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
    });
    var accept = rejectOrAcceptFactory((userMail) async {
      await widget.event!.accept(userMail);
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
    });

    return FutureBuilder(
        future: creator,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: LoadingBouncingGrid.square(
                  borderColor: Colors.teal[400]!,
                  backgroundColor: Colors.teal[400]!,
                  size: 20.0,
                ),
              );
            case ConnectionState.done:
              return Scaffold(
                appBar: AppBar(
                    title: Text(type),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: ArcBannerImage(widget.event!.eventImage,
                        imgHeight: 80.0),
                    actions: [
                      CircleAvatar(
                        //TODO: shreenk
                        foregroundImage: NetworkImage(snapshot.data['avatar']),
                        backgroundColor: Colors.transparent,
                        radius: 60.0, //here
                        child: IconButton(
                            icon: Icon(Icons.quiz_sharp),
                            iconSize: 40.0,
                            //color: Colors.white.withOpacity(0),
                            color: Colors.white.withOpacity(0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserScreen(snapshot.data['email'])),
                              );
                            }),
                      )
                    ]),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        child: Text('Drawer Header'),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
                      ListTile(
                        title: Text('פורום'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                        },
                      ),
                      ListTile(
                        title: Text('לוח זמנים מלא'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                        },
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("לימוד:",
                          textDirection: ui.TextDirection.rtl,
                          style: GoogleFonts.alef(
                              fontSize: 16.0, color: Colors.grey[700])),
                      Text(study,
                          textDirection: ui.TextDirection.rtl,
                          style: GoogleFonts.secularOne(fontSize: 20.0)),
                      // times should be exported to a function together with countdown
                      Text(
                        (widget.event!.dates!.isNotEmpty &&
                                isNow(widget.event!.dates![0],
                                    widget.event!.duration ?? 0))
                            ? "   האירוע מתקיים כעת ב:    "
                            : "   האירוע מתקיים ב:    ",
                        style: GoogleFonts.secularOne(fontSize: 14.0),
                        //textAlign: TextAlign.end,
                        textDirection: ui.TextDirection.rtl,
                      ),
                      Text(
                        time == ""
                            ? ""
                            : (isNow(widget.event!.dates![0],
                                    widget.event!.duration ?? 0)
                                ? nextEvent + "    בשעה  " + time
                                : nextEvent + "   בשעה  " + time),
                        style: GoogleFonts.secularOne(fontSize: 20.0),
                        textAlign: TextAlign.center,
                        textDirection: ui.TextDirection.rtl,
                      ),
                      // countdown
                      Text(countdown_string,
                          textDirection: ui.TextDirection.rtl,
                          style: GoogleFonts.alef(
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 40, 204, 29))),
                      Text("תיאור:", // TODO: remove
                          textDirection: ui.TextDirection.rtl,
                          style: GoogleFonts.alef(
                              fontSize: 16.0, color: Colors.grey[700])),
                      Text(widget.event!.description.toString(), // TODO: remove
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
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
                      Divider(),
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
                      widget.event!.type == "L" || amIParticipant || amICreator
                          ? ParticipentsScroller(
                              //TODO: edit widget
                              widget.event!.participants,
                              title: "משתתפים",
                              initPubMsgText: initPub(false),
                            )
                          : Container(),
                      amICreator && widget.event!.type == 'H'
                          ? ParticipentsScroller(
                              widget.event!.waitingQueue,
                              title: "ממתינים לאישור",
                              initPubMsgText: initPub(true),
                              accept: accept,
                              reject: reject,
                            )
                          : Container(),
                      SizedBox(height: Globals.scaler.getHeight(1)),
                    ],
                  ),
                ),
              );
            default:
              return Text('default');
          }
        });
  }
}
