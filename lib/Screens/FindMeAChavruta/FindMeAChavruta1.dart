import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/First_Dot_Row.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/MyData.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Wavy_Header.dart';
import 'package:havruta_project/DataBase_auth/Topic.dart';
import 'MyData.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Next_Button.dart';

class FindMeAChavruta1 extends StatefulWidget {
  @override
  _FindMeAChavruta1CreateState createState() => _FindMeAChavruta1CreateState();
}

class _FindMeAChavruta1CreateState extends State<FindMeAChavruta1> {
  var db = Globals.db;
  final format = DateFormat("yyyy-MM-dd");
  DateTime val;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String value = '',
      selectedTopic,
      gender,
      selectedBook,
      selectedHour,
      selectedChoice,
      newVal;
  List<DropdownMenuItem<String>> choiceDrop = [],
      topicsDrop = [],
      booksDrop = [],
      genderDrop = [];
  double spaceBetween, height, width, iconSize;
  int counter = 0;

  List<String> choice = MyData().choice;
  List<String> topics = MyData().topics;
  List<String> humashBooks = MyData().humashBooks;
  List<String> nachBooks = MyData().nachBooks;
  List<String> talmudBavliBooks = MyData().talmudBavliBooks;
  List<String> talmudYerushalmiBooks = MyData().talmudYerushalmiBooks;
  List<String> halachaBooks = MyData().halachaBooks;
  List<String> howOftenList = MyData().howOften;
  List<String> genderList = MyData().gender;

  //User user = User();
  String user = "yonatan";
  Event event = Event();

  void loadTopicssData() {
    topicsDrop = [];
    topicsDrop = topics
        .map((val) => DropdownMenuItem<String>(
              child: Container(
                width: 231,
                alignment: Alignment.center,
                child: Text(
                  val,
                  textAlign: TextAlign.center,
                ),
              ),
              value: val,
            ))
        .toList();
  }

