import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'arc_banner_image.dart';
import 'poster.dart';

class EventDetailHeader extends StatelessWidget {
  EventDetailHeader(Event event) {
    this.event = event;
    this.userColl = Globals.db.db.collection('Users');
  }

  Event event;
  var userColl;

  Future getUser(String userMail) async {
    var user = await userColl.findOne(where.eq('email', '$userMail'));
    return user;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    Future creator = getUser(event.creatorUser);
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
    return FutureBuilder(future: creator ,builder: (context, snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.none:
          return Text('none');
        case ConnectionState.active:
        case ConnectionState.waiting:
          return Center(
            child: LoadingBouncingGrid.square(
              borderColor: Colors.teal[400],
              backgroundColor: Colors.teal[400],
              size: 20.0,
            ),
          );
        case ConnectionState.done:
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
                      backgroundImage: NetworkImage(snapshot.data['avatar']),
                      radius: 60.0,
                    ),
                  ],
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
