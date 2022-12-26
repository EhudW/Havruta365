import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Widgets/SplashScreen.dart';
import '../../Globals.dart';
import 'ChatMessage.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {

  Future<List<ChatMessage>>? chatMessagesList;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  void initState() {
    super.initState();
    widget.chatMessagesList = Globals.db!
        .getAllMyMessages(Globals.currentUser!.email);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.chatMessagesList,
        builder: (BuildContext context, AsyncSnapshot<List<ChatMessage>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return SplashScreen();
            case ConnectionState.done:
              var list = snapshot.data!;
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
                            leading: CircleAvatar(
                              radius: 24.0,
                              backgroundImage: NetworkImage(message.avatar!),
                            ),
                            title: Row(
                              children: <Widget>[
                                Text(message.name!),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Text(
                                  DateFormat('d-M-yyyy')
                                      .format(message.datetime!),
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ],
                            ),
                            subtitle: Text(message.message!),
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
          child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(
              "הודעות",
              textAlign: TextAlign.center,
              style: GoogleFonts.alef(
                  fontWeight: FontWeight.bold,
                  fontSize: Globals.scaler.getTextSize(9),
                  color: Colors.teal[400]),
            ),
            SizedBox(width: Globals.scaler.getWidth(1),),
            Icon(FontAwesomeIcons.envelope, size: Globals.scaler.getTextSize(8), color: Colors.teal[400])
          ]),
        ));
  }
}