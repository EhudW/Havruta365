import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:havruta_project/Screens/ChatScreen/chatStreamModel.dart';
import 'package:havruta_project/Screens/UserScreen/User_details_page.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/mytimer.dart';
import 'package:loading_animations/loading_animations.dart';

class ChatL10nHe extends ChatL10n {
  ChatL10nHe()
      : super(
            attachmentButtonAccessibilityLabel: "שלח מדיה",
            emptyChatPlaceholder: "אין כאן הודעות",
            fileButtonAccessibilityLabel: "קובץ",
            inputPlaceholder: "הודעה...",
            sendButtonAccessibilityLabel: "שלח",
            unreadMessagesLabel: "הודעות שלא נקראו");
}

class ChatPage extends StatefulWidget {
  String otherPerson;
  ChatPage({Key? key, required this.otherPerson}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _myUser = types.User(id: Globals.currentUser!.email!);
  late ChatModel model;
  @override
  void initState() {
    super.initState();
    model = ChatModel(
        myMail: Globals.currentUser!.email!,
        refreshNow: false,
        otherPerson: widget.otherPerson);
    // LoadProperty + cancelPrev using MyTimer with max 1 instance in the the program
    // MyTimer using Timer to schedule task every x seconds
    LoadProperty<void>(
      (setter) async {
        model.refresh();
        setter(null);
        return true;
      },
      duration: MyConsts.checkNewMessageInChatSec,
      oneLoadOnly: false,
      cancelPrev: "Chat1v1AutoRefresh", // prevent double timers
    ).start();
  }

  void onSend(types.PartialText pt) {
    model.send(ChatMessage(
        avatar: Globals.currentUser!.avatar,
        datetime: DateTime.now(),
        dst_mail: widget.otherPerson,
        id: null,
        message: pt.text,
        name: Globals.currentUser!.name,
        src_mail: Globals.currentUser!.email));
  }

  void onAvatarClick(types.User u) async {
    User user = await Globals.db!.getUser(u.id);
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => UserDetailsPage(user))));
  }

  @override
  Widget build(BuildContext context) {
    List<types.Message> firstData = [];

    Future<List<types.Message>> first =
        model.stream.first.then((value) => firstData = value);
    model.refresh();
    return Scaffold(
      body: FutureBuilder(
          future: first,
          builder: (context, AsyncSnapshot<List<types.Message>> snapshot) {
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
                return StreamBuilder<List<types.Message>>(
                    initialData: firstData,
                    stream: model.stream,
                    builder: (context, snapshot) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Chat(
                          bubbleRtlAlignment: BubbleRtlAlignment.right,
                          messages: snapshot.data!.reversed.toList(),
                          onAvatarTap: onAvatarClick,
                          l10n: ChatL10nHe(),
                          onSendPressed: onSend,
                          showUserAvatars: true,
                          showUserNames: true,
                          user: _myUser,
                        ),
                      );
                    });
            }
          }),
    );
  }
}
