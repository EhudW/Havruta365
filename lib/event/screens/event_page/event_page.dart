//import 'dart:io';

//import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/event/libraries/event_page_widgets.dart' as f;
import 'package:havruta_project/home_page.dart';
import 'package:havruta_project/widgets/my_future_builder.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/event/buttons/my_progress_button.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' as query;
import '../../widgets/partcipients_scroller.dart';
import '../../widgets/main_details.dart';

class EventPage extends StatefulWidget {
  Event? event;
  List<Event>? allUserEvents;
  var userColl;
  EventPage(this.event, this.allUserEvents) {
    this.userColl = Globals.db!.db.collection('Users');
  }

  Future getUser(String? userMail) async {
    var user = await userColl.findOne(query.where.eq('email', '$userMail'));
    return user;
  }

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future eventCreator = widget.getUser(widget.event!.creatorUser);

    var myMail = Globals.currentUser!.email;
    bool notMyTarget = !Globals.currentUser!.isTargetedForMe(widget.event!);
    var amIParticipant = widget.event!.participants!.contains(myMail);
    var amICreator = widget.event!.creatorUser == myMail;
    var canUserJoinTheEvent = widget.event!.dates!.isNotEmpty && !notMyTarget;

    String type = widget.event?.type == "H" ? "חברותא" : "שיעור";
    String topic = widget.event?.topic?.trim() ?? "";
    String eventType = widget.event!.type == "H" ? "חברותא" : "שיעור";
    String bookName =
        widget.event!.book != "" ? " ב" + widget.event!.book! : "";

    String atTopicStr = topic != "" ? " ב" + topic : "";
    String msgPrefix = "*הודעת תפוצה*" + "\n";
    String msgSuffix = eventType + atTopicStr + bookName + ":\n";

/*
    var remainedPlaces = widget.event!.maxParticipants! -
        widget.event!.participants!.length; /*-waitingQueue.length*/
    ChatModel model = ChatModel(myMail: Globals.currentUser!.email!);
*/

    var initPub = (bool wq) =>
        msgPrefix + (wq ? "למבקשים להצטרף ל" : "למשתתפי ה") + msgSuffix;

    var pageContent = (dynamic snapshot) => Scaffold(
          appBar: f.eventPasgeAppBar(context, widget.event!, snapshot, type),
          drawer: f.eventPageDrawer(type, amICreator, widget.event!, snapshot,
              context, widget.allUserEvents!,
              setStateOnDeleteEventFunc: () => setState(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  })),
          body: SingleChildScrollView(
            child: Column(children: [
              MainDetails(widget.event!),
              Divider(),
              canUserJoinTheEvent ? SizedBox(height: 8) : Container(),
              canUserJoinTheEvent
                  ? Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: MyProgressButton(
                          event: widget.event,
                          allUserEvents: widget.allUserEvents,
                          notifyParent: refresh),
                    )
                  : Container(),
              SizedBox(height: 8.0),
              Divider(),
              widget.event!.type == "L" || amIParticipant || amICreator
                  ? ParticipentsScroller(
                      accept: f.accept(widget.event!),
                      reject: f.reject(widget.event!),
                      title: "משתתפים",
                      initPubMsgText:
                          initPub(amICreator && widget.event!.type == 'H'),
                      event: widget.event,
                      notifyParent: refresh,
                    )
                  : Container(),
              SizedBox(height: Globals.scaler.getHeight(1)),
            ]),
          ),
        );

    return myFutureBuilder(eventCreator, pageContent, isCostumise: false);
  }
}
