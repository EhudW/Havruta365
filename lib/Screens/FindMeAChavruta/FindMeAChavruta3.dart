import 'package:adobe_xd/adobe_xd.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:adobe_xd/pinned.dart';
import 'FindMeAChavruta2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ListViews extends StatefulWidget {
  //ListViews({Key key, this.title}) : super(key: key);
  final String title = "Hello";
  List<String> dates;
  int num = 1;

  ListViews(List<String> dt, int n) {
    this.dates = dt;
    this.num = n;
  }

  @override
  _ListViewsState createState() => _ListViewsState();
}

class _ListViewsState extends State<ListViews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildListView(widget.dates, widget.num),
    );
  }

  Widget _buildListView(List<String> dates, int numOfChavrutot) {
    return Container(
        height: 500,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.teal[400],
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        //width: 200,
        child: ListView.builder(
            itemCount: numOfChavrutot,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              var ind = index + 1;
              var message =
                  ("Chavruta " + ind.toString() + ":  " + '${dates[index]}');
              return ListTile(
                title: Text(
                  message,
                  style: TextStyle(fontSize: 20),
                ),
              );
            }));
  }

  // Widget buildRow(String message) {
  //   // Container(
  //   //   decoration: new BoxDecoration(color: Colors.teal),
  //   //   child:
  //   return ListTile(
  //     title: Text(
  //       message,
  //       style: TextStyle(fontSize: 20),
  //     ),
  //   );
  // }
}

class FindMeAChavruta3 extends StatefulWidget {
  @override
  _FindMeAChavruta3CreateState createState() => _FindMeAChavruta3CreateState();
}

class _FindMeAChavruta3CreateState extends State<FindMeAChavruta3> {
  var db = Globals.db;
  List<String> dateTimes = [];
  List<DateTime> dateTimeListForMongo = [];
  String text = "בחרו זמנים ללמוד";
  DateTime start, end;
  String startDate, endDate, fullDate;
  int howManyChosen = 0;

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Future pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;
    final startTime = await pickTime(context);
    final endTime = await pickTime(context);
    print(endTime);
    if (startTime == null || endTime == null) return;
    // if (startTime == endTime) {
    //   print("cant have start and end time the same");
    //   return;
    // }
    setState(() {
      start = DateTime(
          date.year, date.month, date.day, startTime.hour, startTime.minute);
      end = DateTime(
          date.year, date.month, date.day, endTime.hour, endTime.minute);
      print("startTime");
      print(startTime);
      print("endtime");
      print(end);
      dateTimeListForMongo.add(start);
      this.startDate = DateFormat('MM-dd-yyyy: kk:mm').format(start);
      this.endDate = DateFormat('kk:mm').format(end);
      print(this.endDate);
      this.fullDate = startDate + " - " + this.endDate;
      this.howManyChosen++;
      print(this.fullDate);
      dateTimes.add(this.fullDate);
      //ListViews(formattedDate);
    });

