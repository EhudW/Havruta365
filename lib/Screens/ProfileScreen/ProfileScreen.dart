import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'Profile_details_page.dart';

class ProfileScreen extends StatelessWidget {

  final User curr_user = Globals.currentUser;

  @override
  Widget build(BuildContext context) {
    return ProfileDetailsPage(curr_user);
  }

}
