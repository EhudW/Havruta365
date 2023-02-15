import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_animations/loading_animations.dart';
import 'Event_details_page.dart';

class EventScreen extends StatefulWidget {
  final Event event;

  EventScreen(this.event);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Future<List<dynamic>>? f; //[eventUpdate,allUserEvents];

  @override
  Widget build(BuildContext context) {
    Future<Event> eventUpdate = Globals.db!.getEventById(this.widget.event.id);
    Future<List<Event>> allUserEvents =
        Globals.db!.getAllEventsAndCreated(null, true, null);
    f = Future.wait([eventUpdate, allUserEvents]);
    return Scaffold(
        body: FutureBuilder(
            future: f,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: LoadingBouncingGrid.square(
                      borderColor: Colors.teal[400]!,
                      backgroundColor: Colors.teal[400]!,
                      size: 80.0,
                    ),
                  );
                case ConnectionState.done:
                  List<dynamic> data = snapshot.data! as List<dynamic>;
                  return EventDetailsPage(
                      data[0] as Event?, data[1] as List<Event>?);
                default:
                  return Text('default');
              }
            }));
  }
}
