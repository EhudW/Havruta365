import 'package:havruta_project/Widgets/Button_Widget.dart';

import '../Widgets/Button_Widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class BuildList extends StatefulWidget {
//   List<String> dateTimes;
//   @override
//   _BuildListState createState() => _BuildListState();
// }
//
// class _BuildListState extends State<BuildList> {
//   @override
//   Widget build(BuildContext context) => ButtonHeaderWidget();
// }

class DatePicker extends StatefulWidget {
  List<String> dateTimes;

  DatePicker(List<String> dt) {
    this.dateTimes = dt;
  }

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime dateTime;

  // String getText() {
  //   if (dateTime == null) {
  //     return 'בחרו זמנים ללמוד';
  //   } else {
  //     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  //   }
  // }

  String getText() {
    return 'בחרו זמנים ללמוד';
  }

  @override
  Widget build(BuildContext context) => ButtonHeaderWidget(
        title: '',
        text: getText(),
        onClicked: () => pickDateTime(context),
      );

  Future pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;

    final time = await pickTime(context);
    if (time == null) return;
    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });

    String formattedDate = DateFormat('MM-dd-yyyy – kk:mm').format(dateTime);
    widget.dateTimes.add(formattedDate);
    _buildListView(formattedDate);
    print(widget.dateTimes);
  }

  Future<DateTime> pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: dateTime ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return null;

    return newDate;
  }

  Future<TimeOfDay> pickTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialTime: dateTime != null
          ? TimeOfDay(hour: dateTime.hour, minute: dateTime.minute)
          : initialTime,
    );

    if (newTime == null) return null;

    return newTime;
  }

  Widget _buildListView(String date) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          return _buildRow("row: " + date);
        });
  }

  Widget _buildRow(String message) {
    return ListTile(
      title: Text(
        message,
        //style: _biggerFont,
      ),
    );
  }
}
