import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/widgets/texts.dart';
import '../../data_base/data_representations/event.dart';
import '../../globals.dart';
import '../widgets/main_details.dart';

class FurtherDetailsScreen extends StatelessWidget {
  final Event? event_;
  FurtherDetailsScreen({Key? key, Event? event})
      : event_ = event,
        super(key: key);

  final String str = "";

  @override
  Widget build(BuildContext context) {
    String location = event_!.location?.trim() ?? '';
    String link = event_!.link?.trim() ?? '';
    String lecturer = event_!.lecturer?.trim() ?? '';
    String creatorName = event_!.creatorName?.trim() ?? '';
    String targetGender = event_!.targetGender?.trim() ?? '';
    String minAge = event_!.minAge.toString();
    String maxAge = event_!.maxAge.toString();

    var myMail = Globals.currentUser!.email;
    var amIParticipant = event_!.participants!.contains(myMail);
    var amICreator = event_!.creatorUser == myMail;
    var isHavruta = event_?.type == "H";

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        MainDetails(event_),
        //create_field()
        conditionalTwoLinesFieldCreation("מרצה:", lecturer),
        conditionalTwoLinesFieldCreation("יוצר:", creatorName),
        conditionalTwoLinesFieldCreation("מיקום:", location),
        !isHavruta || amICreator || amIParticipant
            ? conditionalTwoLinesFieldCreation("קישור:", link)
            : Container(),
        conditionalTwoLinesFieldCreation("גיל מינימלי:", minAge),
        conditionalTwoLinesFieldCreation("גיל מקסימלי:", maxAge),
        //conditional_field_creation("יוצר:", creator_user),
        conditionalTwoLinesFieldCreation("מין יעד:", targetGender),
      ])),
    );
  }

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
}
