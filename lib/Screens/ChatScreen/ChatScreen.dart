import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/Screens/ChatScreen/Chat1v1.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:havruta_project/Screens/UserScreen/User_details_page.dart';
//import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Widgets/SplashScreen.dart';
import '../../Globals.dart';
import 'ChatMessage.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatScreen() : super(key: GlobalKey());
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<List<ChatMessage>>? chatMessagesList;
  @override
  void initState() {
    super.initState();
    chatMessagesList = Globals.db!
        .getAllMyLastMessageWithEachFriend(Globals.currentUser!.email!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: chatMessagesList,
        builder:
            (BuildContext context, AsyncSnapshot<List<ChatMessage>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return SplashScreen();
            case ConnectionState.done:
              var list = snapshot.data!;
              var impList = list
                  .where((element) =>
                      element.src_mail != Globals.currentUser!.email)
                  .toList();
              Globals.lastMsgSeen = impList.isNotEmpty ? impList.first : null;
              return Scaffold(
                appBar: appBar(context),
                body: Container(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      ChatMessage message = list[index];
                      return Column(
                        children: <Widget>[
                          Divider(
                            height: 12.0,
                          ),
                          ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    otherPerson: message.otherPersonMail,
                                    otherPersonName: message.otherPersonName,
                                  ),
                                )).then((value) {
                              var x = (widget.key as GlobalKey).currentState;
                              if (x == null) return;
                              Navigator.pop(x.context);
                            }),
                            leading: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserScreen(message.otherPersonMail),
                                    )),
                                child: CircleAvatar(
                                  radius: 24.0,
                                  backgroundImage:
                                      NetworkImage(message.otherPersonAvatar),
                                )),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  width: 16.0,
                                ),
                                Text(
                                    (message.amITheSender
                                            ? "נשלחה ל "
                                            : "התקבלה מ") +
                                        message.otherPersonName,
                                    textDirection: ui.TextDirection.rtl),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('HH:mm  d-M-yyyy')
                                      .format(message.datetime!.toLocal()),
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                Text(message.message!,
                                    textDirection: ui.TextDirection.rtl),
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
                ),
              );
            default:
              return Text('default');
          }
        });
  }

  appBar(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler();
    return new AppBar(
        leadingWidth: 0,
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
