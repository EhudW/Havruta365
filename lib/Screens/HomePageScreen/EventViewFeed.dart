import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';

class EventViewFeed extends StatelessWidget {
  final Event event;

  const EventViewFeed({
    Key key,
    @required this.event,
  })  : assert(event != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
            splashColor: Colors.teal[400],
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            onTap: () {
              print(event.toJson());
              Navigator.push(context, MaterialPageRoute(builder: (context) => EventScreen(event)));
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Container(
                    width: 250.0,
                    height: 100.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: 10),
                        Text(
                          event.book,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          event.book,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(flex: 3, child:Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[Text(
                              event.participants.length.toString(),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 14),
                            ),
                            SizedBox(width: 10),
                            Icon(FontAwesomeIcons.users,
                                size: 20, color: Colors.red)])),
                            SizedBox(width: 40),
                    Expanded(flex: 2, child:Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[ Text(
                              event.topic,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 14),
                            ),
                            SizedBox(width: 10),
                            Icon(FontAwesomeIcons.clock,
                                size: 20, color: Colors.red)]))
                          ])
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(4.0),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent[400],
                        borderRadius: const BorderRadius.all(
                          Radius.circular(60.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.teal[400],
                              offset: const Offset(2, 0),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          event.eventImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          event.topic,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ])
                ])));
  }
}
