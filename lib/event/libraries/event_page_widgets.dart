library getters;

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/chat/screens/single_chat_screen.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/notification.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/event/screens/create_event_screen/create_event_screen.dart';
import 'package:havruta_project/event/screens/event_dates_list.dart';
import 'package:havruta_project/event/screens/further_details_screen.dart';
import 'package:havruta_project/event/widgets/add_to_calendar.dart';
import 'package:havruta_project/event/widgets/arc_banner_image.dart';
import 'package:havruta_project/globals.dart';
import 'dart:ui' as ui;

import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/users/screens/user_screen/user_screen.dart';
import 'package:share_plus/share_plus.dart';

void Function(String) rejectOrAcceptFactory(func) {
  return (userMail) async {
    /*showModalBottomSheet(
            context: context,
            builder: ((builder) => bottomSheet(context, () async {*/
    //Navigator.pop(context);
    await func(userMail);
    //refresh(); -> done at ScrollerParticipant for fast sync time delay; and not needed twwice
    //, () => Navigator.pop(context));
    //);
  };
}

NotificationUser createAcceptRejectNotification(
    bool isAccept, dynamic userMail, dynamic eventId) {
  return NotificationUser.fromJson({
    'creatorUser': Globals.currentUser!.email,
    'destinationUser': userMail,
    'creationDate': DateTime.now(),
    'message':
        isAccept ? "אישרתי את בקשתך לחברותא" : "לצערי דחיתי את בקשתך לחברותא",
    'type': isAccept ? 'joinAccept' : 'joinReject',
    'idEvent': eventId,
    'name': Globals.currentUser!.name,
  });
}

void Function(String) reject(Event event) {
  return rejectOrAcceptFactory((userMail) async {
    await event.reject(userMail);
    NotificationUser notification =
        createAcceptRejectNotification(false, userMail, event.id);
    Globals.db!.insertNotification(notification);
  });
}

void Function(String) accept(Event event) {
  return rejectOrAcceptFactory((userMail) async {
    await event.accept(userMail);
    NotificationUser notification =
        createAcceptRejectNotification(true, userMail, event.id);
    Globals.db!.insertNotification(notification);
  });
}

void deleteEvent(
    BuildContext context, Event event, void Function() setState) async {
  // notify persons who joined/waiting to be joined
  var toNotify = [];
  toNotify.addAll(event.participants ?? []);
  toNotify.addAll(event.waitingQueue ?? []);
  var t = event.type == 'H' ? "חברותא" : "שיעור";
  var g = Globals.currentUser!.gender == 'F' ? "ביטלה" : "ביטל";
  var msg = g + " " + t;
  // try to delete event
  var succeed = await Globals.db!.deleteEvent(event.id);
  // notify the people
  if (succeed) {
    for (String personToNotify in toNotify) {
      Globals.db!.insertNotification(NotificationUser.fromJson({
        'creatorUser': Globals.currentUser!.email,
        'destinationUser': personToNotify,
        'creationDate': DateTime.now(),
        'message': msg,
        'type': 'eventDeleted',
        'idEvent': event.id,
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
    setState();
  });
}

Widget eventPageBottomSheet(
    BuildContext context, Function ok, Function ignore) {
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

AppBar eventPasgeAppBar(context, event, snapshot, type) {
  return AppBar(
      title: Text(type),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: ArcBannerImage(
          event.eventImage ?? MyConsts.DEFAULT_EVENT_IMG,
          imgHeight: 80.0),
      actions: [
        CircleAvatar(
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
                      builder: (context) => UserScreen(snapshot.data['email'])),
                );
              }),
        )
      ]);
}

void emptyFunction() {}

Drawer eventPageDrawer(
    type, amICreator, event, snapshot, context, allUserEvents,
    {setStateOnDeleteEventFunc = emptyFunction}) {
  String topic = event.topic?.trim() ?? "";
  String book = event.book?.trim() ?? "";
  String t_topic = topic != "" ? " ב" + topic : "";
  String t_book = book != "" ? " ב" + book : "";
  Future<String> Function() shareLink =
      () => Globals.ServerDynamicEventLink(event);
  String shareString = "אשמח להזמין אותך ל" +
      event.longStr(
          snapshot.data == null ? null : User.fromJson(snapshot.data)) +
      ".\n";
  var drawerNavigationLine = (lineTitle, navigationFunc) {
    return ListTile(
      title: Text(lineTitle),
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(builder: navigationFunc));
      },
    );
  };
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Text(
            "\n\n" + 'פעולות : ',
            style: TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 25),
            textDirection: ui.TextDirection.rtl,
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        drawerNavigationLine(
            'פורום',
            (context) => SingleChatScreen(
                  otherPerson: event.id.toString(),
                  otherPersonName: event.id.toString(),
                  forumName: type + t_topic + t_book,
                )),
        ListTile(
          title: Text('הוסף ליומן'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: add2calendar(event),
              ),
            );
          },
        ),
        drawerNavigationLine(
            'לוח זמנים מלא',
            (context) => //Add further details page
                EventDatesList(event, allUserEvents ?? [])),
        drawerNavigationLine(
            'פרטים נוספים',
            (context) => //Add further details page
                FurtherDetailsScreen(event: event)),
        ListTile(
          title: Text('המלץ לחבר'),
          onTap: () async {
            Share.share(shareString + "\n" + await shareLink(),
                subject:
                    "כדאי לך להירשם ל${event.typeAsStr} באפליקציית חברותא פלוס");
          },
        ),
        amICreator
            ? ListTile(
                title: Text('צור על בסיס'),
                onTap: () async {
                  event.shouldDuplicate = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateEventScreen(
                              initEvent: event,
                            )),
                  );
                },
              )
            : Container(),
        amICreator
            ? ListTile(
                title: Text('ערוך אירוע'),
                onTap: () async {
                  event.shouldDuplicate = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateEventScreen(
                              initEvent: event,
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
                    builder: ((builder) => eventPageBottomSheet(
                          context,
                          () {
                            Navigator.pop(context);
                            deleteEvent(
                                context, event!, setStateOnDeleteEventFunc);
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
