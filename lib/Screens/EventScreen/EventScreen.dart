import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/EventsSelectorBuilder.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/Chat1v1.dart';
import 'package:havruta_project/Screens/EventScreen/EventPage.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart' as m;
import 'Event_details_page.dart';

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
    f = Future.wait([eventUpdate, allUserEvents]);
    return Scaffold(
        body: FutureBuilder(
            future: f,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: LoadingBouncingGrid.square(
                      borderColor: Colors.teal[400]!,
                      backgroundColor: Colors.teal[400]!,
                      size: 80.0,
                    ),
                  );
                case ConnectionState.done:
                  List<dynamic> data = snapshot.data! as List<dynamic>;
                  if (data[0] == null) {
                    return NoEventScreen(lbl: "האירוע לא נמצא\nככל הנראה נמחק");
                  }
                  var event = data[0] as Event?;
                  String? targetProblem =
                      Globals.currentUser!.whyIsNotTargetedForMe(event!);
                  bool rejectProblem = event!.rejectedQueue
                      .contains(Globals.currentUser!.email!);
                  if (targetProblem != null) {
                    return NoEventScreen(
                        eventname: event.typeAsStr,
                        lbl: "אינך בקהל היעד המתאים - בגלל ה" + targetProblem);
                  }
                  if (rejectProblem) {
                    return NoEventScreen(
                      lbl:
                          'רישומך נדחה ע"י היוזמ/ת. ניתן לשלוח בקשה בהודעה אישית',
                      otheruser: event.creatorUser,
                      otherusername: event.creatorName,
                      eventname: event.typeAsStr,
                    );
                  }
                  return EventPage(event, data[1] as List<Event>?);
                default:
                  return Text('default');
              }
            }));
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
                                builder: (context) => ChatPage(
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
