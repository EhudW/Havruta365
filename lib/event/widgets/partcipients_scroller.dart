import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/chat/screens/send_screen.dart';
import 'package:havruta_project/users/screens/user_screen/user_screen.dart';
import 'package:havruta_project/widgets/my_future_builder.dart';
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
    var currentUser = Globals.currentUser!.email;
    this.isCreator = event!.creatorUser == currentUser;
    //this.usersMail = usersMail ?? [];
    this.selectedUsers = [];
    this.userColl = Globals.db!.db.collection('Users');
  }
  String title;
  var isCreator;
  Set<dynamic> usersMail = {};
  var selectedUsers;
  var userColl;
  Event? event;
  void Function(String)? accept;
  void Function(String)? reject;

  @override
  State<ParticipentsScroller> createState() => _ParticipentsScrollerState();
}

Icon selectIcon(event, userMail, double iconSize) {
  bool isRejected = event.rejectedQueue!.contains(userMail);
  bool isLeaver = event.leftQueue!.contains(userMail);
  bool isParticipant = event.participants!.contains(userMail);

  if (!isRejected && !isLeaver && !isParticipant) iconSize = 0;

  Color color = isRejected || isLeaver ? Colors.red : Colors.green;

  dynamic iconShape = FontAwesomeIcons.solidCircleCheck;
  if (isRejected) iconShape = FontAwesomeIcons.solidCircleXmark;
  if (isLeaver) iconShape = FontAwesomeIcons.circle;
  if (isParticipant) iconShape = FontAwesomeIcons.solidCircleCheck;

  return Icon(
    iconShape,
    size: Globals.scaler.getTextSize(iconSize),
    color: color,
  );
}

String shortStr(String str, int newLength) {
  if (str.length <= newLength) return str;
  return str.substring(0, newLength - 3) + "...";
}

double calcDesiredHeight(usersAmount) {
  double totalscrollheight = 120;
  if (usersAmount > 0) {
    totalscrollheight =
        totalscrollheight * (usersAmount <= 2 ? usersAmount : 2);
  } else
    totalscrollheight = 50;
  return totalscrollheight;
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
    for (var user in widget.selectedUsers) {
      bool didSomething = widget.event!
          .rejectLocal(user); // so we wont need to await to mongodb
      if (!didSomething)
        continue; // to avoid notify fcm someone that already rejected
      widget.reject!(user);
    }
    widget.selectedUsers.clear();
    widget.notifyParent(); // we didnt waited for fcm/mongo db
  }

  void _acceptList() {
    for (var user in widget.selectedUsers) {
      bool didSomething = widget.event!
          .acceptLocal(user); // so we wont need to await to mongodb
      if (!didSomething)
        continue; // to avoid notify fcm someone that already joined
      widget.accept!(user);
    }
    widget.selectedUsers.clear();
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

  Widget createCheckbox(checkBoxValue, userMail) {
    return Container(
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
              value: checkBoxValue,
              side: BorderSide(
                color: Colors.blue,
                width: 0.0,
              ),
              checkColor: Colors.blue,
              activeColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              splashRadius: 100.0,
              onChanged: (bool? value_) {
                setState(() {
                  checkBoxValue = value_!;
                });
                if (value_!)
                  widget.selectedUsers.add(userMail);
                else
                  widget.selectedUsers.remove(userMail);
              },
            );
          },
        ));
  }

  Widget createProfileWidgets(snapshot, userMail, multiSelectBox) {
    bool isLeft = widget.event!.leftQueue.contains(userMail);
    var sizedBox = (double width) => SizedBox(width: width);

    List<Widget> profileWidgets = [
      widget.isCreator && !isLeft ? multiSelectBox : sizedBox(20),
      widget.isCreator ? sizedBox(8) : Container(),
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
                      builder: (context) => UserScreen(snapshot.data['email'])),
                );
              })),
      sizedBox(8),
      Padding(
        padding: EdgeInsets.only(top: 0, left: 16),
        child: Text(shortStr(snapshot.data['name'], 18),
            textDirection: ui.TextDirection.rtl),
      ),
    ];
    return InkWell(
        child: Row(children: profileWidgets.reversed.toList()),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserScreen(snapshot.data['email'])),
          );
        });
  }

  // Combine the different widgets of the user into a row.
  List<Widget> createUserRow(snapshot, profileInk, icon, double iconSize) {
    return [
      profileInk,
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
        widget.isCreator
            ? icon //X
            : SizedBox.shrink()
      ])
    ];
  }

  // Build row for each user in the lists.
  Widget _buildActor(BuildContext ctx, int index) {
    var userMail = widget.usersMail.elementAt(index);

    Future user = getUser(userMail);

    var userRowBuilder = (snapshot) {
      bool checkBoxValue = widget.selectedUsers.contains(userMail);
      var multiSelectBox = createCheckbox(checkBoxValue, userMail);
      var profileInk = createProfileWidgets(snapshot, userMail, multiSelectBox);

      double iconSize = 10;
      Icon icon = selectIcon(widget.event!, userMail, iconSize);

      List<Widget> userRow =
          createUserRow(snapshot, profileInk, icon, iconSize);

      // Add padding and margin for each widget in the row.
      userRow = userRow.reversed
          .toList()
          .map((e) => Container(
                padding: EdgeInsets.only(
                    top: hasButton ? 16 : 0, left: hasButton ? 0 : 16),
                margin: hasButton ? EdgeInsets.only(left: 16) : null,
                child: e,
              ))
          .toList();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: userRow,
      );
    };
    return myFutureBuilder(user, userRowBuilder, isCostumise: false);
  }

  @override
  Widget build(BuildContext context) {
    widget.usersMail = widget.isCreator
        ? {
            widget.event!.participants!,
            widget.event!.waitingQueue!,
            widget.event!.rejectedQueue,
            widget.event!.leftQueue
          }.expand((x) => x).toList().toSet()
        : widget.event!.participants!.toSet();

    String noParticipants = "- אין משתתפים -";
    if (widget.usersMail.isEmpty) return Center(child: Text(noParticipants));

    ElevatedButton sendMsgToAllParticipants = ElevatedButton.icon(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendScreen(
                widget.usersMail.toList(), this.widget.initPubMsgText),
          )),
      icon: Icon(FontAwesomeIcons.envelope, size: 18),
      label: Text("שליחת הודעה לרשימה זו"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red[700])),
    );

    Widget headerRow = Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.isCreator ? sendMsgToAllParticipants : SizedBox.shrink(),
            Text(
              widget.title,
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );

    // Build the list of actors while adding paddings.
    dynamic participantsViewList = Padding(
        child: Column(
            children: List.generate(
                widget.usersMail.length,
                (index) => Padding(
                      padding: EdgeInsets.only(
                          top: 0, left: 8, right: 16, bottom: 16),
                      child: _buildActor(context, index),
                    ))),
        padding: EdgeInsets.only(top: 16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        participantsViewList,
        widget.isCreator && widget.usersMail.isNotEmpty
            ? _creatorCommands()
            : SizedBox.shrink(),
      ],
    );
  }
}
