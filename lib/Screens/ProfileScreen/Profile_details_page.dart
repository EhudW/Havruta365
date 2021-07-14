import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/ProfileScreen/interestsList.dart';
import 'package:havruta_project/Screens/ProfileScreen/profile_details_column.dart';
import 'package:havruta_project/Screens/UserScreen/user_details_column.dart';
import 'Profile_detail_header.dart';
import 'package:havruta_project/Globals.dart';

class ProfileDetailsPage extends StatefulWidget {
  User user;

  ProfileDetailsPage(User user) {
    this.user = user;
  }

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            ProfileDetailHeader(widget.user),
            SizedBox(height: Globals.scaler.getHeight(0)),
            // Divider(
            //   thickness: 0,
            //   indent: 10,
            //   endIndent: 10,
            // ),
            SizedBox(height: Globals.scaler.getHeight(1.5)),
            ProfileDetailsColumn(widget.user),
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
