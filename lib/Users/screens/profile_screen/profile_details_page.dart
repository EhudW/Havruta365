//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
//import 'package:havruta_project/Screens/ProfileScreen/interestsList.dart';
import 'package:havruta_project/users/screens/profile_screen/profile_details_column.dart';
//import 'package:havruta_project/Screens/UserScreen/user_details_column.dart';
import 'profile_detail_header.dart';
import 'package:havruta_project/globals.dart';

// ignore: must_be_immutable
class ProfileDetailsPage extends StatefulWidget {
  User? user;

  ProfileDetailsPage(User? user) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProfileDetailHeader(widget.user),
            SizedBox(height: Globals.scaler.getHeight(4)),
            ProfileDetailsColumn(widget.user),
          ],
        ),
      ),
    );
  }
}
