import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/QQQglobals.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:havruta_project/event/screens/event_page/event_screen.dart';
import 'package:havruta_project/mydebug.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:havruta_project/data_base_auth/User.dart';
//import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class EventViewFeed extends StatelessWidget {
  final Event event;
  final String? search;
  final String? user2View; // will highlight if the user is in waiting queue
  final bool noClickAndClock;
  const EventViewFeed(
      {Key? key,
      required this.event,
      this.search,
      this.noClickAndClock = false,
      this.user2View})
      : super(key: key);

  dynamic highlightedText(Text txt, BuildContext ctx, {bool ignore = false}) {
    var fullString = txt.data ?? txt.textSpan!.toPlainText();
    var style = txt.style ?? txt.textSpan!.style;

    var defaultTxt = txt;
    if (ignore || search == null) {
      return defaultTxt;
    }
    var bold = search!.trim();
    if (bold == "" || !fullString.contains(bold)) {
      return defaultTxt;
    }
    var notUsedStr = "###@@@###";
    fullString = fullString.replaceFirst(bold, notUsedStr);
    var strings = fullString.split(notUsedStr);
    return RichText(
      textDirection: ui.TextDirection.rtl,
      text: TextSpan(
        text: '',
        style: DefaultTextStyle.of(ctx).style,
        children: <TextSpan>[
          TextSpan(text: strings[0], style: style),
          TextSpan(
              text: bold,
              style: style!.merge(TextStyle(backgroundColor: Colors.yellow))),
          TextSpan(text: strings[1], style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler();
    var myMail = Globals.currentUser!.email;
    var iAmParticipant = event.participants!.contains(myMail);
    var iAmInWaitingQueue = event.waitingQueue?.contains(myMail) ?? false;
    Widget registeredState1 =
        SizedBox(width: scaler.getWidth(1) + scaler.getTextSize(14));
    Widget registeredState2 = SizedBox();
    Widget registeredState3 = SizedBox();
    if (iAmParticipant || iAmInWaitingQueue) {
      registeredState1 = SizedBox(
          child: Text(
        iAmParticipant ? "רשום" : "מחכה",
        // textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: scaler.getTextSize(6)),
      ));
      registeredState2 = SizedBox(width: scaler.getWidth(1));
      registeredState3 = SizedBox(
          child: Icon(
              iAmParticipant
                  ? FontAwesomeIcons.handshake
                  : FontAwesomeIcons.hand,
              size: scaler.getTextSize(8),
              color: Colors.blueAccent));
    }
    return Material(
        child: InkWell(
            splashColor: Colors.teal[400],
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            onTap: noClickAndClock
                ? null
                : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventScreen(event.id)));
                  },
            child: Container(
              decoration: user2View != null &&
                      ((event.waitingQueue != null &&
                              event.waitingQueue!.contains(user2View!)) ||
                          event.rejectedQueue.contains(user2View))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.red[300]!,
                        //Colors.transparent,
                        //Colors.transparent,
                        Colors.yellow[50]!,
                      ],
                    ))
                  : null,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      /*decoration: user2View != null &&
                              event.waitingQueue != null &&
                              event.waitingQueue!.contains(user2View!)
                          ? BoxDecoration(
                              gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomLeft,
                              colors: [
                                Colors.red[300]!,
                                //Colors.transparent,
                                //Colors.transparent,
                                Colors.yellow[50]!,
                              ],
                            ))
                          : null,*/
                      width: scaler.getWidth(12),
                      height: scaler.getHeight(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(height: scaler.getHeight(0.5)),
                          highlightedText(
                              Text(
                                event.topic!,
                                textDirection: ui.TextDirection.rtl,
                                // textDirection: TextDirection.RTL,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: scaler.getTextSize(7.5),
                                    fontWeight: FontWeight.bold),
                              ),
                              context),
                          highlightedText(
                              Text(
                                event.book!,
                                textDirection: ui.TextDirection.rtl,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: scaler.getTextSize(6.5)),
                              ),
                              context),
                          SizedBox(height: scaler.getHeight(0.5)),
                          Expanded(
                              child: Container(
                                  //width: scaler.getWidth(28),
                                  height: scaler.getHeight(1),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        SizedBox(width: scaler.getWidth(1)),
                                        registeredState1,
                                        registeredState2,
                                        registeredState3,
                                        Expanded(
                                            child: Text(
                                          (event.participants!
                                                      .length /*+
                                                      (event.waitingQueue
                                                              ?.length ??
                                                          0)*/
                                                  )
                                                  .toString() +
                                              "/" +
                                              event.maxParticipants.toString(),
                                          // textDirection: TextDirection.rtl,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: scaler.getTextSize(6)),
                                        )),
                                        SizedBox(width: scaler.getWidth(1)),
                                        SizedBox(
                                            child: Icon(
                                                event.type == 'L'
                                                    ? FontAwesomeIcons
                                                        .graduationCap
                                                    : FontAwesomeIcons.users,
                                                size: scaler.getTextSize(8),
                                                color: Colors.red)),
                                        SizedBox(width: scaler.getWidth(3)),
                                        noClickAndClock
                                            ? Container()
                                            : Row(
                                                //mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                    Text(
                                                      event.dates!.isEmpty
                                                          ? "-נגמר-"
                                                          : DateFormat(
                                                                  'd-M-yyyy')
                                                              .format(event
                                                                  .dates![0]),
                                                      //textDirection: TextDirection.rtl,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          fontSize: scaler
                                                              .getTextSize(6)),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            scaler.getWidth(1)),
                                                    Icon(FontAwesomeIcons.clock,
                                                        size: scaler
                                                            .getTextSize(8),
                                                        color: Colors.red)
                                                  ])
                                      ])))
                        ],
                      ),
                    )),
                    SizedBox(width: scaler.getWidth(3)),
                    Column(children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        width: scaler.getWidth(5),
                        height: scaler.getHeight(3),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent[400],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(60.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.teal[400]!,
                                offset: const Offset(2, 0),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            event.eventImage ?? MyConsts.DEFAULT_EVENT_IMG,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Globals.scaler.getWidth(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            highlightedText(
                                Text(
                                    this.event.type == "L"
                                        ? event.lecturer!
                                        : event.creatorName!,
                                    textDirection: ui.TextDirection.rtl,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: scaler.getTextSize(6)),
                                    textAlign: TextAlign.center),
                                context,
                                // even when this.event.type == "H" the search will work, so dont ignore
                                ignore: false),
                          ],
                        ),
                      ),
                    ]),
                    SizedBox(width: scaler.getWidth(1))
                  ]),
            )));
  }
}
