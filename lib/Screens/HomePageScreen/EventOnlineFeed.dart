import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';

class EventOnlineFeed extends StatelessWidget {
  final Event event;

  const EventOnlineFeed({
    Key key,
    @required this.event,
  })  : assert(event != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Stack(children: <Widget>[
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(event.eventImage)),
              borderRadius: BorderRadius.all(Radius.circular(0.0)),
              color: Colors.redAccent,
            ),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(event.topic,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black)))
          ),
        ]),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.red,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EventScreen(event)));
              },
            ),
          ),
        ),
      ],
    );
  }
}
