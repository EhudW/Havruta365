import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButtons extends StatelessWidget {
  ContactButtons(this.user);

  final User user;
  ButtonStyle buttonStyleMessage = ButtonStyle(
    padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      )),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[300]));
  ButtonStyle buttonStyleIcon = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          )),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[300]));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mail button
        ElevatedButton(
          onPressed: () => launch("mailto:${user.email}?subject=חברותא&body="),
          style: buttonStyleIcon,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                FontAwesomeIcons.envelope,
                color: Colors.black,
              )
            ],
          ),
        ),
        SizedBox(width: 10),
        // Call button
        ElevatedButton(
          onPressed: () => launch("tel:${user.phone}"),
          style: buttonStyleIcon,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                FontAwesomeIcons.phoneAlt,
                color: Colors.black,
              )
            ],
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {},
          style: buttonStyleMessage,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("הודעה",
              style: GoogleFonts.alef(
                  fontSize: 16,
                  textStyle: TextStyle(color: Colors.black, letterSpacing: 2),
                  fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,),
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
    );
  }
}
