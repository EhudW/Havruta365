//import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase/DataRepresentations/Event.dart';
import 'package:havruta_project/Notifications/PushNotifications/Fcm.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Chat/Chat1v1.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Center;
import '../../../Users/Screens/UserScreen/UserScreen.dart';
import '../../Widgets/arc_banner_image.dart';
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
        // ? TODO: add a button to chat wwith the creator
        SizedBox(
          //TODO: remove this
          height: 50,
        ),
        Text(
          // TODO: add limud: before the text
          event!.topic!,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 26.0),
          textAlign: TextAlign.center,
        ),
        Text(
          event!.book!, //TODO: combine with topic
          textDirection: TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 22.0),
          textAlign: TextAlign.center,
        ),
        Text(
          //TODO: remove this
          teacher,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.secularOne(fontSize: 22.0),
          textAlign: TextAlign.center,
        ),
      ],
    );
    String topic = event?.topic?.trim() ?? "";
    String book = event?.book?.trim() ?? "";
    String type = event?.type == "H" ? "חברותא" : "שיעור";
    String t_book = book != "" ? " ב" + book : "";
    String t_topic = topic != "" ? " ב" + topic : "";
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
                    //TODO: shreenk the image
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: ArcBannerImage(
                        event!.eventImage ?? MyConsts.DEFAULT_EVENT_IMG),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 16.0,
                    right: 16.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment
                          .end, //TODO: change to start or remove
                      children: [
                        movieInformation,
                        SizedBox(
                          width: 60,
                        ),
                        //SizedBox(width: 16.0),

                        Column(
                          children: [
                            CircleAvatar(
                              //TODO: shreenk
                              backgroundImage:
                                  NetworkImage(snapshot.data['avatar']),
                              radius: 60.0, //here
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
                              // TODO: remove this
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
                  Positioned(
                    // TODO: move into sandwich
                    top: 200,
                    child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  otherPerson: event!.id.toString(),
                                  otherPersonName: event!.id.toString(),
                                  forumName: type + t_topic + t_book,
                                ),
                              ));
                        },
                        icon: Icon(Icons.abc),
                        label: Text("forum")),
                  ),
                ],
              );
            default:
              return Text('default');
          }
        });
  }
}
