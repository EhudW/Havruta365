import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/screens/event_scroller_screen/events.dart';
//import 'package:havruta_project/data_base_auth/User.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/event/screens/event_page/event_screen.dart';
import 'package:havruta_project/event/model/events_model.dart';
import 'package:havruta_project/mydebug.dart';
//import 'package:havruta_project/Screens/EventScreen/Event_api.dart';
//import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:loading_animations/loading_animations.dart';

// ignore: must_be_immutable
class EventsScroller extends StatefulWidget {
  EventsScroller(this.userMail);

  String? userMail;

  @override
  _EventsScrollerState createState() => _EventsScrollerState();
}

class _EventsScrollerState extends State<EventsScroller> {
  Future? eventsList;
  List<Event>? events;

  @override
  void initState() {
    super.initState();
    throw Exception("this .dart file not in used");
    //eventsList = Globals.db!.getEvents(widget.userMail, true, null);
  }

  Widget _buildEvent(BuildContext ctx, int index) {
    if (index == 0) {
      return Padding(
        padding: EdgeInsets.only(right: Globals.scaler.getWidth(1.5)),
        child: Column(
          children: [
            CircleAvatar(
              //backgroundImage: NetworkImage(event.eventImage!),
              backgroundColor: Colors.grey.withOpacity(0.2),
              radius: 30.0,
              child: IconButton(
                  icon: Icon(Icons.list),
                  iconSize: Globals.scaler.getWidth(3),
                  color: Colors.teal.withOpacity(1),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Events(
                              EventsModel(
                                false,
                              ),
                              null),
                        ));
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: Globals.scaler.getHeight(0)),
              child: Text("רשימה מלאה",
                  style: GoogleFonts.secularOne(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl),
            ),
          ],
        ),
      );
    }
    index = index - 1;
    var event = events![index];
    String subject = event.book!;
    subject = subject.trim() == "" ? event.topic! : subject;
    String teacher = event.lecturer!;
    teacher = teacher.trim() == "" ? event.creatorName! : teacher;
    return Padding(
      padding: EdgeInsets.only(right: Globals.scaler.getWidth(1.5)),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(event.eventImage ?? MyConsts.DEFAULT_EVENT_IMG),
            radius: 30.0,
            child: IconButton(
                icon: Icon(FontAwesomeIcons.houseUser),
                iconSize: Globals.scaler.getWidth(5),
                color: Colors.white.withOpacity(0),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventScreen(event.id),
                      ));
                }),
          ),
          Padding(
            padding: EdgeInsets.only(top: Globals.scaler.getHeight(0)),
            child: Column(
              children: [
                Text(subject,
                    style: GoogleFonts.secularOne(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl),
                Text(teacher, textDirection: TextDirection.rtl)
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
        future: eventsList,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: LoadingBouncingGrid.circle(
                  borderColor: Colors.teal[400]!,
                  backgroundColor: Colors.teal[400]!,
                  size: 40.0,
                ),
              );
            case ConnectionState.done:
              events = snapshot.data as List<Event>?;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.fromSize(
                    size: Size.fromHeight(Globals.scaler.getHeight(5)),
                    child: ListView.builder(
                      itemCount: events!.length,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(top: 0, left: 20.0),
                      itemBuilder: _buildEvent,
                    ),
                  ),
                ],
              );
            default:
              return Text('default');
          }
        });
  }
}
