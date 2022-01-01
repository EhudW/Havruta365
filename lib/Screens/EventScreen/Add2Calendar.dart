import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as ADD2CALENDAR;

class Add2Calendar extends StatefulWidget {
  Add2Calendar(this.event);

  final Event event;

  @override
  _Add2CalendarState createState() => _Add2CalendarState();
}

class _Add2CalendarState extends State<Add2Calendar> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        add2calendar(widget.event);
      },
      icon: Icon(FontAwesomeIcons.calendarCheck, size: 18),
      label: Text("הוסף ליומן"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
    );
  }
}

add2calendar(Event event) {
  final ADD2CALENDAR.Event add2cal_event = ADD2CALENDAR.Event(
    title: event.topic,
    description: "${event.description} \n${event.link}",
    location: "Online - Link in the description",
    startDate: event.dates[0],
    endDate: event.dates[1],
    // TODO add recurrence
    // recurrence:
  );
  // Open calendar
  ADD2CALENDAR.Add2Calendar.addEvent2Cal(add2cal_event);
}
