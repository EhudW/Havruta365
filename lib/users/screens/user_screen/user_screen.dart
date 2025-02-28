import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:havruta_project/data_base_auth/Event.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/widgets/my_future_builder.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' hide Center;
import 'user_details_page.dart';

Future<User> getUser(String? userMail) async {
  var coll = Globals.db!.db.collection('Users');
  // ignore: non_constant_identifier_names
  var user_json = await coll.findOne(where.eq('email', '$userMail'));
  User user = User.fromJson(user_json);
  return user;
}

class UserScreen extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final String? user_mail;
  UserScreen(this.user_mail);
  @override
  Widget build(BuildContext context) {
    var user = getUser(user_mail);
    var screenContent = (dynamic snapshot) => Scaffold(
          body: UserDetailsPage(snapshot.data as User),
        );
    return myFutureBuilder(user, screenContent, isCostumise: false);
  }
}
