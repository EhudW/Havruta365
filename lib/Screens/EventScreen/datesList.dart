import 'package:flutter/cupertino.dart';

class DatesList extends StatelessWidget{

  List<DateTime> dates;
  DatesList(this.dates);
  DateTime a = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView(
      children: [Text(a.toString()),Text(a.toString()),Text(a.toString())]
    );
  }

}

// a.format('d.m.Y, H:i')