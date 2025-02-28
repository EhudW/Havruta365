//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as ADD2CALENDAR;

class Add2Calendar extends StatefulWidget {
  Add2Calendar(this.event);

  final Event? event;

  @override
  _Add2CalendarState createState() => _Add2CalendarState();
}

class _Add2CalendarState extends State<Add2Calendar> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        add2calendar(widget.event!);
      },
      icon: Icon(FontAwesomeIcons.calendarCheck, size: 18),
      label: Text("הוסף ליומן"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
    );
  }
}

add2calendar(Event event, {bool ignorePast = true}) {
  //copy list
  List<DateTime> future = [];
  future.addAll(event.dates!.map((e) => e)); // no need to add +2 from utc

  // keep only dates that aren't older than yestarday
  if (ignorePast == true) {
    future.retainWhere((element) =>
        DateTime.now().subtract(Duration(days: 1)).isBefore(element));
  }
  // left events?
  if (future.isEmpty) {
    return;
  }
  // sort from early to late
  future.sort();

  ADD2CALENDAR.Frequency frequency = ADD2CALENDAR.Frequency.daily;
  if (future.length > 1 && future[1].difference(future.first).inDays > 2) {
    frequency = ADD2CALENDAR.Frequency.weekly;
  }
  if (future.length > 1 && future[1].difference(future.first).inDays > 8) {
    frequency = ADD2CALENDAR.Frequency.monthly;
  }

  String topic = event.topic?.trim() ?? "";
  String book = event.book?.trim() ?? "";
  String type = event.type == "H" ? "חברותא" : "שיעור";
  String link = event.link?.trim() ?? "";
  String location = event.location?.trim() ?? "";
  String description = event.description?.trim() ?? "";
  String lecturer = event.lecturer?.trim() ?? "";
  String creator = event.creatorName?.trim() ?? "";
  String teacher = event.type == "H" ? creator : lecturer;
  int minutesPerMeeting = event.duration ?? 30;
  //String title = book;
  //title = title.trim() != "" ? title : topic;
  //title = "$type: $title";
  String t_book = book != "" ? " ב" + book : "";
  String t_topic = topic != "" ? " ב" + topic : "";
  String title = type + t_topic + t_book + " " + "(חברותא+)";

  // return val; or "" if checkNotEmpty is empty NONNULLABLE STRING;
  // if checkNotEmpty ommited(NULL) then val is checked
  var n = (String val, [String? checkNotEmpty]) =>
      (checkNotEmpty ?? val) == "" ? "" : val;
  // if any element of checkNotEmpty array is not empty than ret val, else ""
  var nA = (String val, List<String> checkNotEmpty) =>
      checkNotEmpty.any((e) => e != "") ? val : "";

  String r = "$type:";
  r += n(" $topic", topic);
  r += n("\n$book", book);
  r += "\n";
  r += nA("\n", [teacher, location, link, description]);
  r += n("$teacher\n", teacher);
  r += n("$location\n", location);
  r += n("$link\n", link);
  r += n("------\n$description\n", description);
  r += "------";
  /*  
  will look like
      [$type:[ $topic]] [\n$book] \n [\n [$teacher\n] [$location\n] [$link\n] [------\n$description\n] ] [------]
      [$type:         ] [\n$book] \n [\n                                                 ] [------]
             [ $topic]                   [$teacher\n] [$location\n] [$link\n] [------\n$description\n]                    
  */

  String formattedDescription =
      "$type: $topic\n$book\n\n$teacher\n$location\n$link\n------\n$description\n------";
  formattedDescription = r;
  // ignore: non_constant_identifier_names
  final ADD2CALENDAR.Event add2cal_event = ADD2CALENDAR.Event(
      title: title,
      description: formattedDescription,
      location: location != "" ? location : (link == "" ? null : link),
      startDate: future.first,
      endDate: future.first.add(Duration(minutes: minutesPerMeeting)),
      recurrence: future.first == future.last
          ? null
          : ADD2CALENDAR.Recurrence(
              frequency: frequency,
              endDate: future.last,
              interval: 1,
              ocurrences: null));
  // Open calendar
  ADD2CALENDAR.Add2Calendar.addEvent2Cal(add2cal_event);
}
