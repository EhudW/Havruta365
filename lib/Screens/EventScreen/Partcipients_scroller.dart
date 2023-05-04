import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/Chat1v1.dart';
import 'package:havruta_project/Screens/ChatScreen/SendScreen.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' hide Center;
import 'dart:ui' as ui;

// ignore: must_be_immutable
class ParticipentsScroller extends StatelessWidget {
  String initPubMsgText;
  ParticipentsScroller(List<dynamic>? usersMail,
      {this.title = "משתתפים",
      this.accept,
      this.reject,
      required this.initPubMsgText}) {
    this.usersMail = usersMail ?? [];
    this.userColl = Globals.db!.db.collection('Users');
  }
  String title;
  var usersMail;
  var userColl;
  void Function(String)? accept;
  void Function(String)? reject;
  //bool get hasButton => reject != null || accept != null;
  final bool hasButton = true;
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
            var profile = [
              CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data['avatar']),
                radius: 20.0,
                child: IconButton(
                    icon: Icon(FontAwesomeIcons.houseUser),
                    iconSize: 20.0,
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
                padding: EdgeInsets.only(
                    top: hasButton ? 0 : 8.0, left: hasButton ? 16 : 0),
                child: Text(snapshot.data['name'],
                    textDirection: ui.TextDirection.rtl),
              ),
            ];
            var profileInk = InkWell(
              child: hasButton
                  ? Row(children: profile)
                  : Column(children: profile),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserScreen(snapshot.data['email'])),
                );
              },
            );
            List<Widget> _inner = [
              //Padding(
              //  padding: EdgeInsets.only(right:0),// hasButton?0:16,top:hasButton?16:0), //was 16.0
              //  child:
              profileInk,
              //),
              Row(children: [
                accept == null
                    ? SizedBox()
                    : TextButton(
                        onPressed: () => accept!(userMail),
                        child: Text("אשר"),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white)),
                SizedBox(
                  width: 8,
                ),
                reject == null
                    ? SizedBox()
                    : TextButton(
                        onPressed: () => reject!(userMail),
                        child: Text("דחה"),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white)),
                SizedBox(
                  width: 8,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    otherPerson: snapshot.data['email'],
                                    otherPersonName: snapshot.data['name'],
                                  )));
                    },
                    child: Text('צאט'),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white))
              ])
            ];
            _inner = _inner
                .map((e) => Container(
                      padding: EdgeInsets.only(
                          top: hasButton ? 16 : 0, left: hasButton ? 0 : 16),
                      margin: hasButton ? EdgeInsets.only(left: 16) : null,
                      child: e,
                    ))
                .toList();
            return hasButton
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _inner,
                  )
                : Column(
                    children: _inner,
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
    //double extraHeight = 0;
    //extraHeight += accept != null ? ScreenScaler().getHeight(3) : 0;
    //extraHeight += reject != null ? ScreenScaler().getHeight(3) : 0;
    double totalscrollheight = hasButton ? 120 : 150;
    if (hasButton && usersMail.length > 0) {
      totalscrollheight =
          totalscrollheight * (usersMail.length <= 2 ? usersMail.length : 2);
    }
    totalscrollheight = usersMail.length > 0 ? totalscrollheight : 50;
    dynamic list = ListView.builder(
      itemCount: usersMail.length,
      scrollDirection: hasButton ? Axis.vertical : Axis.horizontal,
      padding: EdgeInsets.only(
          top: 0,
          left: hasButton ? 16 : 0,
          right: 16,
          bottom: hasButton ? 16 : 0),
      itemBuilder: _buildActor,
    );
    list = SizedBox.fromSize(
      size: Size.fromHeight(totalscrollheight),
      child: Padding(
          child: usersMail.length == 0 ? Center(child: Text("- אין -")) : list,
          padding: EdgeInsets.only(top: 16)),
    );
    if (hasButton) {
      list = Column(
          children: List.generate(
              usersMail.length,
              (index) => Padding(
                    padding: EdgeInsets.only(
                        top: 0,
                        left: hasButton ? 8 : 0,
                        right: 16,
                        bottom: hasButton ? 16 : 0),
                    child: _buildActor(context, index),
                  )));
      list = Padding(
          child: usersMail.length == 0 ? Center(child: Text("- אין -")) : list,
          padding: EdgeInsets.only(top: 16));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                usersMail.isNotEmpty
                    ? ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SendScreen(usersMail, this.initPubMsgText),
                            )),
                        icon: Icon(FontAwesomeIcons.envelope, size: 18),
                        label: Text("שליחת הודעה לרשימה זו"),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red[700])),
                      )
                    : Container(),
                Text(
                  title,
                  textDirection: ui.TextDirection.rtl,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        list
      ],
    );
  }
}
