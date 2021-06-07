import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'User_details_page.dart';

Future<User> getUser(String userMail) async {
  var coll = Globals.db.db.collection('Users');
  var user_json = await coll.findOne(where.eq('email', '$userMail'));
  User user = User.fromJson(user_json);
  return user;
}

class UserScreen extends StatelessWidget {
  final String user_mail;
  UserScreen(this.user_mail);
  @override
  Widget build(BuildContext context) {
    var user = getUser(user_mail);
    return FutureBuilder(
        future: user,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: LoadingBouncingGrid.square(
                  borderColor: Colors.teal[400],
                  backgroundColor: Colors.teal[400],
                  size: 80.0,
                ),
              );
            case ConnectionState.done:
              return Scaffold(
                appBar: CustomAppBar(
                  title: 'פרטי משתמש',
                  gradientBegin: Colors.blue,
                  gradientEnd: Colors.greenAccent,
                ),
                body: UserDetailsPage(snapshot.data),
              );
            default:
              return Text('default');
          }
        });
  }
}
