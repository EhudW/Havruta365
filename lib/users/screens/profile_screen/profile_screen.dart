import 'package:flutter/material.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/globals.dart';
import 'profile_details_page.dart';

class ProfileScreen extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final User? curr_user = Globals.currentUser;

  @override
  Widget build(BuildContext context) {
    return ProfileDetailsPage(curr_user);
  }
}
