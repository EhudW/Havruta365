//import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Center;
import '../UserScreen/UserScreen.dart';
import 'arc_banner_image.dart';
//import 'poster.dart';

// ignore: must_be_immutable
class EventDetailHeader extends StatelessWidget {
  EventDetailHeader(Event? event) {
    this.event = event;
    this.userColl = Globals.db!.db.collection('Users');
  }

  Event? event;
  var userColl;

  Future getUser(String? userMail) async {
    var user = await userColl.findOne(where.eq('email', '$userMail'));
    return user;
  }

  @override
  Widget build(BuildContext context) {
    Future creator = getUser(event!.creatorUser);
    // havruta('H') teacher is the creator, shiur('L') this is event.lecturer
    String teacher =
        event!.type == 'L' ? event!.lecturer! : event!.creatorName!;
    // should we add extra text to differ between teacher and creator?
    var asBasic = (String str) => str.toLowerCase().trim();
    var myCmp = (a, b) => asBasic(a) == asBasic(b);
    // indeed, if they are 2 different persons
    // type = 'H'  => creator_description == ""
    // type = 'L'  && lecturer "same" as creator => creator_description == ""
    // type = 'L'  && lecturer not "same" as creator => creator_description == creator
    String creatorDescription =
        myCmp(teacher, event!.creatorName!) ? "" : event!.creatorName!;

    var movieInformation = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
        ),
        Text(
          event!.topic!,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 26.0),
          textAlign: TextAlign.center,
        ),
        Text(
          event!.book!,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 22.0),
          textAlign: TextAlign.center,
        ),
        Text(
          teacher,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 22.0),
          textAlign: TextAlign.center,
        ),
      ],
    );
    return FutureBuilder(
        future: creator,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: LoadingBouncingGrid.square(
                  borderColor: Colors.teal[400]!,
                  backgroundColor: Colors.teal[400]!,
                  size: 20.0,
                ),
              );
            case ConnectionState.done:
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: ArcBannerImage(event!.eventImage),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 16.0,
                    right: 16.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        movieInformation,
                        SizedBox(
                          width: 60,
                        ),
                        //SizedBox(width: 16.0),

                        Column(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data['avatar']),
                              radius: 60.0,
                              child: IconButton(
                                  icon: Icon(Icons.quiz_sharp),
                                  iconSize: 40.0,
                                  color: Colors.white.withOpacity(0),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserScreen(
                                              snapshot.data['email'])),
                                    );
                                  }),
                            ),
                            Text(
                              creatorDescription == "" ? "" : "ביוזמת",
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            Text(
                              creatorDescription,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
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
