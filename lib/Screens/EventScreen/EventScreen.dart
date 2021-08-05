import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:loading_animations/loading_animations.dart';
import 'Event_details_page.dart';

class EventScreen extends StatelessWidget {
  final Event event;
  Future<Event> eventUpdate;

  EventScreen(this.event);

  @override
  Widget build(BuildContext context) {
    eventUpdate = Globals.db.getEventById(this.event.id);
    return new WillPopScope(
        onWillPop: () async {
          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: Scaffold(
            body: FutureBuilder(
                future: eventUpdate,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('none');
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return Center(
                        child: LoadingBouncingGrid.square(
                          borderColor: Colors.teal[400],
                          backgroundColor: Colors.teal[400],
                          size: 80.0,
                        ),
                      );
                    case ConnectionState.done:
                      print(snapshot.data);
                      return EventDetailsPage(snapshot.data);
                    default:
                      return Text('default');
                  }
                })));
  }
}
