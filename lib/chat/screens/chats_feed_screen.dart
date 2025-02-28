import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/chat/chat_stream_model.dart';
import 'package:havruta_project/users/screens/user_screen/user_screen.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';

import 'package:havruta_project/event/screens/event_page/event_screen.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/mytimer.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart' as mg;
import '../../globals.dart';
import '../../data_base/data_representations/chat_message.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class ChatsFeedScreen extends StatefulWidget {
  @override
  _ChatsFeedScreenState createState() => _ChatsFeedScreenState();
}

class _ChatsFeedScreenState extends State<ChatsFeedScreen> {
  ChatModel model = ChatModel(myMail: Globals.currentUser!.email!);
  late MyTimer timer;
  @override
  void initState() {
    super.initState();
    timer = MyTimer(
      duration: MyConsts.checkNewMessageOutsideChatSec,
      function: () => model
          //.refresh(Globals.db!.getAllMyForums(
          //    Globals.msgWithFriends.waitData().then((v) => v!)))
          .refresh(Globals.msgWithFriends.waitData().then((v) => v!))
          .then((value) => true),
    );
    timer.start(true);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context),
        resizeToAvoidBottomInset: true,
        body: StreamBuilder<List<MapEntry<ChatMessage, int>>>(
            stream: model.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                model.simulateRefresh();
                return Center(
                  child: LoadingBouncingGrid.square(
                    borderColor: Colors.teal[400]!,
                    backgroundColor: Colors.teal[400]!,
                    size: 20.0,
                  ),
                );
              }
              var list = snapshot.data!;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    "אין הודעות",
                    style: TextStyle(fontSize: 20.0),
                  ),
                );
              }

              return Container(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = list[index].key;
                    int unread = list[index].value;
                    return Column(
                      children: <Widget>[
                        Divider(
                          height: 12.0,
                        ),
                        ListTile(
                          onTap: () {
                            timer.cancel();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleChatScreen(
                                    otherPerson: message.otherPersonMail,
                                    otherPersonName: message.otherPersonName!,
                                    forumName: message.isForum
                                        ? message.otherPersonName
                                        : null,
                                  ),
                                )).then((value) => timer.start(true));
                          },
                          leading: Stack(
                            children: [
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                  onPressed: () {
                                    timer.cancel();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => message.isForum
                                              ? EventScreen(
                                                  mg.ObjectId.fromHexString(
                                                      message.dst_mail!
                                                          .split('"')[1]))
                                              : UserScreen(
                                                  message.otherPersonMail),
                                        )).then((value) => timer.start(true));
                                  },
                                  child: CircleAvatar(
                                    radius: 24.0,
                                    backgroundImage: NetworkImage(
                                        message.otherPersonAvatar!),
                                  )),
                              CircleAvatar(
                                radius: unread == 0 ? 0 : 13.0,
                                backgroundColor: Colors.red[900],
                                child: Text(
                                  unread.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          title: null,
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(message.otherPersonName!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16),
                                  textDirection: ui.TextDirection.rtl),
                              message.isForum
                                  ? Text(
                                      (" 🗨 פורום 🗨 "),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.deepOrange),
                                    )
                                  : SizedBox(),
                              Text(
                                DateFormat('HH:mm  d-M-yyyy')
                                    .format(message.datetime!.toLocal()),
                                style: TextStyle(fontSize: 14.0),
                              ),
                              RichText(
                                textDirection: ui.TextDirection.rtl,
                                text: TextSpan(
                                  text: '',
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .merge(
                                          TextStyle(color: Colors.grey[600])),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: (message.amITheSender
                                                ? "אני"
                                                : (message.name!
                                                    .trim()
                                                    .split(" ")[0])) +
                                            ": ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontStyle: FontStyle.italic,
                                          /*decorationThickness: 1,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            decorationStyle:
                                                TextDecorationStyle.solid,
                                            decorationColor: Colors.black,
                                            decoration:
                                                TextDecoration.underline*/
                                        )),
                                    TextSpan(text: message.message!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 14.0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }));
  }

  appBar(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler();
    return new AppBar(
        leadingWidth: Globals.scaler.getWidth(6),
        leading: IconSwitch(
          true,
          (toBe, flip) {
            model.onlyPrivateChats = !toBe;
            model.simulateRefresh();
            flip();
          },
          icons: {true: Icons.filter_alt_off_sharp, false: Icons.chat_outlined},
          tooltip: {true: "עם פורומים", false: "בלי פורומים"},
        ),
        toolbarHeight: 40,
        elevation: 30,
        shadowColor: Colors.teal[400],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        )),
        backgroundColor: Colors.white,
        title: Container(
          width: scaler.getWidth(50),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "הודעות",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alef(
                      fontWeight: FontWeight.bold,
                      fontSize: Globals.scaler.getTextSize(9),
                      color: Colors.teal[400]),
                ),
                SizedBox(
                  width: Globals.scaler.getWidth(1),
                ),
                Icon(FontAwesomeIcons.envelope,
                    size: Globals.scaler.getTextSize(8),
                    color: Colors.teal[400])
              ]),
        ));
  }
}
