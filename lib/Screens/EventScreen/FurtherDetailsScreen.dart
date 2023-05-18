import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../DataBase_auth/Event.dart';
import '../../Globals.dart';
import 'dart:ui' as ui;

class FurtherDetailsScreen extends StatelessWidget {
  final Event? event_;
  FurtherDetailsScreen({Key? key, Event? event})
      : event_ = event,
        super(key: key);

  final String str = "";

  appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal[400],
      title: Text(
        event_!.topic ?? '',
        style: GoogleFonts.assistant(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String teacher =
        event_!.type == 'L' ? event_!.lecturer! : event_!.creatorName!;
    // should we add extra text to differ between teacher and creator?
    var asBasic = (String str) => str.toLowerCase().trim();
    var myCmp = (a, b) => asBasic(a) == asBasic(b);
    final String creatorDescription =
        myCmp(teacher, event_!.creatorName!) ? "" : event_!.creatorName!;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            SizedBox(height: Globals.scaler.getHeight(1)),
            Row(
              textDirection: ui.TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("גברים/נשים: ", //TODO: into further details
                    textDirection: ui.TextDirection.rtl,
                    style: GoogleFonts.suezOne(
                        fontSize: 20.0, color: Colors.grey[700])),
                Text(event_!.targetGender!,
                    textDirection: ui.TextDirection.rtl,
                    style: GoogleFonts.suezOne(
                        fontSize: 20.0, color: Colors.grey[700])),
              ],
            ),
            Text(
              // TODO: add limud: before the text
              event_!.topic!,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.secularOne(fontSize: 26.0),
              textAlign: TextAlign.center,
            ),
            Text(
              event_!.book!, //TODO: combine with topic
              textDirection: TextDirection.rtl,
              style: GoogleFonts.secularOne(fontSize: 22.0),
              textAlign: TextAlign.center,
            ),
            Text(
              //TODO: remove this
              teacher,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.secularOne(fontSize: 22.0),
              textAlign: TextAlign.center,
            ),
            Text(
              // TODO: remove this
              creatorDescription == "" ? "" : "ביוזמת",
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              creatorDescription,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ])),
    );
  }
}