    //print(widget.dateTimes);
  }

  Future<DateTime> pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: start ?? initialDate,
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
      initialTime: start != null
          ? TimeOfDay(hour: start.hour, minute: start.minute)
          : initialTime,
    );

    if (newTime == null) return null;

    return newTime;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 667),
        orientation: Orientation.portrait);
    return Scaffold(
        appBar: CustomAppBar(
          title: "חברותא חדשה",
          gradientBegin: Colors.blue,
          gradientEnd: Colors.greenAccent,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                    ),
                    Container(
                        child: ElevatedButton(
                            onPressed: () => pickDateTime(context),
                            style: ElevatedButton.styleFrom(
                                //minimumSize: Size.fromHeight(20),
                                primary: Colors.teal[400],
                                onSurface: Colors.white70),
                            child: Container(
                              height: 50,
                              width: 200,
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 10.0, 10.0, 10.0),
                              decoration: BoxDecoration(
                                color: Colors.teal[400],
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: FittedBox(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),

                              // child: DatePicker(dateTimes),
                            ))),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                    ),
                    Expanded(
                        child: ListViews(this.dateTimes, this.howManyChosen)),

                    //===================CHOOSE TIME========================

                    //BuildList(dateTimes),
                  ],
                ),
              ),

              //===================CHOOSE TIME========================
              Padding(
                padding: EdgeInsets.fromLTRB(55, 25, 10, 0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 6,
                    child: Stack(
                      children: <Widget>[
                        Pinned.fromSize(
                          bounds: Rect.fromLTWH(32.0, 0.0, 6.0, 6.0),
                          size: Size(54.0, 6.0),
                          pinTop: true,
                          pinBottom: true,
                          fixedWidth: true,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(9999.0, 9999.0)),
                              color: Colors.teal[400],
                            ),
                          ),
                        ),
                        Pinned.fromSize(
                          bounds: Rect.fromLTWH(16.0, 0.0, 6.0, 6.0),
                          size: Size(54.0, 6.0),
                          pinTop: true,
                          pinBottom: true,
                          fixedWidth: true,
                          child: SvgPicture.string(
                            _svg_h36wzl,
                            allowDrawingOutsideViewBox: true,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Pinned.fromSize(
                          bounds: Rect.fromLTWH(48.0, 0.0, 6.0, 6.0),
                          size: Size(54.0, 6.0),
                          pinTop: true,
                          pinBottom: true,
                          fixedWidth: true,
                          child: SvgPicture.string(
                            _svg_h36wzl,
                            allowDrawingOutsideViewBox: true,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //########### ----NEXT ARROW----########
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Adobe XD layer: 'Next' (group)
                  SizedBox(
                    width: 335,
                    height: 48,
                    child: Stack(
                      children: <Widget>[
                        Pinned.fromSize(
                            bounds: Rect.fromLTWH(15, 0, 300, 48),
                            size: Size(327, 48),
                            pinLeft: true,
                            pinRight: true,
                            pinTop: true,
                            pinBottom: true,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.teal[400],
                              ),
                            )),
                        Pinned.fromSize(
                          bounds: Rect.fromLTWH(156, 16, 16, 16),
                          size: Size(327, 48),
                          fixedWidth: true,
                          fixedHeight: true,
                          child: PageLink(
                            links: [
                              PageLinkInfo(
                                transition: LinkTransition.SlideLeft,
                                ease: Curves.linear,
                                duration: 0.3,
                                pageBuilder: () => FindMeAChavruta2(),
                              ),
                            ],
                            child: Stack(
                              children: <Widget>[
                                Pinned.fromSize(
                                  bounds: Rect.fromLTWH(0, 0, 16, 16),
                                  size: Size(16, 16),
                                  pinLeft: true,
                                  pinRight: true,
                                  pinTop: true,
                                  pinBottom: true,
                                  child: SvgPicture.string(
                                    _svg_ru0g9a,
                                    allowDrawingOutsideViewBox: true,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
              ),
            ],
          ),

          //floatingActionButton: FloatingActionButton,
        ));
  }
}

const String _svg_pkfj6b =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path transform="matrix(-1.0, 0.0, 0.0, -1.0, 16.0, 16.0)" d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_y73tjv =
    '<svg viewBox="0.0 0.0 375.0 68.0" ><path transform="translate(-4907.0, -1089.0)" d="M 4907.00048828125 1156.999633789063 L 4907.00048828125 1108.999389648438 L 5282.00048828125 1108.999389648438 L 5282.00048828125 1156.999633789063 L 4907.00048828125 1156.999633789063 Z M 4907.00048828125 1108.999389648438 L 4907.00048828125 1088.999877929688 L 5282.00048828125 1088.999877929688 L 5282.00048828125 1108.999389648438 L 4907.00048828125 1108.999389648438 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_ru0g9a =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path  d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_h36wzl =
    '<svg viewBox="16.0 0.0 6.0 6.0" ><path transform="translate(16.0, 0.0)" d="M 3 0 C 4.656854152679443 0 6 1.343145847320557 6 3 C 6 4.656854152679443 4.656854152679443 6 3 6 C 1.343145847320557 6 0 4.656854152679443 0 3 C 0 1.343145847320557 1.343145847320557 0 3 0 Z" fill="#bce0fd" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_spzoa6 =
    '<svg viewBox="301.0 111.0 16.0 16.0" ><path transform="translate(4921.0, 111.0)" d="M -4613.00048828125 15.99948692321777 L -4613.00048828125 8.999783515930176 L -4620 8.999783515930176 L -4620 6.999702930450439 L -4613.00048828125 6.999702930450439 L -4613.00048828125 0 L -4611 0 L -4611 6.999702930450439 L -4604.00048828125 6.999702930450439 L -4604.00048828125 8.999783515930176 L -4611 8.999783515930176 L -4611 15.99948692321777 L -4613.00048828125 15.99948692321777 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
