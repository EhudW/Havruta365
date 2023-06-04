import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/Chat1v1.dart';
import 'package:havruta_project/Screens/ChatScreen/SendScreen.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' hide Center;
import 'dart:ui' as ui;

// ignore: must_be_immutable
class ParticipentsScroller extends StatefulWidget {
  String initPubMsgText;
  ParticipentsScroller(List<dynamic>? usersMail,
      {this.title = "משתתפים",
      this.accept,
      this.reject,
      required this.initPubMsgText,
      this.event}) {
    var current_user = Globals.currentUser!.email;
    this.is_creator = event!.creatorUser == current_user;
    this.usersMail = this.is_creator
        ? {event!.participants!, event!.waitingQueue!}.toList()
        : event!.participants!;
    this.usersMail.remove(current_user);
    this.usersMail = usersMail ?? [];
    this.selected_users = [];
    this.userColl = Globals.db!.db.collection('Users');
  }
  String title;
  var is_creator;
  var usersMail;
  var userColl;
  Event? event;
  var selected_users;
  void Function(String)? accept;
  void Function(String)? reject;

  @override
  State<ParticipentsScroller> createState() => _ParticipentsScrollerState();
}

class _ParticipentsScrollerState extends State<ParticipentsScroller> {
  //bool get hasButton => reject != null || accept != null;
  final bool hasButton = true;

  Future getUser(String? userMail) async {
    var user = await widget.userColl.findOne(where.eq('email', '$userMail'));
    return user;
  }

  Widget _creatorCommands() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      widget.reject == null
          ? SizedBox()
          : TextButton(
              onPressed: () =>
                  widget.selected_users.map((x) => widget.reject!(x)),
              child: Text("דחה"),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white)),
      SizedBox(
        width: 20,
      ),
      widget.accept == null
          ? SizedBox()
          : TextButton(
              onPressed: () =>
                  widget.selected_users.map((x) => widget.accept!(x)),
              child: Text("אשר"),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white)),
      SizedBox(
        width: 8,
      ),
    ]);
  }

  Widget _buildActor(BuildContext ctx, int index) {
    var userMail = widget.usersMail[index];
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

            /// Add mark box to allow the user select and mark a few users.
            bool check_box_value = widget.selected_users.contains(userMail);
            var multi_select_box = Checkbox(
              value: check_box_value,
              onChanged: (bool? value_) {
                setState(() {
                  if (value_!)
                    widget.selected_users.add(userMail);
                  else
                    widget.selected_users.remove(userMail);
                  check_box_value = value_!;
                });
              },
            );
            var profile = [
              widget.is_creator ? multi_select_box : Container(),
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
                child: Text(
                    snapshot.data['name'].length > 15
                        ? snapshot.data['name'].substring(0, 15) + '...'
                        : snapshot.data['name'],
                    textDirection: ui.TextDirection.rtl),
              ),
            ];
            var profileInk = InkWell(
              child: hasButton
                  ? Row(children: profile.reversed.toList())
                  : Column(children: profile),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserScreen(snapshot.data['email'])),
                );
              },
            );

            Icon icons = Icon(
              FontAwesomeIcons.solidCircleCheck,
              size: Globals.scaler.getTextSize(0),
              color: Colors.green,
            );
            if (widget.event!.participants!.contains(userMail))
              icons = Icon(
                FontAwesomeIcons.solidCircleCheck,
                size: Globals.scaler.getTextSize(8),
                color: Colors.green,
              ); // V
            if (widget.event!.rejectedQueue!.contains(userMail))
              Icon(
                FontAwesomeIcons.solidCircleXmark,
                size: Globals.scaler.getTextSize(8),
                color: Colors.red,
              );

            List<Widget> _inner = [
              //Padding(
              //  padding: EdgeInsets.only(right:0),// hasButton?0:16,top:hasButton?16:0), //was 16.0
              //  child:
              profileInk,
              //),
              Row(children: [
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
                  child: Icon(
                    FontAwesomeIcons.solidMessage,
                    size: Globals.scaler.getTextSize(8),
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                widget.is_creator
                    ? icons //X
                    : SizedBox.shrink()
              ])
            ];
            _inner = _inner.reversed
                .toList()
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
    if (hasButton && widget.usersMail.length > 0) {
      totalscrollheight = totalscrollheight *
          (widget.usersMail.length <= 2 ? widget.usersMail.length : 2);
    }
    totalscrollheight = widget.usersMail.length > 0 ? totalscrollheight : 50;
    dynamic list = ListView.builder(
      itemCount: widget.usersMail.length,
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
          child: widget.usersMail.length == 0
              ? Center(child: Text("- אין -"))
              : list,
          padding: EdgeInsets.only(top: 16)),
    );
    if (hasButton) {
      list = Column(
          children: List.generate(
              widget.usersMail.length,
              (index) => Padding(
                    padding: EdgeInsets.only(
                        top: 0,
                        left: hasButton ? 8 : 0,
                        right: 16,
                        bottom: hasButton ? 16 : 0),
                    child: _buildActor(context, index),
                  )));
      list = Padding(
          child: widget.usersMail.length == 0
              ? Center(child: Text("- אין -"))
              : list,
          padding: EdgeInsets.only(top: 16));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.usersMail.isNotEmpty
                    ? ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendScreen(
                                  widget.usersMail, this.widget.initPubMsgText),
                            )),
                        icon: Icon(FontAwesomeIcons.envelope, size: 18),
                        label: Text("שליחת הודעה לרשימה זו"),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red[700])),
                      )
                    : Container(),
                Text(
                  widget.title,
                  textDirection: ui.TextDirection.rtl,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        list,
        widget.is_creator ? _creatorCommands() : SizedBox.shrink(),
      ],
    );
  }
}
