import 'package:adobe_xd/adobe_xd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'FindMeAChavruta3.dart';
import 'MyData.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/rendering.dart';
import 'package:havruta_project/Globals.dart';

class IosStylePickers extends StatefulWidget {
  @override
  _IosStylePickersState createState() => _IosStylePickersState();
}

class _IosStylePickersState extends State<IosStylePickers> {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  DateTime value;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        height: 43,
        width: 300,
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(
            color: Colors.blue,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: DateTimeField(
            initialValue: value,
            format: format,
            decoration: InputDecoration(
              hintText: "מתי תרצה ללמוד",
              hintStyle: TextStyle(
                fontSize: 15.0,
                //color: Colors.green,
              ),
              fillColor: Colors.white,
              border: InputBorder.none,
              // enabledBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: Colors.green),
              // ),
              // focusedBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: Colors.purple, width: 5),
              // ),
            ),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                    builder: (context, _) {
                      return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                              // Using 24-Hour format
                              alwaysUse24HourFormat: true),
                          child: _);
                    });
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            }),
      ),
    ]);
  }
}

class FindMeAChavruta1 extends StatefulWidget {
  @override
  _FindMeAChavruta1CreateState createState() => _FindMeAChavruta1CreateState();
}

class _FindMeAChavruta1CreateState extends State<FindMeAChavruta1> {
  var db = Globals.db;
  final format = DateFormat("yyyy-MM-dd");
  DateTime val;
  String value = '';
  String selectedTopic;
  String selectedBook;
  String selectedHour;
  List<DropdownMenuItem<String>> topicsDrop = [];
  List<DropdownMenuItem<String>> hoursDrop = [];
  List<DropdownMenuItem<String>> booksDrop = [];
  List<DropdownMenuItem<String>> howOften = [];
  List<DropdownMenuItem<String>> genderDrop = [];

  List<String> topics = MyData().topics;
  List<String> humashBooks = MyData().humashBooks;
  List<String> nachBooks = MyData().nachBooks;
  List<String> talmudBavliBooks = MyData().talmudBavliBooks;
  List<String> talmudYerushalmiBooks = MyData().talmudYerushalmiBooks;
  List<String> halachaBooks = MyData().halachaBooks;
  List<String> howOftenList = MyData().howOften;
  List<String> genderList = MyData().gender;

  final durationInput = Container(
    padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 8.0),
    child: new Row(
      children: <Widget>[
        Container(
          child: new Flexible(
              child: new TextField(
                  decoration: InputDecoration(
                      hintText: "Duration",
                      contentPadding:
                          EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  maxLines: 1)),
        ),
      ],
    ),
  );