  void loadChoices() {
    choiceDrop = [];
    choiceDrop = choice
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void intializeEvent(Event event) {
    event.maxParticipants = 0;
    event.targetGender = '';
    event.book = '';
    event.topic = '';
    event.type = '';
    event.description = '';
    event.lecturer = '';
    event.dates = [];
    event.creatorUser = '';
    event.eventImage = '';
    event.participants = [];
    event.link = '';
  }

  void loadTorahBooksData() {
    booksDrop = [];
    booksDrop = humashBooks
        .map((val) => DropdownMenuItem<String>(
              child: Container(
                child: Text(val),
                width: 230,
                alignment: Alignment.center,
              ),
              value: val,
            ))
        .toList();
  }

  /// Function to load the data for the dropdown list
  void loadNachBooksData() {
    booksDrop = [];
    booksDrop = nachBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(
                val,
                textAlign: TextAlign.center,
              ),
              value: val,
            ))
        .toList();
  }

  void loadBavliBooksData() {
    booksDrop = [];
    booksDrop = talmudBavliBooks
        .map((val) => DropdownMenuItem<String>(
              child: Text(
                val,
                textAlign: TextAlign.center,
              ),
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
              child: Text(
                val,
                textAlign: TextAlign.center,
              ),
              value: val,
            ))
        .toList();
  }

  void loadGenderData() {
    genderDrop = [];
    genderDrop = genderList
        .map((val) => DropdownMenuItem<String>(
              child: Text(
                val,
                textAlign: TextAlign.center,
              ),
              value: val,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Topic>> l = Globals.db.getTopics();
    l.then((value) => print(value));
    if (this.counter == 0) {
      intializeEvent(this.event);
      this.counter += 1;
    }
    spaceBetween = 20;
    height = 67;
    width = 280;
    iconSize = 40;
    loadTopicssData();
    loadGenderData();
    loadChoices();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: Builder(
        builder: (context) => Center(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: WavyHeader()),
                ],
              ),
              Column(
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(top: 65.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //########### ----CHOICE DROPDOWN LIST----########
                      DropdownButtonHideUnderline(
                          child: Stack(
                        children: [
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8.0),
                              ],
                              color: Colors.white70,
                              border:
                                  Border.all(color: Colors.white70, width: 2.5),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Material(
                              elevation: 50,
                              borderRadius: BorderRadius.circular(50.0),
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: Colors.teal[400],
                                  isExpanded: false,
                                  elevation: 1,
                                  value: selectedChoice,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                  ),
                                  hint: Container(
                                      width: 230,
                                      child: TextField(
                                          textAlign: TextAlign.center,
                                          autocorrect: true,
                                          style: const TextStyle(
                                              color: Colors.teal),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              hintText:
                                                  "בחרו האם זה שיעור או חברותא"))),
                                  items: choiceDrop,
                                  onChanged: (value) {
                                    selectedChoice = value;
                                    event.type = selectedChoice;
                                    print(event.type);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          FontAwesomeIcons.questionCircle,
                          color: Colors.tealAccent[400],
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(50, 20, 10, 20),
                        ),
                        Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8.0),
                              ],
                              color: Colors.white70,
                              border:
                                  Border.all(color: Colors.white70, width: 2.5),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Material(
                              elevation: 50,
                              borderRadius: BorderRadius.circular(50.0),
                              child: Container(
                                width: 230,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  autocorrect: true,
                                  style: const TextStyle(
                                      color: Colors.teal, fontSize: 16.5),
                                  decoration: InputDecoration(
                                    hintText: "מספר משתתפים",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(
                                        10.0, 20.0, 10.0, 10.0),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLines: 1,
                                  onChanged: (newVal) {
                                    var numOfParticapints = int.parse(newVal);
                                    event.maxParticipants = numOfParticapints;
                                    print(event.maxParticipants);
                                    if (event.maxParticipants == null) {
                                      event.maxParticipants = 1;
                                    }
                                  },
                                ),
                              ),
                            ))
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.group,
                          color: Colors.tealAccent[400],
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //########### ----TOPIC DROPDOWN LIST----########
                      DropdownButtonHideUnderline(
                          child: Stack(
                        children: [
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8.0),
                              ],
                              color: Colors.white70,
                              border:
                                  Border.all(color: Colors.white70, width: 2.5),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Material(
                              elevation: 50,
                              borderRadius: BorderRadius.circular(50.0),
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: Colors.teal[400],
                                  isExpanded: false,
                                  elevation: 1,
                                  value: selectedTopic,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                  ),
                                  hint: Container(
                                      width: 230,
                                      child: TextField(
                                          textAlign: TextAlign.center,
                                          autocorrect: true,
                                          style: const TextStyle(
                                              color: Colors.teal),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              hintText: "בחרו תחום"))),
                                  items: topicsDrop,
                                  onChanged: (value) {
                                    // need to send to function the value which will load from the db
                                    if (value == "תורה") {
                                      //loadTorahBooksData("תורה");
                                      loadTorahBooksData();
                                    } else if (value == "נ״ך") {
                                      loadNachBooksData();
                                    } else if (value == "תלמוד בבלי") {
                                      loadBavliBooksData();
                                    }
                                    selectedTopic = value;
                                    event.topic = selectedTopic;
                                    print(event.topic);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      )),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.topic,
                          color: Colors.tealAccent[400],
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //########### ----BOOKS DROPDOWN LIST----########
                      DropdownButtonHideUnderline(
                        child: Stack(children: [
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8.0),
                              ],
                              color: Colors.white70,
                              border:
                                  Border.all(color: Colors.white70, width: 2.5),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Material(
                              elevation: 50,
                              borderRadius: BorderRadius.circular(50.0),
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                  //icon: Icon(Icons.book),
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: Colors.teal[400],
                                  isDense: true,
                                  elevation: 0,
                                  value: selectedBook,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                  ),
                                  hint: Container(
                                      width: 230,
                                      child: TextField(
                                          textAlign: TextAlign.center,
                                          autocorrect: true,
                                          style: const TextStyle(
                                              color: Colors.teal),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              hintText: "בחרו ספר"))),
                                  items: booksDrop,
                                  onChanged: (value) {
                                    selectedBook = value;
                                    event.book = selectedBook;
                                    print(event.book);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          FontAwesomeIcons.book,
                          color: Colors.tealAccent[400],
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //########### ----GENDER DROPDOWN LIST----########
                        DropdownButtonHideUnderline(
                            child: Stack(
                          children: [
                            Container(
                              height: height,
                              width: width,
                              decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8.0),
                                ],
                                color: Colors.white70,
                                border: Border.all(
                                    color: Colors.white70, width: 2.5),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Material(
                                elevation: 50,
                                borderRadius: BorderRadius.circular(50.0),
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: Colors.teal[400],
                                    elevation: 1,
                                    value: gender,
                                    style: const TextStyle(
                                      color: Colors.teal,
                                    ),
                                    hint: Container(
                                        width: 230,
                                        child: TextField(
                                            textAlign: TextAlign.center,
                                            autocorrect: true,
                                            style: const TextStyle(
                                                color: Colors.teal),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintText: "בחרו מין יעד"))),
                                    items: genderDrop,
                                    onChanged: (value) {
                                      gender = value;
                                      this.event.targetGender = gender;
                                      print(event.targetGender);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Icon(
                            Icons.face,
                            color: Colors.tealAccent[400],
                            size: iconSize,
                          ),
                        ),
                      ]),
                  //########### ----NUMBER OF ATTENDEES----########

                  SizedBox(height: spaceBetween),
                  FirstDotRow(),

                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NextButton(
                          context: context,
                          event: this.event,
                          whichPage: 2,
                          isEmpty: false)
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  appBar() {
    return new AppBar(
        leadingWidth: 20,
        toolbarHeight: 40,
        elevation: 10,
        shadowColor: Colors.teal[400],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        )),
        backgroundColor: Colors.white,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            'קבע אירוע חדש  ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.calendar, size: 25, color: Colors.teal[400])
        ]));
  }
}
