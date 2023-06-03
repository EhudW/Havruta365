import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../DataBase_auth/Event.dart';
import '../../Globals.dart';
import 'dart:ui' as ui;

import 'MainDetails.dart';

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
    String location = event_!.location?.trim() ?? '';
    String link = event_!.link?.trim() ?? '';
    String lecturer = event_!.lecturer?.trim() ?? '';
    String creator_name = event_!.creatorName?.trim() ?? '';
    //String creator_user = event_!.creatorUser?.trim() ?? '';
    String target_gender = event_!.targetGender?.trim() ?? '';
    String min_age = event_!.minAge?.toString() ?? '';
    String max_age = event_!.maxAge?.toString() ?? '';
    //String creation_date = event_!.creationDate?.toString() ?? '';
    //String first_init_date = event_!.firstInitDates?.toString() ?? '';

    var myMail = Globals.currentUser!.email;
    var amIParticipant = event_!.participants!.contains(myMail);
    var amICreator = event_!.creatorUser == myMail;
    var isHavruta = event_?.type == "H";

    var asBasic = (String str) => str.toLowerCase().trim();
    var myCmp = (a, b) => asBasic(a) == asBasic(b);
    final String creatorDescription =
        myCmp(teacher, event_!.creatorName!) ? "" : event_!.creatorName!;

    var str_to_header = (String str) => Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(str,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.alef(fontSize: 15.0, color: Colors.grey[700])));

    var str_to_text = (String str) => Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          str,
          style: GoogleFonts.secularOne(fontSize: 18.0),
          textAlign: TextAlign.right,
          textDirection: ui.TextDirection.rtl,
        ));

    var create_field = (String header, String text) => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            str_to_header(header),
            str_to_text(text),
          ],
        );

    var conditional_field_creation = (String header, String text) =>
        text == '' ? Container() : create_field(header, text);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        MainDetails(event_),
        //create_field()
        conditional_field_creation("מרצה:", lecturer),
        conditional_field_creation("יוצר:", creator_name),
        conditional_field_creation("מיקום:", location),
        !isHavruta || amICreator || amIParticipant
            ? conditional_field_creation("קישור:", link)
            : Container(),
        conditional_field_creation("גיל מינימלי:", min_age),
        conditional_field_creation("גיל מקסימלי:", max_age),
        //conditional_field_creation("יוצר:", creator_user),
        conditional_field_creation("מין יעד:", target_gender),
      ])),
    );
  }
}
