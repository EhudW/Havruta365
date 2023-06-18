//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
//import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'wavy_header.dart';

// ignore: must_be_immutable
class SetDate extends StatefulWidget {
  Event? event;

  SetDate({this.event});

  @override
  _SetDateCreateState createState() => _SetDateCreateState();
}

class _SetDateCreateState extends State<SetDate> {
  var db = Globals.db;
  double? spaceBetween, spaceBetweenTimes;
  String? dateTime;
  List<DateTime> dateTimeListForMongo = [];
  String? text = "בחרו זמנים ללמוד", dayStr;
  TimeOfDay? startTime, endTime;
  DateTime? date, start, end;
  String? startDate, endDate, fullDate;
  int howManyChosen = 0;

  Future<DateTime?> pickDay(BuildContext context) {
    final date = pickDate(context);
    //if (date == null) return null;
    return date;
  }

  Future<DateTime?> pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (newDate == null) return null;
    if (DateTime.now().isAfter(newDate) && DateTime.now().day > newDate.day) {
      alertMessage("אי אפשר לבחור תאריך שעבר");
      return null;
    }
    setState(() => date = newDate);
    return newDate; // TODO : CHECK ????
  }

  Future<TimeOfDay?> pickStartTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      helpText: 'Select Start Time',
      initialTime: startTime != null
          ? TimeOfDay(hour: startTime!.hour, minute: startTime!.minute)
          : initialTime,
    );
    if (newTime == null) return null;
    if (date!.day == DateTime.now().day) {
      if (((newTime.hour < DateTime.now().hour) ||
          ((newTime.hour == DateTime.now().hour) &&
              newTime.minute < DateTime.now().minute))) {
        alertMessage("אי אפשר לבחור תאריך שעבר");
        return null;
      }
    }
    setState(() => startTime = newTime);
    return newTime; // TODO : ??
  }

  Future<TimeOfDay?> pickEndTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 10, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      helpText: 'Select End Time',
      initialTime: endTime != null
          ? TimeOfDay(hour: endTime!.hour, minute: endTime!.minute)
          : initialTime,
    );
    if (newTime == null) return null;
    if (startTime!.hour > newTime.hour) {
      alertMessage("זמן התחלה צריך להיות לפני זמן סיום");
      return null;
    }
    if (startTime!.hour == newTime.hour &&
        startTime!.minute >= newTime.minute) {
      alertMessage("זמן התחלה צריך להיות לפני זמן סיום");
      return null;
    }
    setState(() => endTime = newTime);
    return newTime;
  }

  void saveData() {
    if (startTime == null || endTime == null || date == null) {
      alertMessage("חסר שדות");
      return null;
    } else {
      setState(() {
        start = DateTime(date!.year, date!.month, date!.day, startTime!.hour,
            startTime!.minute);
        end = DateTime(
            date!.year, date!.month, date!.day, endTime!.hour, endTime!.minute);
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
    spaceBetween = Globals.scaler.getHeight(4);
    spaceBetweenTimes = Globals.scaler.getHeight(2);
    return Scaffold(
        appBar: appBar(),
        body: Builder(
          builder: (context) => Center(
            child: Stack(children: [
              Column(
                children: [
                  WavyHeader(),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                                padding:
                                    EdgeInsets.all(Globals.scaler.getWidth(1))),
                            Text(
                              "תאריך     ",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Globals.scaler.getTextSize(8.3),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(
                          height: Globals.scaler.getHeight(0.5),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                  width: Globals.scaler.getWidth(26),
                                  height: Globals.scaler.getHeight(3)),
                              child: ElevatedButton(
                                onPressed: () => pickDate(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: StadiumBorder(),
                                    shadowColor: Colors.grey.withOpacity(1)),
                                child: Text(getDateText(this.date),
                                    style: TextStyle(
                                        fontSize:
                                            Globals.scaler.getTextSize(8.5))),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "זמן התחלה     ",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: Globals.scaler.getTextSize(8.3),
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: Globals.scaler.getHeight(0.5),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                              width: Globals.scaler.getWidth(26),
                              height: Globals.scaler.getHeight(3)),
                          child: ElevatedButton(
                            onPressed: () => pickStartTime(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: StadiumBorder(),
                                shadowColor: Colors.grey.withOpacity(1)),
                            child: Text(getStartTimeText(),
                                style: TextStyle(
                                    fontSize: Globals.scaler.getTextSize(8.5))),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: spaceBetweenTimes,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "זמן סיום     ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: Globals.scaler.getTextSize(8.3),
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: Globals.scaler.getHeight(0.5),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                              width: Globals.scaler.getWidth(26),
                              height: Globals.scaler.getHeight(3)),
                          child: ElevatedButton(
                            onPressed: () => pickEndTime(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: StadiumBorder(),
                                shadowColor: Colors.grey.withOpacity(1)),
                            child: Text(getEndTimeText(),
                                style: TextStyle(
                                    fontSize: Globals.scaler.getTextSize(8.5))),
                          ),
                        )
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(2.0),
                    // ),
                    SizedBox(height: spaceBetween),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              //shape: (),
                              shadowColor: Colors.grey.withOpacity(1)),
                          child: Text("בטל"),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                right: Globals.scaler.getWidth(13))),
                        ElevatedButton(
                          onPressed: () => saveData(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shadowColor: Colors.grey.withOpacity(1)),
                          child: Text("שמור"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ));
  }

  appBar() {
    return new AppBar(
        leadingWidth: Globals.scaler.getWidth(0),
        toolbarHeight: Globals.scaler.getHeight(2),
        elevation: Globals.scaler.getHeight(1),
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
          Icon(FontAwesomeIcons.clock,
              size: Globals.scaler.getTextSize(9), color: Colors.teal[400])
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
        "!אי אפשר לשמור את התאריך",
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
      final hours = startTime!.hour.toString().padLeft(2, '0');
      final minutes = startTime!.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    }
  }

  String getEndTimeText() {
    if (endTime == null) {
      return "בחר זמן סיום";
    } else {
      final hours = endTime!.hour.toString().padLeft(2, '0');
      final minutes = endTime!.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    }
  }
}