  void loadTopicssData() {
    topicsDrop = [];
    topicsDrop = topics
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  // void loadHours() {
  //   hoursDrop = [];
  //   //hoursDrop = hours
  //       .map((val) => DropdownMenuItem<String>(
  //             child: Text(val),
  //             value: val,
  //           ))
  //       .toList();
  // }

  //void loadTorahBooksData(String torah) async{
  //   print("Try to connect...");
  //   db = await mongo.Db.create(CONNECT_TO_DB);
  //   await db.open();
  //   var collection = db.collection('Topics');
  //   var humashBooks = await collection.findOne(where.eq('תורה', torah));
  //   booksDrop = [];
  //   booksDrop = humashBooks
  //       .map((val) => DropdownMenuItem<String>(
  //           child: Text(val),
  //           value: val,
  //   )).toList();
  //}
  void loadTorahBooksData() {
    booksDrop = [];
    booksDrop = humashBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  /// Function to load the data for the dropdown list
  void loadNachBooksData() {
    booksDrop = [];
    booksDrop = nachBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void loadBavliBooksData() {
    booksDrop = [];
    booksDrop = talmudBavliBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void loadYerushalmiBooksData() {
    booksDrop = [];
    booksDrop = talmudYerushalmiBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void loadHalachaBooksData() {
    booksDrop = [];
    booksDrop = halachaBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void loadHowOftenData() {
    howOften = [];
    howOften = howOftenList
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void loadGenderData() {
    genderDrop = [];
    genderDrop = genderList
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    loadTopicssData();
    //loadHours();
    loadHowOftenData();
    loadGenderData();
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
            Padding(
              padding: EdgeInsets.fromLTRB(30, 30, 20, 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.topic,
                    color: Colors.teal[400],
                  ),
                ),
                //########### ----TOPIC DROPDOWN LIST----########
                DropdownButtonHideUnderline(
                    child: Stack(
                  children: [
                    Container(
                      height: 42,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.teal[400],
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.teal[400],
                          isExpanded: false,
                          elevation: 1,
                          value: selectedTopic,
                          style: const TextStyle(color: Colors.teal),
                          hint: Text("בחרו תחום"),
                          items: topicsDrop,
                          onChanged: (value) {
                            if (value == "תורה") {
                              //loadTorahBooksData("תורה");
                              loadTorahBooksData();
                            } else if (value == "נ״ך") {
                              loadNachBooksData();
                            } else if (value == "תלמוד בבלי") {
                              loadBavliBooksData();
                            }
                            selectedTopic = value;
                            setState(() {
                              selectedBook = null;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                )),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(55, 20, 10, 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.book, color: Colors.teal[400]),
                ),
                //########### ----BOOKS DROPDOWN LIST----########
                DropdownButtonHideUnderline(
                    child: Stack(
                  children: [
                    Container(
                      height: 42,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.teal[400],
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                          //icon: Icon(Icons.book),
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.teal[400],
                          elevation: 1,
                          value: selectedTopic,
                          style: const TextStyle(color: Colors.teal),
                          hint: Text("בחרו ספר"),
                          items: topicsDrop,
                          onChanged: (value) {
                            selectedHour = value;
                            setState(() {
                              selectedHour = null;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                )),
              ],
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(55, 20, 10, 20),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.face, color: Colors.teal[400]),
                  ),
                  //########### ----GENDER DROPDOWN LIST----########
                  DropdownButtonHideUnderline(
                      child: Stack(
                    children: [
                      Container(
                        height: 42,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.teal[400],
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton(
                            dropdownColor: Colors.white,
                            iconEnabledColor: Colors.teal[400],
                            elevation: 1,
                            value: selectedTopic,
                            style: const TextStyle(color: Colors.teal),
                            hint: Text("מין"),
                            items: genderDrop,
                            onChanged: (value) {
                              // if (value == "תורה") {
                              //   //loadTorahBooksData("תורה");
                              //   loadTorahBooksData();
                              // } else if (value == "נ״ך") {
                              //   loadNachBooksData();
                              // } else if (value == "תלמוד בבלי") {
                              //   loadBavliBooksData();
                              // }
                              // selectedTopic = value;
                              setState(() {
                                //selectedBook = null;
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  )),
                ]),
            //########### ----NUMBER OF ATTENDEES----########
            Padding(
              padding: EdgeInsets.fromLTRB(55, 20, 10, 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.people,
                    color: Colors.teal[400],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      height: 42,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.teal[400],
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: new TextField(
                          decoration: InputDecoration(
                            hintText: "מספר משתתפים",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLines: 1),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(55, 20, 10, 20),
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
                        bounds: Rect.fromLTWH(16.0, 0.0, 6.0, 6.0),
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
                        bounds: Rect.fromLTWH(32.0, 0.0, 6.0, 6.0),
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
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
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
                          bounds: Rect.fromLTWH(15, 0.0, 327, 48),
                          size: Size(327, 48),
                          pinLeft: true,
                          pinRight: true,
                          pinTop: true,
                          pinBottom: true,
                          // child: Scaffold(
                          //   body: GestureDetector(
                          //     onTap: () {
                          //       // Update user details
                          //       // go to next page
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => FindMeAChavruta2()),
                          //       );
                          //     },
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
                              pageBuilder: () => FindMeAChavruta3(),
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
          ],
        ),
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
