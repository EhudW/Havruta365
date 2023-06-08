// ignore_for_file: non_constant_identifier_names

import 'package:another_flushbar/flushbar.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Authenitcate.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Second_Dot_Row.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../Globals.dart';
//import 'package:havruta_project/Screens/Login/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../EventScreen/MyProgressButton.dart';
import 'ChooseDatesAlgo.dart';
import 'FindMeAChavruta3.dart';
import 'dart:ui' as UI;

class ChooseDates extends StatefulWidget {
  final Event? event;

  List<Event>? allUserEvents;
  ChooseDates({this.event, this.allUserEvents});

  @override
  _ChooseDates createState() => _ChooseDates();
}

class _ChooseDates extends State<ChooseDates> {
  final AuthService authenticate = AuthService();

  late DateTime firstDate;
  TimeOfDay time = TimeOfDay.now();
  DateTime? lastDate = DateTime.now();
  String? frequency = "יומי";
  double? eventDuration = 30;
  @override
  void initState() {
    super.initState();
    if (widget.event!.id != null) {
      Event event = widget.event!;
      final DateTime now = DateTime.now();
      event.dates = (event.dates ?? []).where((t) => t.isAfter(now)).toList();
      firstDate = event.dates!.isNotEmpty
          ? event.dates!.first.toLocal()
          : DateTime.now().add(Duration(days: 1));
      lastDate =
          event.dates!.isNotEmpty ? event.dates!.last.toLocal() : lastDate;
      time = TimeOfDay.fromDateTime(firstDate);
      eventDuration = event.duration?.toDouble() ?? eventDuration;
      if (event.dates!.isEmpty) {
        frequency = frequency;
      } else if (event.dates!.first == event.dates!.last) {
        frequency = "חד פעמי";
      } else if (event.dates![1].difference(event.dates!.first).inDays > 8) {
        frequency = "חודשי";
      } else if (event.dates![1].difference(event.dates!.first).inDays > 2) {
        frequency = "שבועי";
      } else {
        frequency = "יומי";
      }
    }
  }

