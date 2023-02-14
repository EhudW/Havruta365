import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:havruta_project/DataBase_auth/User.dart';
//import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class EventViewFeed extends StatelessWidget {
  final Event event;
  final String? search;
  const EventViewFeed({Key? key, required this.event, this.search})
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

    return Material(
        child: InkWell(
            splashColor: Colors.teal[400],
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EventScreen(event)));
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Container(
                    width: scaler.getWidth(12),
                    height: scaler.getHeight(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: scaler.getHeight(0.5)),
                        highlightedText(
                            Text(
                              event.topic!,
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
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: scaler.getTextSize(6.5)),
                            ),
                            context),
                        SizedBox(height: scaler.getHeight(0.5)),
                        Expanded(
                            child: Container(
                                width: scaler.getWidth(18),
                                height: scaler.getHeight(1),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        event.participants!.length.toString() +
                                            "/" +
                                            event.maxParticipants.toString(),
                                        // textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: scaler.getTextSize(6)),
                                      )),
                                      SizedBox(width: scaler.getWidth(0.5)),
                                      Expanded(
                                          child: Icon(
                                              event.type == 'L'
                                                  ? FontAwesomeIcons
                                                      .graduationCap
                                                  : FontAwesomeIcons.users,
                                              size: scaler.getTextSize(8),
                                              color: Colors.red)),
                                      SizedBox(width: scaler.getWidth(3)),
                                      Row(
                                          //mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              DateFormat('d-M-yyyy')
                                                  .format(event.dates![0]),
                                              //textDirection: TextDirection.rtl,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize:
                                                      scaler.getTextSize(6)),
                                            ),
                                            SizedBox(width: scaler.getWidth(1)),
                                            Icon(FontAwesomeIcons.clock,
                                                size: scaler.getTextSize(8),
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
                          event.eventImage!,
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
                ])));
  }
}
