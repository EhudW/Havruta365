import 'package:adobe_xd/adobe_xd.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta3.dart';
import 'package:havruta_project/Widgets/list_item_widget.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Widgets/list_item_widget.dart';

class ListItem {
  String title;

  ListItem(String t) {
    this.title = t;
  }
}

class ListViews extends StatefulWidget {
  //ListViews({Key key, this.title}) : super(key: key);
  List<String> dates;
  List<DateTime> datesForDB;
  int numOfChavs = 1;

  ListViews(List<String> dt, List<DateTime> dDB, int n) {
    this.dates = dt;
    this.numOfChavs = n;
    this.datesForDB = dDB;
  }

  @override
  _ListViewsState createState() => _ListViewsState();
}

class _ListViewsState extends State<ListViews> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<String> eraseDate(List<String> dates, index) {
    print(dates);
    print(index);
    dates.remove(dates[index]);
    print(dates);
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: AnimatedList(
      //   //initialItemCount: widget.numOfChavs,
      //   itemBuilder: (context, index, animation) =>
      //       _buildListView(widget.dates, widget.datesForDB, widget.numOfChavs),
      // ),

      body: _buildListView(widget.dates, widget.datesForDB, widget.numOfChavs),
    );
  }

  Widget _buildListView(
      List<String> dates, List<DateTime> datesForMongo, int numOfChavrutot) {
    return Padding(
        padding: const EdgeInsets.all(2.0),
        // child: Container(
        //     height: 500,
        //     padding: const EdgeInsets.all(12.0),
        //     decoration: BoxDecoration(
        //       border: Border.all(
        //         color: Colors.teal[400],
        //         width: 4,
        //       ),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     // child: AnimatedList(
        //     //   initialItemCount: numOfChavrutot,
        //     //   itemBuilder: (context, index, animation) => ListView.builder(
        //     //       itemBuilder: (context, index)
        //     //   )
        child: ListView.builder(
            // child: AnimatedList(
            //   key: _listKey,
            itemCount: numOfChavrutot,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            //itemBuilder: (context, index, animation) => ListItemWidget(
            //     item: dates[index],
            //     animation: animation,
            //     //onClicked: () => removeItem(index),
            //   ),
            itemBuilder: (context, index) {
              var ind = index + 1;
              var chavrutaInfoMessage = ('${dates[index]}');
              return Card(
                  shape:
                      Border(right: BorderSide(color: Colors.green, width: 5)),
                  child: ListTile(
                    leading: const Icon(
                      Icons.perm_contact_cal,
                      color: Colors.green,
                    ),
                    trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          eraseDate(dates, index);
                          //index -= 1;
                        }),
                    // trailing: IconButton(
                    //   const Icon(
                    //     Icons.delete,
                    //     color: Colors.red,
                    //   ),
                    //   onPressed: null,
                    // ),
                    title: Text(
                      chavrutaInfoMessage,
                      style: TextStyle(fontSize: 15),
                    ),
                  ));
            }));
  }
}

class FindMeAChavruta2 extends StatefulWidget {
  final Event event;
  FindMeAChavruta2({Key key, @required this.event}) : super(key: key);

  @override
  _FindMeAChavruta2CreateState createState() => _FindMeAChavruta2CreateState();
}

class _FindMeAChavruta2CreateState extends State<FindMeAChavruta2> {
  var db = Globals.db;
  List<String> dateTimes = [];
  List<DateTime> dateTimeListForMongo = [];
  String text = "בחרו זמנים ללמוד";
  DateTime start, end;
  String startDate, endDate, fullDate;
  int howManyChosen = 0;

