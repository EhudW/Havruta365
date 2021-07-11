import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/UserScreen/contact_buttons.dart';
import 'package:havruta_project/Screens/UserScreen/user_details_column.dart';
import 'User_detail_header.dart';
import 'interestsList.dart';

class UserDetailsPage extends StatefulWidget {
  User user;

  UserDetailsPage(User user) {
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
            SizedBox(height: 5),
            // Contact buttons
            Center(
              child: ContactButtons(widget.user),
            ),
            SizedBox(height: 10),
            Divider(
              thickness: 2.0,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
              child: UserDetailsColumn(widget.user),
            ),
            Divider(
              thickness: 2.0,
              indent: 10,
              endIndent: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20),
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
