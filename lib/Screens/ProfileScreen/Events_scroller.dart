import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'package:havruta_project/Screens/EventScreen/Event_api.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:loading_animations/loading_animations.dart';

class EventsScroller extends StatefulWidget {
  EventsScroller(this.userMail);

  String userMail;

  @override
  _EventsScrollerState createState() => _EventsScrollerState();
}

class _EventsScrollerState extends State<EventsScroller> {
  Future eventsList;
  List<Event> events;

  @override
  void initState() {
    super.initState();
    eventsList = Globals.db.getEvents(widget.userMail);
  }

  Widget _buildEvent(BuildContext ctx, int index) {
    var event = events[index];
    return Padding(
      padding: EdgeInsets.only(right: Globals.scaler.getWidth(1.5)),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(event.eventImage),
            radius: 30.0,
            child: IconButton(
                icon: Icon(FontAwesomeIcons.houseUser),
                iconSize: Globals.scaler.getWidth(5),
                color: Colors.white.withOpacity(0),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventScreen(event),
                      ));
                }),
          ),
          Padding(
            padding: EdgeInsets.only(top: Globals.scaler.getHeight(0)),
            child: Column(
              children: [
                Text(event.book,
                    style: GoogleFonts.secularOne(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl),
                Text(event.lecturer)
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  borderColor: Colors.teal[400],
                  backgroundColor: Colors.teal[400],
                  size: 40.0,
                ),
              );
            case ConnectionState.done:
              events = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.fromSize(
                    size: Size.fromHeight(Globals.scaler.getHeight(5)),
                    child: ListView.builder(
                      itemCount: events.length,
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