  Future pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;
    final startTime = await pickTime(context);
    final endTime = await pickTime(context);
    print(endTime);
    if (startTime == null || endTime == null) return;
    int startInMinutes = startTime.hour * 60 + startTime.minute;
    int endInMinutes = endTime.hour * 60 + endTime.minute;
    print(startTime.hour);
    print(endTime.hour);
    if (startInMinutes >= endInMinutes || startTime.hour > endTime.hour) {
      //Put a block up here showing error
      showErrorSnackBar(context);
      print("Error in choosing the times");
      return;
    }
    setState(() {
      start = DateTime(
          date.year, date.month, date.day, startTime.hour, startTime.minute);
      end = DateTime(
          date.year, date.month, date.day, endTime.hour, endTime.minute);
      dateTimeListForMongo.add(start);
      dateTimeListForMongo.add(end);
      this.startDate = DateFormat('MM-dd-yyyy: kk:mm').format(start);
      this.endDate = DateFormat('kk:mm').format(end);
      this.fullDate = startDate + " - " + this.endDate;
      this.howManyChosen++;
      print(this.fullDate);
      dateTimes.add(this.fullDate);
      print(dateTimeListForMongo);
      widget.event.dates = dateTimeListForMongo;
      print(widget.event.targetGender);
    });
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
    return Scaffold(
        // appBar: CustomAppBar(
        //   title: "חברותא חדשה",
        //   gradientBegin: Colors.blue,
        //   gradientEnd: Colors.greenAccent,
        // ),
        appBar: appBar(),
        body: Builder(
          builder: (context) => Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      // // ),
                      Material(
                        shadowColor: Colors.teal,
                        // child: Container(
                        //   child: FloatingActionButton(
                        //     backgroundColor: Colors.green,
                        //     onPressed: () => pickDateTime(context),
                        //     child: Text(
                        //       "+",
                        //       style: TextStyle(fontSize: 40),
                        //     ),
                        //   ),

                        // child: ElevatedButton(
                        //     onPressed: () => pickDateTime(context),
                        //     style: ElevatedButton.styleFrom(
                        //         //minimumSize: Size.fromHeight(20),
                        //         primary: Colors.teal[400],
                        //         onSurface: Colors.white70),
                        //     child: Container(
                        //       height: 50,
                        //       width: 200,
                        //       padding: const EdgeInsets.fromLTRB(
                        //           10.0, 10.0, 10.0, 10.0),
                        //       decoration: BoxDecoration(
                        //         color: Colors.teal[400],
                        //         borderRadius: BorderRadius.only(
                        //             topLeft: Radius.circular(10),
                        //             topRight: Radius.circular(10),
                        //             bottomLeft: Radius.circular(10),
                        //             bottomRight: Radius.circular(10)),
                        //       ),
                        //       child: FittedBox(
                        //         child: Text(
                        //           text,
                        //           style: TextStyle(
                        //               fontSize: 20, color: Colors.white),
                        //         ),
                        //       ),
                        //       // child: DatePicker(dateTimes),
                        //     ))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                      ),
                      Expanded(
                          child: ListViews(this.dateTimes,
                              this.dateTimeListForMongo, this.howManyChosen)),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(80, 25, 80, 0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Padding(padding: EdgeInsets.fromLTRB(150, 25, 80, 0)),
                    //Padding(padding: padding)
                    FloatingActionButton(
                      backgroundColor: Colors.green,
                      onPressed: () => pickDateTime(context),
                      child: Text(
                        "+",
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),

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
                                  pageBuilder: () =>
                                      FindMeAChavruta3(event: widget.event),
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
          ),
        ));
  }

  appBar() {
    return AppBar(
      toolbarHeight: 40,
      elevation: 20,
      shadowColor: Colors.teal[400],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(40),
      )),
      backgroundColor: Colors.white,
      title: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Text(
              'הוסיפו זמני לימוד',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.teal[400]),
            ),
            Icon(FontAwesomeIcons.clock, size: 25, color: Colors.teal[400])
          ])),
    );
  }

  void showErrorSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'זמן סיום צריך להיות אחרי זמן התחלה',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.fixed,
    );
    Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: () {
        pickDateTime(context);
      },
      child: Text(
        "+",
        style: TextStyle(fontSize: 40),
      ),
    );
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
