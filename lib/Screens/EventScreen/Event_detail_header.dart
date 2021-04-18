import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/EventScreen/Event_api.dart';
import 'arc_banner_image.dart';
import 'poster.dart';

class EventDetailHeader extends StatelessWidget {
  EventDetailHeader(this.event);
  final Event event;


  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var movieInformation = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.center,
          child: Text(
            event.topic,
            style: TextStyle(fontFamily: 'sdgsg', fontSize: 25),
            textAlign: TextAlign.center,
          ),
        ),

        // SizedBox(height: 12.0),
        Align(
          alignment: AlignmentDirectional.center,
          child: Text(
            event.book,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.center,
          child: Text(
            event.lecturer,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 90.0),
          child: ArcBannerImage(event.eventImage),
        ),
        Positioned(
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: movieInformation),
              //SizedBox(width: 16.0),
              CircleAvatar(
                backgroundImage: NetworkImage(event.creatorUser.avatar),
                radius: 60.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
