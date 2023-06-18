// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/event/screens/event_scroller_screen/Events.dart';
import 'package:havruta_project/event/widgets/models_home_pages.dart';

import '../../../QQQglobals.dart';
import 'package:flutter/material.dart';

/// helper widget for cusrom filtered events list ui
class MyEventsPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> modelData;
  final IconData? icon;
  String? user2View;
  MyEventsPage(
      {required this.title,
      required this.modelData,
      this.icon,
      this.user2View});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: Events(EventsModel(false, modelData: widget.modelData), null,
          user2View: widget.user2View),
    );
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
                  "  ${this.widget.title}  ",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alef(
                      fontWeight: FontWeight.bold,
                      fontSize: Globals.scaler.getTextSize(9),
                      color: Colors.teal[400]),
                ),
                Icon(this.widget.icon, size: 20, color: Colors.teal[400])
              ]),
        ));
  }
}
