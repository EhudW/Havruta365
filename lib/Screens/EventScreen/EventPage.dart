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

  @override
  Widget build(BuildContext context) {
    Future creator = widget.getUser(widget.event!.creatorUser);

    String type = widget.event?.type == "H" ? "חברותא" : "שיעור";
    String topic = widget.event?.topic?.trim() ?? "";
    String book = widget.event?.book?.trim() ?? "";
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
    bool notMyTarget = !Globals.currentUser!.isTargetedForMe(widget.event!);

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
                      Text("TODO: Countdown",
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
                      // participants
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
