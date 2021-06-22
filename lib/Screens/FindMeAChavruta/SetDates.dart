import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Second_Dot_Row.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'FindMeAChavruta2.dart';
import 'Wavy_Header.dart';

class SetDate extends StatefulWidget {
  Event event;
  SetDate({this.event});

  @override
  _SetDateCreateState createState() => _SetDateCreateState();
}

class _SetDateCreateState extends State<SetDate> {
  var db = Globals.db;
  double spaceBetween, spaceBetweenTimes;
  String dateTime;
  List<DateTime> dateTimeListForMongo = [];
  String text = "בחרו זמנים ללמוד", dayStr;
  TimeOfDay startTime, endTime;
  DateTime date, start, end;
  String startDate, endDate, fullDate;
  int howManyChosen = 0;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myController = TextEditingController();

  Future<DateTime> pickDay(BuildContext context) {
    final date = pickDate(context);
    if (date == null) return null;
    return date;
  }

  Future<DateTime> pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (newDate == null) return null;
    setState(() => date = newDate);
  }

  Future<TimeOfDay> pickStartTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      helpText: 'Select Start Time',
      initialTime: startTime != null
          ? TimeOfDay(hour: startTime.hour, minute: startTime.minute)
          : initialTime,
    );
    if (newTime == null) return null;
    setState(() => startTime = newTime);
  }

  Future<TimeOfDay> pickEndTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      helpText: 'Select End Time',
      initialTime: endTime != null
          ? TimeOfDay(hour: endTime.hour, minute: endTime.minute)
          : initialTime,
    );
    if (newTime == null) return null;
    if (startTime.hour > newTime.hour) {
      alertMessage("זמן התחלה צריך להיות לפני זמן סיום");
      return null;
    }
    if (startTime.hour == newTime.hour && startTime.minute >= newTime.minute) {
      alertMessage("זמן התחלה צריך להיות לפני זמן סיום");
      return null;
    }
    setState(() => endTime = newTime);
  }

  void saveData() {
    if (startTime == null || endTime == null || date == null) {
      alertMessage("חסר שדות");
      return null;
    } else {
      setState(() {
        start = DateTime(
            date.year, date.month, date.day, startTime.hour, startTime.minute);
        end = DateTime(
            date.year, date.month, date.day, endTime.hour, endTime.minute);
        //   dateTimeListForMongo.add(start);
        //   dateTimeListForMongo.add(end);
        //   this.startDate = DateFormat('MM-dd-yyyy: kk:mm').format(start);
        //   this.endDate = DateFormat('kk:mm').format(end);
        //   this.fullDate = startDate + " - " + this.endDate;
        //   this.howManyChosen++;
        //   widget.event.dates = dateTimeListForMongo;
      });
      //Navigator.pop(context, this.fullDate);
      Navigator.pop(context, [this.start, this.end]);
    }
  }

  @override
  Widget build(BuildContext context) {
    spaceBetween = 120;
    spaceBetweenTimes = 40;
    return Scaffold(
        appBar: appBar(),
        body: Builder(
            builder: (context) => Center(
                  child: Stack(children: [
                    Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: WavyHeader()),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Padding(padding: const EdgeInsets.only(top: 20.0)),
                        SizedBox(
                          height: spaceBetween,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: 330, height: 60),
                                  child: ElevatedButton(
                                    onPressed: () => pickDate(context),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.teal,
                                        //shape: (),
                                        shadowColor:
                                            Colors.grey.withOpacity(1)),
                                    child: Text(getDateText(this.date),
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: spaceBetweenTimes,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                  width: 330, height: 60),
                              child: ElevatedButton(
                                onPressed: () => pickStartTime(context),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.teal,
                                    //shape: (),
                                    shadowColor: Colors.grey.withOpacity(1)),
                                child: Text(getStartTimeText(),
                                    style: TextStyle(fontSize: 20)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: spaceBetweenTimes,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                  width: 330, height: 60),
                              child: ElevatedButton(
                                onPressed: () => pickEndTime(context),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.teal,
                                    //shape: (),
                                    shadowColor: Colors.grey.withOpacity(1)),
                                child: Text(getEndTimeText(),
                                    style: TextStyle(fontSize: 20)),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                        ),
                        SizedBox(height: spaceBetween),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.all(12.0)),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  //shape: (),
                                  shadowColor: Colors.grey.withOpacity(1)),
                              child: Text("בטל"),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 235.0)),
                            ElevatedButton(
                              onPressed: () => saveData(),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  //shape: (),
                                  shadowColor: Colors.grey.withOpacity(1)),
                              child: Text("שמור"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
                )));
  }

  appBar() {
    return new AppBar(
        leadingWidth: 20,
        toolbarHeight: 40,
        elevation: 10,
        shadowColor: Colors.teal[400],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        )),
        backgroundColor: Colors.white,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            'הוסיפו זמני לימוד  ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.clock, size: 25, color: Colors.teal[400])
        ]));
  }

  alertMessage(String text) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "אי אפשר לשמור את התאריך!",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      content: Text(text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String getDateText(date) {
    if (date == null) {
      return "בחר תאריך";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String getStartTimeText() {
    if (startTime == null) {
      return "בחר זמן התחלה";
    } else {
      final hours = startTime.hour.toString().padLeft(2, '0');
      final minutes = startTime.minute.toString().padLeft(2, '0');

      return '$hours:$minutes';
    }
  }

  String getEndTimeText() {
    if (endTime == null) {
      return "בחר זמן סיום";
    } else {
      final hours = endTime.hour.toString().padLeft(2, '0');
      final minutes = endTime.minute.toString().padLeft(2, '0');

      return '$hours:$minutes';
    }
  }
}
