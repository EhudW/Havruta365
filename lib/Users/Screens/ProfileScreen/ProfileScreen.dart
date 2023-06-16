import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase/DataRepresentations/User.dart';
import 'package:havruta_project/Globals.dart';
import 'ProfileDetailsPage.dart';

class ProfileScreen extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final User? curr_user = Globals.currentUser;

  @override
  Widget build(BuildContext context) {
    return ProfileDetailsPage(curr_user);
  }
}
