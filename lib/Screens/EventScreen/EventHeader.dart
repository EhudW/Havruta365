import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/FCM/fcm.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/Chat1v1.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Center;
import '../UserScreen/UserScreen.dart';
import 'arc_banner_image.dart';

class EventHeader extends StatelessWidget {
  EventHeader(Event? event) {
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

    String type = event?.type == "H" ? "חברותא" : "שיעור";
    String book = event?.book?.trim() ?? "";
    String topic = event?.topic?.trim() ?? "";
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
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: ArcBannerImage(event!.eventImage, imgHeight: 40.0),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(type,
                        style: GoogleFonts.assistant(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 10.0,
                    right: 10.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment
                          .end, //TODO: change to start or remove
                      children: [
                        /*SizedBox(
                          width: 60,
                        ),*/
                        //SizedBox(width: 16.0),

                        CircleAvatar(
                          //TODO: shreenk
                          backgroundImage:
                              NetworkImage(snapshot.data['avatar']),
                          radius: 30.0, //here
                          child: IconButton(
                              icon: Icon(Icons.quiz_sharp),
                              iconSize: 20.0,
                              color: Colors.white.withOpacity(0),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserScreen(snapshot.data['email'])),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    // TODO: move into sandwich
                    top: 100,
                    child: Scaffold(
                      appBar: AppBar(title: Text(type)),
                      body: const Center(
                        child: Text('My Page!'),
                      ),
                      drawer: Drawer(
                        // Add a ListView to the drawer. This ensures the user can scroll
                        // through the options in the drawer if there isn't enough vertical
                        // space to fit everything.
                        child: ListView(
                          // Important: Remove any padding from the ListView.
                          padding: EdgeInsets.zero,
                          children: [
                            const DrawerHeader(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                              ),
                              child: Text('Drawer Header'),
                            ),
                            ListTile(
                              title: const Text('Item 1'),
                              onTap: () {
                                // Update the state of the app
                                // ...
                                // Then close the drawer
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('Item 2'),
                              onTap: () {
                                // Update the state of the app
                                // ...
                                // Then close the drawer
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    /*child: ElevatedButton.icon(
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
                        label: Text("forum")),*/
                  ),
                ],
              );
            default:
              return Text('default');
          }
        });
  }
}
