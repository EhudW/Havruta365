import 'package:flutter/material.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/event/screens/event_page/event_page.dart';
import 'package:havruta_project/data_base/events_selector_builder.dart';
import 'package:havruta_project/widgets/my_future_builder.dart';
import 'package:mongo_dart/mongo_dart.dart' as m;

String onlyHex(String s) =>
    s.replaceAll("ObjectId(\"", "").replaceAll("\")", "");
m.ObjectId fromHex(String ObjectIdAndHex) =>
    m.ObjectId.fromHexString(onlyHex(ObjectIdAndHex));

class EventScreen extends StatefulWidget {
  final m.ObjectId eventId;

  EventScreen(this.eventId);
  EventScreen.fromString(String ObjectIdAndHex)
      : eventId = fromHex(ObjectIdAndHex);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Future<List<dynamic>>? f; //[eventUpdate,allUserEvents];

  @override
  Widget build(BuildContext context) {
    Future<Event?> eventUpdate = Globals.db!.getEventById(this.widget.eventId);
    Future<List<Event>> allUserEvents =
        //Globals.db!.getAllEventsAndCreated(null, true, null);
        EventsSelectorBuilder.IinvolvedIn(
            myMail: Globals.currentUser!.email!,
            filterOldEvents: true,
            startFrom: null,
            maxEvents: null);

    var screenContent = (dynamic snapshot) {
      List<dynamic> data = snapshot.data! as List<dynamic>;
      if (data[0] == null) {
        return NoEventScreen(lbl: "האירוע לא נמצא\nככל הנראה נמחק");
      }
      var event = data[0] as Event?;
      String? targetProblem =
          Globals.currentUser!.whyIsNotTargetedForMe(event!);
      bool rejectProblem =
          event!.rejectedQueue.contains(Globals.currentUser!.email!);
      if (targetProblem != null) {
        return NoEventScreen(
            eventname: event.longStr(),
            lbl: "אינך בקהל היעד המתאים - בגלל ה" + targetProblem);
      }
      if (rejectProblem) {
        return NoEventScreen(
          lbl: 'רישומך נדחה ע"י היוזמ/ת. ניתן לשלוח בקשה בהודעה אישית',
          otheruser: event.creatorUser,
          otherusername: event.creatorName,
          eventname: event.longStr(),
        );
      }
      return EventPage(event, data[1] as List<Event>?);
    };
    f = Future.wait([eventUpdate, allUserEvents]);
    return Scaffold(
      body: myFutureBuilder(f, screenContent, isCostumise: false),
    );
  }
}

class NoEventScreen extends StatelessWidget {
  final String lbl;
  final String? otheruser;
  final String? otherusername;
  final String? eventname;
  const NoEventScreen(
      {Key? key,
      required this.lbl,
      this.eventname,
      this.otheruser,
      this.otherusername})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            (eventname ?? "") + "\n" + lbl,
            textAlign: TextAlign.right,
          )),
          otheruser == null
              ? SizedBox()
              : Center(
                  child: ElevatedButton(
                      child: Text("שלח הודעה"),
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SingleChatScreen(
                                    otherPerson: otheruser!,
                                    otherPersonName: otherusername!)),
                          )),
                ),
          Center(
              child: ElevatedButton(
            child: Text("חזרה"),
            onPressed: () => Navigator.pop(context),
          )),
        ],
      ),
    );
  }
}
