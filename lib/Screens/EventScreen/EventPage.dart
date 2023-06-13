//import 'dart:io';

//import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Screens/EventScreen/FurtherDetailsScreen.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta1.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/MyProgressButton.dart';
import 'package:share_plus/share_plus.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' as query;
import '../../DataBase_auth/Notification.dart';
import '../ChatScreen/Chat1v1.dart';
import '../ChatScreen/chatStreamModel.dart';
import 'Add2Calendar.dart';
import 'arc_banner_image.dart';
import 'EventDatesList.dart';
import 'Partcipients_scroller.dart';
import 'dart:ui' as ui;
import 'MainDetails.dart';

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

  Widget bottomSheet(BuildContext context, Function ok, Function ignore) {
    return Container(
      height: Globals.scaler.getHeight(8.5),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: Globals.scaler.getWidth(3),
        vertical: Globals.scaler.getHeight(1),
      ),
      child: Column(
        children: <Widget>[
          Text(
            Globals.currentUser!.gender == 'F' ? "את בטוחה?" : "אתה בטוח?",
            textDirection: ui.TextDirection.rtl,
            style: TextStyle(
              fontSize: Globals.scaler.getTextSize(8.5),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.check),
              onPressed: () {
                ok();
              },
              label: Text("בטוח"),
            ),
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.circleXmark),
              onPressed: () {
                ignore();
              },
              label: Text("בטל פעולה"),
            ),
          ])
        ],
      ),
    );
  }

  _deleteEvent() async {
    // notify persons who joined/waiting to be joined
    var toNotify = [];
    toNotify.addAll(widget.event!.participants ?? []);
    toNotify.addAll(widget.event!.waitingQueue ?? []);
    var t = widget.event!.type == 'H' ? "חברותא" : "שיעור";
    var g = Globals.currentUser!.gender == 'F' ? "ביטלה" : "ביטל";
    var msg = g + " " + t;
    // try to delete event
    var succeed = await Globals.db!.deleteEvent(widget.event!.id);
    // notify the people
    if (succeed) {
      for (String personToNotify in toNotify) {
        Globals.db!.insertNotification(NotificationUser.fromJson({
          'creatorUser': Globals.currentUser!.email,
          'destinationUser': personToNotify,
          'creationDate': DateTime.now(),
          'message': msg,
          'type': 'eventDeleted',
          'idEvent': widget.event!.id,
          'name': Globals.currentUser!.name,
        }));
      }
    }
    // show flushbar to the creator
    if (!succeed) {
      Flushbar(
        title: 'מחיקת אירוע',
        messageText: Text('אירעה שגיאה בתהליך המחיקה !',
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.teal[400], fontSize: 20)),
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      Flushbar(
        title: 'האירוע נמחק',
        messageText: Text('מיד תועבר לעמוד הבית !',
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.teal[400], fontSize: 20)),
        duration: Duration(seconds: 2),
      )..show(context);
    }
    // move creator to the home page
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    });
  }

  AppBar BuildAppBar(snapshot, type) {
    return AppBar(
        title: Text(type),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: ArcBannerImage(
            widget.event!.eventImage ?? MyConsts.DEFAULT_EVENT_IMG,
            imgHeight: 80.0),
        actions: [
          CircleAvatar(
            //TODO: shreenk
            foregroundImage: NetworkImage(snapshot.data['avatar']),
            backgroundColor: Colors.transparent,
            radius: 40.0, //here
            child: IconButton(
                icon: Icon(Icons.quiz_sharp),
                iconSize: 40.0,
                //color: Colors.white.withOpacity(0),
                color: Colors.white.withOpacity(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserScreen(snapshot.data['email'])),
                  );
                }),
          )
        ]);
  }

  Drawer BuildDrawer(type, amICreator, snapshot) {
    String topic = widget.event?.topic?.trim() ?? "";
    String book = widget.event?.book?.trim() ?? "";
    String t_topic = topic != "" ? " ב" + topic : "";
    String t_book = book != "" ? " ב" + book : "";
    String study = book == "" ? topic : "";
    Future<String> Function() share_link =
        () => Globals.ServerDynamicEventLink(widget.event!);
    String share_string = "אשמח להזמין אותך ל" +
        widget.event!.longStr(
            snapshot.data == null ? null : User.fromJson(snapshot.data)) +
        ".\n";
    var drawer_navigation_line = (line_title, navigation_func) {
      return ListTile(
        title: Text(line_title),
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: navigation_func));
        },
      );
    };
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(
              "\n\n" + 'תפריט פעולות : ',
              style: TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 25),
              textDirection: ui.TextDirection.rtl,
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          drawer_navigation_line(
              'פורום',
              (context) => ChatPage(
                    otherPerson: widget.event!.id.toString(),
                    otherPersonName: widget.event!.id.toString(),
                    forumName: type + t_topic + t_book,
                  )),
          ListTile(
            title: Text('הוסף ליומן'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: add2calendar(widget.event!),
                ),
              );
            },
          ),
          drawer_navigation_line(
              'לוח זמנים מלא',
              (context) => //Add further details page
                  EventDatesList(widget.event!, widget.allUserEvents ?? [])),
          drawer_navigation_line(
              'פרטים נוספים',
              (context) => //Add further details page
                  FurtherDetailsScreen(event: widget.event!)),
          ListTile(
            title: Text('המלץ לחבר'),
            onTap: () async {
              Share.share(share_string + "\n" + await share_link(),
                  subject:
                      "כדאי לך להירשם ל${widget.event!.typeAsStr} באפליקציית חברותא פלוס");
            },
          ),
          amICreator
              ? ListTile(
                  title: Text('צור על בסיס'),
                  onTap: () async {
                    widget.event!.shouldDuplicate = true;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FindMeAChavruta1(
                                initEvent: widget.event,
                              )),
                    );
                  },
                )
              : Container(),
          amICreator
              ? ListTile(
                  title: Text('ערוך אירוע'),
                  onTap: () async {
                    widget.event!.shouldDuplicate = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FindMeAChavruta1(
                                initEvent: widget.event,
                                barTitle: "עריכת אירוע קיים  ",
                              )),
                    );
                  },
                )
              : Container(),
          amICreator
              ? ListTile(
                  title: Text('מחק אירוע'),
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => bottomSheet(
                            context,
                            () {
                              Navigator.pop(context);
                              _deleteEvent();
                            },
                            () => Navigator.pop(context),
                          )),
                    );
                  },
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future creator = widget.getUser(widget.event!.creatorUser);

    String type = widget.event?.type == "H" ? "חברותא" : "שיעור";
    String topic = widget.event?.topic?.trim() ?? "";
    String book = widget.event?.book?.trim() ?? "";
    String t_event_type = widget.event!.type == "H" ? "חברותא" : "שיעור";
    String t_book_name =
        widget.event!.book != "" ? " ב" + widget.event!.book! : "";
    String t_topic = topic != "" ? " ב" + topic : "";
    var myMail = Globals.currentUser!.email;
    bool notMyTarget = !Globals.currentUser!.isTargetedForMe(widget.event!);
    var amIParticipant = widget.event!.participants!.contains(myMail);
    var amICreator = widget.event!.creatorUser == myMail;
    var remainedPlaces = widget.event!.maxParticipants! -
        widget.event!.participants!.length; /*-waitingQueue.length*/
    String t_pre = "*הודעת תפוצה*" + "\n";
    String t_suffix = t_event_type + t_topic + t_book_name + ":\n";

    ChatModel model = ChatModel(myMail: Globals.currentUser!.email!);

    var initPub =
        (bool wq) => t_pre + (wq ? "למבקשים להצטרף ל" : "למשתתפי ה") + t_suffix;

    var rejectOrAcceptFactory = (func) => (userMail) async {
          /*showModalBottomSheet(
            context: context,
            builder: ((builder) => bottomSheet(context, () async {*/
          //Navigator.pop(context);
          await func(userMail);
          //refresh(); -> done at ScrollerParticipant for fast sync time delay; and not needed twwice
          //, () => Navigator.pop(context));
          //);
        };
    var reject = rejectOrAcceptFactory((userMail) async {
      await widget.event!.reject(userMail);
      NotificationUser notification = NotificationUser.fromJson({
        'creatorUser': Globals.currentUser!.email,
        'destinationUser': userMail,
        'creationDate': DateTime.now(),
        'message': "לצערי דחיתי את בקשתך לחברותא",
        'type': 'joinReject',
        'idEvent': widget.event!.id,
        'name': Globals.currentUser!.name,
      });
      Globals.db!.insertNotification(notification);
    });
    var accept = rejectOrAcceptFactory((userMail) async {
      await widget.event!.accept(userMail);
      NotificationUser notification = NotificationUser.fromJson({
        'creatorUser': Globals.currentUser!.email,
        'destinationUser': userMail,
        'creationDate': DateTime.now(),
        'message': "אישרתי את בקשתך לחברותא",
        'type': 'joinAccept',
        'idEvent': widget.event!.id,
        'name': Globals.currentUser!.name,
      });
      Globals.db!.insertNotification(notification);
    });

    return FutureBuilder(
        future: creator,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
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
              return Scaffold(
                appBar: BuildAppBar(snapshot, type),
                drawer: BuildDrawer(type, amICreator, snapshot),
                body: SingleChildScrollView(
                  child: Column(children: [
                    MainDetails(widget.event!),
                    Divider(),
                    widget.event!.dates!.isEmpty || notMyTarget
                        ? Container()
                        : SizedBox(height: 8),
                    widget.event!.dates!.isEmpty || notMyTarget
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: MyProgressButton(
                                event: widget.event,
                                allUserEvents: widget.allUserEvents,
                                notifyParent: refresh),
                          ),
                    SizedBox(height: 8.0),
                    Divider(),
                    widget.event!.type == "L" || amIParticipant || amICreator
                        ? ParticipentsScroller(
                            accept: accept,
                            reject: reject,
                            title: "משתתפים",
                            initPubMsgText: initPub(
                                amICreator && widget.event!.type == 'H'),
                            event: widget.event,
                            notifyParent: refresh,
                          )
                        : Container(),
                    SizedBox(height: Globals.scaler.getHeight(1)),
                  ]),
                ),
              );
            default:
              return Text('default');
          }
        });
  }
}
