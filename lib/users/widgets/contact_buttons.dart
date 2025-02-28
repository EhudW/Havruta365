import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/event/screens/event_scroller_screen/my_events_page.dart';

import '../../globals.dart';
//import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ContactButtons extends StatelessWidget {
  ContactButtons(this.user);

  final User? user;
  ButtonStyle buttonStyleMessage = ButtonStyle(
      padding:
          MaterialStateProperty.all(EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      )),
      backgroundColor: MaterialStateProperty.all<Color?>(Colors.grey[300]));
  ButtonStyle buttonStyleIcon = ButtonStyle(
      padding:
          MaterialStateProperty.all(EdgeInsets.fromLTRB(50.0, 5.0, 50.0, 5.0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      )),
      backgroundColor: MaterialStateProperty.all<Color?>(Colors.grey[300]));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SingleChatScreen(
                              otherPerson: user!.email!,
                              otherPersonName: user!.name!,
                            )));
                //SendScreen(user!.email, user!.name)));
              },
              style: buttonStyleMessage,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "הודעה",
                    style: GoogleFonts.alef(
                        fontSize: 16,
                        textStyle:
                            TextStyle(color: Colors.black, letterSpacing: 2),
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    FontAwesomeIcons.facebookMessenger,
                    color: Colors.black,
                  )
                ],
              ),
            )
          ],
        ),
        // 2 button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyEventsPage(
                              title: "ביחד עם - " + user!.name!,

                              modelData: {
                                "withParticipant": Globals.currentUser!.email,
                                "withParticipant2": user!.email,
                                "createdBy": null
                              },
                              icon: FontAwesomeIcons.userGroup, //bookBookmark,
                              user2View: user!.email,
                            )));
              },
              style: buttonStyleMessage,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "שיעורים משותפים",
                    style: GoogleFonts.alef(
                        fontSize: 16,
                        textStyle:
                            TextStyle(color: Colors.black, letterSpacing: 2),
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    FontAwesomeIcons.userGroup,
                    color: Colors.black,
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
