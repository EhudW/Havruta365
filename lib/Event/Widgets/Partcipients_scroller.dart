import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/chat/screens/send_screen.dart';
import 'package:havruta_project/users/screens/user_screen/user_screen.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' hide Center;
import 'dart:ui' as ui;

// ignore: must_be_immutable
class ParticipentsScroller extends StatefulWidget {
  String initPubMsgText;
  Function notifyParent;
  ParticipentsScroller(
      {this.title = "משתתפים",
      this.accept,
      this.reject,
      required this.initPubMsgText,
      this.event,
      required this.notifyParent}) {
    var current_user = Globals.currentUser!.email;
    this.is_creator = event!.creatorUser == current_user;
    //this.usersMail = usersMail ?? [];
    this.selected_users = [];
    this.userColl = Globals.db!.db.collection('Users');
  }
  String title;
  var is_creator;
  Set<dynamic> usersMail = {};
  var selected_users;
  var userColl;
  Event? event;
  void Function(String)? accept;
  void Function(String)? reject;

  @override
  State<ParticipentsScroller> createState() => _ParticipentsScrollerState();
}

class _ParticipentsScrollerState extends State<ParticipentsScroller> {
  //bool get hasButton => reject != null || accept != null;
  final bool hasButton = true;
  //List<dynamic> usersMail = [];

  Future getUser(String? userMail) async {
    var user = await widget.userColl.findOne(where.eq('email', '$userMail'));
    return user;
  }

  void _rejectList() {
    for (var user in widget.selected_users) {
      bool didSomething = widget.event!
          .rejectLocal(user); // so we wont need to await to mongodb
      if (!didSomething)
        continue; // to avoid notify fcm someone that already rejected
      widget.reject!(user);
    }
    widget.selected_users.clear();
    widget.notifyParent(); // we didnt waited for fcm/mongo db
  }

  void _acceptList() {
    for (var user in widget.selected_users) {
      bool didSomething = widget.event!
          .acceptLocal(user); // so we wont need to await to mongodb
      if (!didSomething)
        continue; // to avoid notify fcm someone that already joined
      widget.accept!(user);
    }
    widget.selected_users.clear();
    widget.notifyParent(); // we didnt wait for mongodb or fcm
  }

  Widget _creatorCommands() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      widget.reject == null
          ? SizedBox()
          : TextButton(
              onPressed: () => _rejectList(),
              child: Text("דחה"),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white)),
      SizedBox(
        width: 20,
      ),
      widget.accept == null
          ? SizedBox()
          : TextButton(
              onPressed: () => _acceptList(),
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
    var userMail = widget.usersMail.elementAt(index);
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
            var multi_select_box = Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 3.0, color: Colors.blue),
                    left: BorderSide(width: 3.0, color: Colors.blue),
                    right: BorderSide(width: 3.0, color: Colors.blue),
                    bottom: BorderSide(width: 3.0, color: Colors.blue),
                  ),
                  shape: BoxShape.circle,
                ),
                width: 20,
                height: 20,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Checkbox(
                      value: check_box_value,
                      side: BorderSide(
                        color: Colors.blue,
                        width: 0.0,
                      ),
                      checkColor: Colors.blue,
                      // fillColor: Colors.blue,
                      activeColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      splashRadius: 100.0,
                      onChanged: (bool? value_) {
                        setState(() {
                          check_box_value = value_!;
                        });
                        if (value_!)
                          widget.selected_users.add(userMail);
                        else
                          widget.selected_users.remove(userMail);
                      },
                    );
                  },
                ));

            var profile = [
              widget.is_creator && !widget.event!.leftQueue.contains(userMail)
                  ? multi_select_box
                  : SizedBox(
                      width: 20,
                    ),
              widget.is_creator
                  ? SizedBox(
                      width: 8,
                    )
                  : Container(),
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
              SizedBox(
                width: 8,
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
            double iconSize = 10;

            Icon icons = Icon(
              FontAwesomeIcons.solidCircleCheck,
              size: Globals.scaler.getTextSize(0),
              color: Colors.green,
            );
            ;
            if (widget.event!.rejectedQueue!.contains(userMail))
              icons = Icon(
                FontAwesomeIcons.solidCircleXmark,
                size: Globals.scaler.getTextSize(iconSize),
                color: Colors.red,
              );
            if (widget.event!.leftQueue!.contains(userMail)) {
              icons = Icon(
                FontAwesomeIcons.circle,
                size: Globals.scaler.getTextSize(iconSize),
                color: Colors.red,
              );
            }
            if (widget.event!.participants!.contains(userMail))
              icons = Icon(
                FontAwesomeIcons.solidCircleCheck,
                size: Globals.scaler.getTextSize(iconSize),
                color: Colors.green,
              ); // V
            if (widget.event!.waitingQueue!.contains(userMail)) {
              icons = Icon(
                FontAwesomeIcons.solidCircleCheck,
                size: Globals.scaler.getTextSize(0),
                color: Colors.green,
              );
            }

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
                            builder: (context) => SingleChatScreen(
                                  otherPerson: snapshot.data['email'],
                                  otherPersonName: snapshot.data['name'],
                                )));
                  },
                  child: Icon(
                    FontAwesomeIcons.solidMessage,
                    size: Globals.scaler.getTextSize(iconSize),
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
            Map<Widget, bool> _inner_map = {};
            _inner = _inner.reversed.toList();
            widget.is_creator
                ? _inner = _inner
                    .map((e) => Container(
                          padding: EdgeInsets.only(
                              top: hasButton ? 16 : 0,
                              left: hasButton ? 0 : 16),
                          margin: hasButton ? EdgeInsets.only(left: 16) : null,
                          child: e,
                        ))
                    .toList()
                : _inner_map = {
                    for (var v in _inner
                        .toList()
                        .map((e) => Container(
                              padding: EdgeInsets.only(
                                  top: hasButton ? 16 : 0,
                                  left: hasButton ? 0 : 16),
                              margin:
                                  hasButton ? EdgeInsets.only(left: 16) : null,
                              child: e,
                            ))
                        .toList())
                      v: false
                  };
            //return widget.is_creator
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    widget.usersMail = widget.is_creator
        ? {
            widget.event!.participants!,
            widget.event!.waitingQueue!,
            widget.event!.rejectedQueue,
            widget.event!.leftQueue
          }.expand((x) => x).toList().toSet()
        : widget.event!.participants!.toSet();
    //widget.selected_users_ =   List.generate(widget.usersMail.length, (index) => false);
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
            padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.usersMail.isNotEmpty
                    ? ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendScreen(
                                  widget.usersMail.toList(),
                                  this.widget.initPubMsgText),
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
