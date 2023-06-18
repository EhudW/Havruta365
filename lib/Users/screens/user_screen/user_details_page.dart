//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/users/screens/user_screen/user_details_column.dart';
import 'package:havruta_project/users/widgets/contact_buttons.dart';
import 'user_detail_header.dart';
//import 'interestsList.dart';
import 'package:havruta_project/globals.dart';

// ignore: must_be_immutable
class UserDetailsPage extends StatefulWidget {
  User? user;

  UserDetailsPage(User? user) {
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
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            // Contact buttons
            Center(
              child: ContactButtons(widget.user),
            ),
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            Divider(
              thickness: 2.0,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Globals.scaler.getHeight(0),
                Globals.scaler.getWidth(0),
                Globals.scaler.getHeight(0),
                Globals.scaler.getHeight(0.5),
              ),
              child: UserDetailsColumn(widget.user),
            ),
            // Divider(
            //   thickness: 2.0,
            //   indent: 10,
            //   endIndent: 10,
            // ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(
            //       Globals.scaler.getWidth(2),
            //       Globals.scaler.getHeight(0),
            //       Globals.scaler.getWidth(2),
            //       Globals.scaler.getHeight(0)),
            //   child: InterestsList(widget.user.interestList),
            // ),
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
