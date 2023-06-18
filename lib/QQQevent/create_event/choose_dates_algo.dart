import 'package:flutter/material.dart';

// add days, but keep fixed hour, even if less/more than 24*days hours will be passed (daylight saving)
DateTime smartPlus(DateTime x, int days) {
  x = x.toLocal();
  var diff = x.hour;
  x = x.add(Duration(days: days));
  diff = diff - x.hour;
  if (diff < 0) {
    x = x.subtract(Duration(hours: -diff));
  } else {
    x = x.add(Duration(hours: diff));
  }
  return x;
}
//import 'package:havruta_project/QQQglobals.dart';
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
  //DateTime next = first.add(Duration(days: frequency));
  DateTime next = smartPlus(first, frequency);
  // Add one day to the last date, cause isAfter work like >= (including the equal)
  dateEnd = dateEnd.add(Duration(days: 1));
  // Calculate all dates before the last date
  while (!next.isAfter(dateEnd)) {
    dates.add(next);
    //next = next.add(Duration(days: frequency));
    next = smartPlus(next, frequency);
  }
  return dates;
}
