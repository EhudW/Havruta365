import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'package:havruta_project/Screens/EventScreen/datesList.dart';
import 'package:havruta_project/Screens/UserScreen/user_details_column.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Partcipients_scroller.dart';
import 'User_detail_header.dart';
import 'interestsList.dart';
import 'story_line.dart';


class UserDetailsPage extends StatefulWidget {
  User user;
  UserDetailsPage(User user){
    this.user = user;
  }

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserDetailHeader(widget.user),
            SizedBox(height: 10.0),
            UserDetailsColumn(widget.user),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 40.0, 20),
              child: InterestsList(widget.user.interestList),
            ),
            // MyProgressButton(id: widget.event.id, link: widget.event.link),
            // SizedBox(height: 20.0),
            // ParticipentsScroller(widget.event.participants),
            // SizedBox(height: 10.0),
            // Link
          ],
        ),
      ),
    );
  }
}
