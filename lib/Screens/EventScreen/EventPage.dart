//import 'dart:io';

//import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/EventScreen/FurtherDetailsScreen.dart';
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

  AppBar BuildAppBar(snapshot, type) {
    return AppBar(
        title: Text(type),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace:
            ArcBannerImage(widget.event!.eventImage, imgHeight: 80.0),
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

  Drawer BuildDrawer(type) {
    String topic = widget.event?.topic?.trim() ?? "";
    String book = widget.event?.book?.trim() ?? "";
    String t_topic = topic != "" ? " ב" + topic : "";
    String t_book = book != "" ? " ב" + book : "";
    String study = book == "" ? topic : "";
    String share_string = "אשמח להזמין אותך ל" +
        type +
        " בנושא " +
        study +
        ", מפי הרב " +
        widget.event!.lecturer! +
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
            child: Text('Drawer Header'),
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
            onTap: () {
              Share.share(share_string + "\n https://www.google.com/",
                  subject: "https://www.google.com/");
            },
          ),
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

    var rejectOrAcceptFactory = (func) => (userMail) {
          showModalBottomSheet(
            context: context,
            builder: ((builder) => bottomSheet(context, () async {
                  Navigator.pop(context);
                  await func(userMail);
                  refresh();
                }, () => Navigator.pop(context))),
          );
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
                drawer: BuildDrawer(type),
                body: SingleChildScrollView(
                  child: Column(children: [
                    MainDetails(widget.event!),
                    Divider(),
                    widget.event!.dates!.isEmpty || notMyTarget
                        ? Container()
                        : SizedBox(height: 8),
                    widget.event!.dates!.isEmpty || notMyTarget
                        ? Container()
                        : MyProgressButton(
                            event: widget.event,
                            allUserEvents: widget.allUserEvents,
                            notifyParent: refresh),
                    SizedBox(height: 8.0),
                    Divider(),
                    /*Container(
                      height: Globals.scaler.getHeight(5),
                      child:*/
                    widget.event!.type == "L" || amIParticipant || amICreator
                        ? ParticipentsScroller(
                            //TODO: edit widget
                            widget.event!.participants,
                            title: "משתתפים",
                            initPubMsgText: initPub(false),
                            event: widget.event,
                          )
                        : Container(),

                    amICreator && widget.event!.type == 'H'
                        ? ParticipentsScroller(
                            widget.event!.waitingQueue,
                            title: "ממתינים לאישור",
                            initPubMsgText: initPub(true),
                            accept: accept,
                            reject: reject,
                            event: widget.event,
                          )
                        : Container(),

                    //),
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