  Future<void> _selectFirstDate(BuildContext context) async {
    final DateTime? picked = await (showDatePicker(
        context: context,
        initialDate: firstDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)));
    DateTime now = DateTime.now();
    // TODO: check logic
    if (picked == null || now.isAfter(picked)) {
      Flushbar(
        title: 'שגיאה',
        message: 'לא ניתן לבחור תאריך שעבר',
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }
    //if (picked != null && picked != firstDate)
    if (picked != firstDate)
      setState(() {
        firstDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: time);
    if (picked != null && picked != time)
      setState(() {
        time = picked;
      });
  }

  Future<void> _selectLastDate(BuildContext context) async {
    DateTime? picked = firstDate;
    picked = await (showDatePicker(
        context: context,
        initialDate: lastDate!,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)));
    final difference = picked?.difference(firstDate).inDays ?? 400;
    if (difference > 365) {
      Flushbar(
        title: 'שגיאה',
        message: 'לא ניתן לקבוע שיעורים ליותר משנה',
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }
    // in this line, picked != null
    if (picked == null || picked.isBefore(firstDate)) {
      Flushbar(
        title: 'שגיאה',
        message: 'תאריך אחרון חייב להיות לאחר תאריך ראשון',
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }
    if (picked != lastDate)
      setState(() {
        lastDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Globals.scaler.getHeight(2)),
            // First date
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "בחר תאריך לאירוע   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            InkWell(
              onTap: () => _selectFirstDate(context),
              child: Container(
                alignment: AlignmentDirectional.center,
                width: Globals.scaler.getWidth(32),
                height: Globals.scaler.getHeight(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(1),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Text(DateFormat('dd - MM - yyyy').format(firstDate),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.varelaRound(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent)),
              ),
            ),
            SizedBox(height: Globals.scaler.getHeight(1)),
            // Time
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "בחר שעה לאירוע   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                alignment: AlignmentDirectional.center,
                width: Globals.scaler.getWidth(32),
                height: Globals.scaler.getHeight(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(1),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Text(time.format(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.varelaRound(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent)),
              ),
            ),
            // Event Duration
            SizedBox(height: Globals.scaler.getHeight(1)),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  this.widget.event!.type == "L"
                      ? "בחר את משך השיעור (דקות)   "
                      : "בחר את משך החברותא (דקות)   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            SfSlider(
              value: eventDuration,
              onChanged: (new_duration) {
                setState(() => eventDuration = new_duration);
              },
              min: 30,
              max: 180,
              showLabels: true,
              showTicks: true,
              enableTooltip: true,
              interval: 30,
              stepSize: 30,
              // divisions: 7,
              // label:  "${eventDuration.round().toString()}דקות ",
            ),
            SizedBox(height: Globals.scaler.getHeight(1)),
            // Frequency
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "בחר תדירות לאירוע   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(0.5)),
            InkWell(
                child: Container(
              alignment: AlignmentDirectional.center,
              width: Globals.scaler.getWidth(32),
              height: Globals.scaler.getHeight(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      offset: const Offset(0, 2),
                      blurRadius: 8.0),
                ],
              ),
              child: DropdownButton<String>(
                value: frequency,
                isExpanded: true,
                borderRadius: BorderRadius.circular(50),
                elevation: 100,
                onChanged: (String? newValue) {
                  setState(() {
                    frequency = newValue;
                  });
                },
                items: <String>['יומי', 'שבועי', 'חודשי', 'חד פעמי']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      child: Text(value,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.varelaRound(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent)),
                    ),
                  );
                }).toList(),
              ),
            )),
            SizedBox(height: Globals.scaler.getHeight(1)),
            // Last date
            Column(
              children: frequency == "חד פעמי"
                  ? []
                  : [
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "בחר תאריך אחרון לאירוע   ",
                            style: GoogleFonts.alef(
                                fontSize: 18, color: Colors.teal[400]),
                          )),
                      SizedBox(height: Globals.scaler.getHeight(0.5)),
                      InkWell(
                        onTap: () => _selectLastDate(context),
                        child: Container(
                          alignment: AlignmentDirectional.center,
                          width: Globals.scaler.getWidth(32),
                          height: Globals.scaler.getHeight(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.withOpacity(1),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8.0),
                            ],
                          ),
                          child: Text(
                              DateFormat('dd - MM - yyyy').format(lastDate!),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.varelaRound(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrangeAccent)),
                        ),
                      ),
                    ],
            ),
            SizedBox(height: Globals.scaler.getHeight(1.4)),
            SecondDotRow(),
            SizedBox(height: Globals.scaler.getHeight(0.6)),
            ElevatedButton(
              child: Icon(Icons.arrow_forward_outlined,
                  textDirection: UI.TextDirection.rtl, color: Colors.white),

              /*Text(
                "המשך",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(fontSize: 23, color: Colors.white),
              )*/
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize: Size(
                      Globals.scaler.getWidth(32), Globals.scaler.getHeight(3)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(38.0),
                  ),
                  backgroundColor: Colors.teal,
                  // <-- Button color
                  foregroundColor: Colors.teal),
              onPressed: () async {
                lastDate = frequency == "חד פעמי" ? firstDate : lastDate;

                if (isDatesValid(firstDate, time, lastDate!, context)) {
                  // Calculate dates
                  int frequencyInt = convertFrquency2Int(frequency);
                  List<DateTime> dates =
                      calcDates(firstDate, time, lastDate!, frequencyInt);

                  widget.event!.dates = dates;
                  widget.event!.duration = eventDuration!.round();
                  var nextPage = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FindMeAChavruta3(event: widget.event)),
                      );
                  // -- check for overlap
                  var overlaps = getEventsOverlap(
                      widget.event!, widget.allUserEvents ?? []);

                  if (overlaps.isNotEmpty) {
                    var ok = () {
                      Navigator.pop(context);
                      nextPage();
                    };
                    var ignore = () => Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) =>
                          bottomSheet(overlaps, context, ok, ignore)),
                    );
                    return;
                  }
                  // -- if no overlap:
                  nextPage();
                }
              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1))
          ],
        ),
      ),
    );
  }
}

int convertFrquency2Int(String? frequency) {
  switch (frequency) {
    case 'יומי':
      {
        return 1;
      }
    //break;
    case 'שבועי':
      {
        return 7;
      }
    //break;
    case 'חודשי':
      {
        return 30;
      }
    //break;
    case 'חד פעמי':
      {
        return 0;
      }
  }
  return 0; // TODO : check if correct logic
}

isDatesValid(DateTime firstDate, TimeOfDay time, DateTime lastDate,
    BuildContext context) {
  if (lastDate.isBefore(firstDate)) {
    Flushbar(
      title: 'שגיאה',
      message: 'תאריך אחרון חייב להיות לאחר תאריך ראשון',
      duration: Duration(seconds: 3),
    )..show(context);
    return false;
  }
  return true;
}

appBar(BuildContext context) {
  ScreenScaler scaler = new ScreenScaler();

  return new AppBar(
      leadingWidth: 0,
      toolbarHeight: 40,
      elevation: 30,
      shadowColor: Colors.teal[400],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(0),
      )),
      backgroundColor: Colors.white,
      title: Container(
        width: scaler.getWidth(50),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            "?מתי תרצו ללמוד  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(
                fontWeight: FontWeight.bold,
                fontSize: Globals.scaler.getTextSize(9),
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.clock, size: 20, color: Colors.teal[400])
        ]),
      ));
}
