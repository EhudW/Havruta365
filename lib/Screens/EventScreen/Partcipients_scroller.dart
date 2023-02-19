import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' hide Center;

// ignore: must_be_immutable
class ParticipentsScroller extends StatelessWidget {
  ParticipentsScroller(List<dynamic>? usersMail,
      {this.title = "משתתפים", this.accept, this.reject}) {
    this.usersMail = usersMail ?? [];
    this.userColl = Globals.db!.db.collection('Users');
  }
  String title;
  var usersMail;
  var userColl;
  void Function(String)? accept;
  void Function(String)? reject;

  Future getUser(String? userMail) async {
    var user = await userColl.findOne(where.eq('email', '$userMail'));
    return user;
  }

  Widget _buildActor(BuildContext ctx, int index) {
    var userMail = usersMail[index];
    // TODO find user via mail and get it from the mongo
    // build user: avatar, name, button to the user profile
    //Future<User> user = Globals.db.getUser(userMail);
    // var user = await collection.findOne(where.eq('email', '$mail'));
    Future user = getUser(userMail);
    return FutureBuilder(
      future: user,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: LoadingBouncingGrid.square(
                borderColor: Colors.teal[400]!,
                backgroundColor: Colors.teal[400]!,
                size: 20.0,
              ),
            );
          case ConnectionState.done:
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 0.0), //was 16.0
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data['avatar']),
                        radius: 40.0,
                        child: IconButton(
                            icon: Icon(FontAwesomeIcons.houseUser),
                            iconSize: 40.0,
                            color: Colors.white.withOpacity(0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserScreen(snapshot.data['email'])),
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(snapshot.data['name']),
                      ),
                    ],
                  ),
                ),
                accept == null
                    ? SizedBox()
                    : TextButton(
                        onPressed: () => accept!(userMail),
                        child: Text("אשר"),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white)),
                reject == null
                    ? SizedBox()
                    : TextButton(
                        onPressed: () => reject!(userMail),
                        child: Text("דחה"),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white))
              ],
            );
          default:
            return Text('default');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var textTheme = Theme.of(context).textTheme;
    double extraHeight = 0;
    extraHeight += accept != null ? ScreenScaler().getHeight(3) : 0;
    extraHeight += reject != null ? ScreenScaler().getHeight(3) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        SizedBox.fromSize(
          size: Size.fromHeight(
              usersMail.length > 0 ? (120.0 + extraHeight) : 40),
          child: usersMail.length == 0
              ? Center(child: Text("- אין -"))
              : ListView.builder(
                  itemCount: usersMail.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(top: 12.0, left: 20.0),
                  itemBuilder: _buildActor,
                ),
        ),
      ],
    );
  }
}
