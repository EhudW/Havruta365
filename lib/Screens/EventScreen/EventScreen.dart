import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/EventsSelectorBuilder.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart' as m;
import 'Event_details_page.dart';

class EventScreen extends StatefulWidget {
  final m.ObjectId eventId;

  EventScreen(this.eventId);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Future<List<dynamic>>? f; //[eventUpdate,allUserEvents];

  @override
  Widget build(BuildContext context) {
    Future<Event?> eventUpdate = Globals.db!.getEventById(this.widget.eventId);
    Future<List<Event>> allUserEvents =
        //Globals.db!.getAllEventsAndCreated(null, true, null);
        EventsSelectorBuilder.IinvolvedIn(
            myMail: Globals.currentUser!.email!,
            filterOldEvents: true,
            startFrom: null,
            maxEvents: null);
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
                  if (data[0] == null) {
                    return NoEventScreen();
                  }
                  return EventDetailsPage(
                      data[0] as Event?, data[1] as List<Event>?);
                default:
                  return Text('default');
              }
            }));
  }
}

class NoEventScreen extends StatelessWidget {
  const NoEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "האירוע לא נמצא\nככל הנראה נמחק",
            textAlign: TextAlign.right,
          )),
          Center(
              child: ElevatedButton(
            child: Text("חזרה"),
            onPressed: () => Navigator.pop(context),
          )),
        ],
      ),
    );
  }
}
