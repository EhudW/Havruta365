import 'package:flutter/material.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/screens/event_page/event_screen.dart';
import 'package:havruta_project/mydebug.dart';

import '../../../Globals.dart';

class EventOnlineFeed extends StatelessWidget {
  final Event event;

  const EventOnlineFeed({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Stack(children: <Widget>[
          Container(
              width: Globals.scaler.getWidth(10),
              height: Globals.scaler.getHeight(6),
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        event.eventImage ?? MyConsts.DEFAULT_EVENT_IMG)),
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
                color: Colors.redAccent,
              ),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: Offset(0, 1),
                          )
                        ]),
                    width: Globals.scaler.getWidth(10),
                    child: Text(
                        (event.book?.trim() ?? "") != ""
                            ? event.book!.trim()
                            : (event.topic ?? ""),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Globals.scaler.getTextSize(6),
                            color: Colors.white)),
                  ))),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EventScreen(event.id)));
              },
            ),
          ),
        ),
      ],
    );
  }
}
