import 'package:flutter/material.dart';
//import 'package:havruta_project/Globals.dart';
//import 'package:intl/intl.dart';

// calc dates. input: date_start, time_start, date_end
// freq < 1   -->   List<DateTime> ( [dateStart] )
List<DateTime> calcDates(
    DateTime dateStart, TimeOfDay timeStart, DateTime dateEnd, int frequency) {
  List<DateTime> dates = [];
  // First day with start time
  DateTime first = new DateTime(dateStart.year, dateStart.month, dateStart.day,
      timeStart.hour, timeStart.minute);
  dates.add(first);
  if (frequency < 1) {
    return dates;
  }
  DateTime next = first.add(Duration(days: frequency));
  // Add one day to the last date, cause isAfter work like >= (including the equal)
  dateEnd = dateEnd.add(Duration(days: 1));
  // Calculate all dates before the last date
  while (!next.isAfter(dateEnd)) {
    dates.add(next);
    next = next.add(Duration(days: frequency));
  }
  return dates;
}
