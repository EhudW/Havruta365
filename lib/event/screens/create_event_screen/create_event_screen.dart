import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/topic.dart';
import 'package:havruta_project/event/create_event/my_data.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/event/create_event/third_dot_row.dart';
import 'package:havruta_project/event/create_event/wavy_header.dart';
import 'package:havruta_project/data_base/events_selector_builder.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "dart:async";
import '../../buttons/next_button.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'dart:ui' as ui;

class CreateEventScreen extends StatefulWidget {
  final Event? initEvent;
  final String? barTitle;
  CreateEventScreen({Event? initEvent, this.barTitle})
      : this.initEvent = initEvent?.deepClone();
  @override
  _CreateEventScreenCreateState createState() =>
      _CreateEventScreenCreateState();
}

List<String> topics = [];
List<String> humashBooks = [];
List<String> neviimBooks = [];
List<String> ketuvimBooks = [];
List<String> talmudBavliBooks = [];
List<String> talmudYerushalmiBooks = [];
List<String> halachaBooks = [];
List<String> chasidutBooks = [];
List<String> machsehvetBooks = [];
List<String> otherBooks = [];

List<String> booksDrop = [];

class _CreateEventScreenCreateState extends State<CreateEventScreen> {
  var db = Globals.db;
  final format = DateFormat("yyyy-MM-dd");
  DateTime? val;
  String? value,
      selectedTopic,
      gender,
      targetStatus,
      selectedBook,
      selectedHour,
      selectedChoice,
      newVal;
  List<DropdownMenuItem<String>> choiceDrop = [],
      topicsDrop = [],
      booksDrop = [],
      genderDrop = [];
  double? spaceBetween, height, width, iconSize;
  int counter = 0;
  List<String> choice = MyData().choice;
  List<String> genderList = MyData().gender;
  String user = "yonatan";
  Event event = Event(); // see initState()
  late TextEditingController maxController;
  late TextEditingController maxAgeController;
  late TextEditingController minAgeController;
  late TextEditingController bookController;
  @override
  void initState() {
    super.initState();
    maxController = TextEditingController(
        text: widget.initEvent?.maxParticipants?.toString() ?? "5");
    maxAgeController = TextEditingController(
        text: widget.initEvent?.maxAge.toString() ?? "120");
    minAgeController =
        TextEditingController(text: widget.initEvent?.minAge.toString() ?? "0");
    bookController = TextEditingController(text: widget.initEvent?.book);
    if (widget.initEvent != null) {
      event = widget.initEvent!;
      // for debug compabilty
      if (!genderList.contains(event.targetGender)) {
        event.targetGender = MyData().gender.last;
      }
      // here set & also in controller: TextEditingController
      this.selectedBook = event.book;
      // here set, which will also affect default value showed to the user
      this.gender = event.targetGender;
      this.targetStatus = event.onlyForStatus;
      this.selectedTopic = event.topic;
      this.selectedChoice = {"H": "חברותא", "L": "שיעור"}[event.type];
      // max participants only in controller: TextEditingController,
      //but no field to update here... (onChange auto update event.maxParticipants)
      counter++; //to prevent call in build() to intializeEvent()
    }
  }

  Future<List<Topic>> getTopics() async {
    final topicsList = await Globals.db!.getTopics();
    topics = [];
    humashBooks = [];
    neviimBooks = [];
    ketuvimBooks = [];
    talmudBavliBooks = [];
    talmudYerushalmiBooks = [];
    halachaBooks = [];
    chasidutBooks = [];
    machsehvetBooks = [];
    for (var i in topicsList) {
      final title = i.title;
      if (title == "תחומים") {
        for (var j in i.tags!) {
          topics.add(j);
        }
      } else if (title == "תורה") {
        for (var j in i.tags!) {
          humashBooks.add(j);
        }
      } else if (title == "נביאים") {
        for (var j in i.tags!) {
          neviimBooks.add(j);
        }
      } else if (title == "כתובים") {
        for (var j in i.tags!) {
          ketuvimBooks.add(j);
        }
      } else if (title == "תלמוד בבלי") {
        for (var j in i.tags!) {
          talmudBavliBooks.add(j);
        }
      } else if (title == "תלמוד ירושלמי") {
        for (var j in i.tags!) {
          talmudYerushalmiBooks.add(j);
        }
      } else if (title == "הלכה") {
        for (var j in i.tags!) {
          halachaBooks.add(j);
        }
      } else if (title == "חסידות") {
        for (var j in i.tags!) {
          chasidutBooks.add(j);
        }
      } else if (title == "מחשבת ישראל") {
        for (var j in i.tags!) {
          machsehvetBooks.add(j);
        }
      }
    }
    loadTopicssData();
    return topicsList;
  }

  Future<void> loadTopicssData() async {
    topicsDrop = topics
        .map((val) =>
            DropdownMenuItem<String>(child: dropDownContainer(val), value: val))
        .toList();
  }

  void loadTorahBooksData() {
    booksDrop = humashBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadOtherBooksData() {
    booksDrop = [];
  }

  dropDownContainer(val) {
    return Container(
      child: Text(
        val,
        textDirection: ui.TextDirection.rtl,
      ),
      width: Globals.scaler.getWidth(26.6),
      alignment: Alignment.center,
    );
  }

  void loadNachBooksData() {
    booksDrop = neviimBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadBavliBooksData() {
    booksDrop = talmudBavliBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadChoices() {
    choiceDrop = choice
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void ketuvimBooksData() {
    booksDrop = ketuvimBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadYerushalmiBooksData() {
    booksDrop = talmudYerushalmiBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadHalachaBooksData() {
    booksDrop = halachaBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadHasidutBooksData() {
    booksDrop = chasidutBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void loadMachshevetBooksData() {
    booksDrop = machsehvetBooks
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  void intializeEvent(Event event) {
    event.maxParticipants = 5;
    event.minAge = 0;
    event.maxAge = 120;
    event.targetGender = '';
    event.book = '';
    event.topic = '';
    event.type = '';
    event.description = '';
    event.lecturer = '';
    event.dates = [];
    event.creatorName = Globals.currentUser!.name;
    event.creatorUser = Globals.currentUser!.email;
    event.eventImage = MyConsts.DEFAULT_EVENT_IMG;
    event.participants = [];
    event.waitingQueue = [];
    event.link = '';
  }

  void loadGenderData() {
    genderDrop = [];
    genderDrop = genderList
        .map((val) => DropdownMenuItem<String>(
              child: dropDownContainer(val),
              value: val,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (this.counter == 0) {
      intializeEvent(this.event);
      this.counter += 1;
    }
    spaceBetween = Globals.scaler.getHeight(1.4);
    height = Globals.scaler.getHeight(2.8);
    width = Globals.scaler.getWidth(25);
    iconSize = Globals.scaler.getTextSize(10);
    loadGenderData();
    loadChoices();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBar(),
      body: Container(
        child: FutureBuilder(
            future: getTopics(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                    child: Center(
                  child: Image.asset(circularProgressIndicator, scale: 10),
                ));
              } else {
                return SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: Globals.scaler.getHeight(0)),
                              child: WavyHeader()),
                        ],
                      ),
                      Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: Globals.scaler.getHeight(2.2)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ///########### ----CHOICE DROPDOWN LIST----########
                                dropDownList("בחרו האם זה שיעור או חברותא",
                                    choiceDrop, selectedChoice),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  FontAwesomeIcons.comments,
                                  color: Colors.red,
                                  //color: Colors.tealAccent[400],
                                  size: iconSize,
                                ),
                              ],
                            ),
                            SizedBox(height: spaceBetween),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    height: height,
                                    width: width,
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(1),
                                            offset: const Offset(0, 2),
                                            blurRadius:
                                                Globals.scaler.getHeight(.2)),
                                      ],
                                      color: Colors.white70,
                                      border: Border.all(
                                          color: Colors.white70,
                                          width: Globals.scaler.getWidth(0.2)),
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Material(
                                      elevation: Globals.scaler.getHeight(2),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Container(
                                        width: Globals.scaler.getWidth(29),
                                        child: Stack(
                                          children: [
                                            Align(
                                              child: Text(
                                                "מספר משתתפים   ",
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                              alignment: Alignment.centerRight,
                                            ),
                                            Container(
                                              width:
                                                  Globals.scaler.getWidth(15),
                                              child: TextField(
                                                controller: maxController,
                                                textAlign: TextAlign.center,
                                                autocorrect: true,
                                                style: TextStyle(
                                                    color: Colors.teal,
                                                    fontSize: Globals.scaler
                                                        .getTextSize(7.2)),
                                                decoration: InputDecoration(
                                                  //suffixText: "מספר משתתפים",
                                                  //hintText: "מספר משתתפים",
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                maxLines: 1,
                                                onChanged: (newVal) {
                                                  int? numOfParticapints =
                                                      int.tryParse(newVal);
                                                  if (numOfParticapints ==
                                                      null) {
                                                    event.maxParticipants =
                                                        event.maxParticipants ??
                                                            1;
                                                  } else {
                                                    event.maxParticipants =
                                                        numOfParticapints;
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  Icons.group,
                                  color: Colors.red,
                                  //color: Colors.tealAccent[400],
                                  size: iconSize,
                                ),
                              ],
                            ),
                            SizedBox(height: spaceBetween),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                dropDownList(
                                    "בחרו תחום", topicsDrop, selectedTopic),

                                ///########### ----TOPIC DROPDOWN LIST----########
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  Icons.topic,
                                  color: Colors.red,
                                  //color: Colors.tealAccent[400],
                                  size: iconSize,
                                ),
                              ],
                            ),
                            SizedBox(height: spaceBetween),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    height: height,
                                    width: width,
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(1),
                                            offset: const Offset(0, 2),
                                            blurRadius:
                                                Globals.scaler.getHeight(.2)),
                                      ],
                                      color: Colors.white70,
                                      border: Border.all(
                                          color: Colors.white70,
                                          width: Globals.scaler.getWidth(0.2)),
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Material(
                                        elevation: Globals.scaler.getHeight(2),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Container(
                                            width: Globals.scaler.getWidth(29),
                                            child: TextField(
                                              controller: bookController,
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              textAlign: TextAlign.center,
                                              autocorrect: true,
                                              style: TextStyle(
                                                  color: Colors.teal,
                                                  fontSize: Globals.scaler
                                                      .getTextSize(7.2)),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "בחרו ספר",
                                                  focusColor: Colors.teal,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                  )),
                                              maxLines: 1,
                                              onChanged: (book) {
                                                event.book = book;
                                              },
                                            )))),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  FontAwesomeIcons.book,
                                  color: Colors.red,
                                  //color: Colors.tealAccent[400],
                                  size: iconSize,
                                ),
                              ],
                            ),
                            SizedBox(height: spaceBetween),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ///########### ----GENDER DROPDOWN LIST----########
                                  dropDownList(
                                      "בחרו מין יעד", genderDrop, gender),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    FontAwesomeIcons.restroom,
                                    color: Colors.red,
                                    //color: Colors.tealAccent[400],
                                    size: iconSize,
                                  ),
                                ]),
                            SizedBox(height: spaceBetween),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ///########### ----GENDER DROPDOWN LIST----########
                                  dropDownList(
                                      "בחרו קבוצת יעד",
                                      Event.onlyForStatus_Options
                                          .map((e) => DropdownMenuItem<String>(
                                                child: dropDownContainer(
                                                    Event.getNewLbl(e[0])),
                                                value: e[0],
                                              ))
                                          .toList(),
                                      targetStatus),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    FontAwesomeIcons.usersViewfinder,
                                    color: Colors.red,
                                    //color: Colors.tealAccent[400],
                                    size: iconSize,
                                  ),
                                ]),
                            SizedBox(height: spaceBetween),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    height: height,
                                    width: width,
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(1),
                                            offset: const Offset(0, 2),
                                            blurRadius:
                                                Globals.scaler.getHeight(.2)),
                                      ],
                                      color: Colors.white70,
                                      border: Border.all(
                                          color: Colors.white70,
                                          width: Globals.scaler.getWidth(0.2)),
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Material(
                                      elevation: Globals.scaler.getHeight(2),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Container(
                                        width: Globals.scaler.getWidth(29),
                                        child: Stack(children: [
                                          Align(
                                            child: Text(
                                              "גיל מינימלי   ",
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                            ),
                                            alignment: Alignment.centerRight,
                                          ),
                                          Container(
                                              width:
                                                  Globals.scaler.getWidth(15),
                                              child: TextField(
                                                controller: minAgeController,
                                                textAlign: TextAlign.center,
                                                autocorrect: true,
                                                style: TextStyle(
                                                    color: Colors.teal,
                                                    fontSize: Globals.scaler
                                                        .getTextSize(7.2)),
                                                decoration: InputDecoration(
                                                  // suffixText: "גיל מינימלי",
                                                  // hintText: "גיל מינימלי",
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                maxLines: 1,
                                                onChanged: (newVal) {
                                                  int? n = int.tryParse(newVal);
                                                  if (n != null) {
                                                    event.minAge = n;
                                                  }
                                                },
                                              ))
                                        ]),
                                      ),
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  FontAwesomeIcons.baby,
                                  textDirection: ui.TextDirection.ltr,
                                  color: Colors.red,
                                  //color: Colors.tealAccent[400],
                                  size: iconSize,
                                ),
                              ],
                            ),
                            SizedBox(height: spaceBetween),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    height: height,
                                    width: width,
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(1),
                                            offset: const Offset(0, 2),
                                            blurRadius:
                                                Globals.scaler.getHeight(.2)),
                                      ],
                                      color: Colors.white70,
                                      border: Border.all(
                                          color: Colors.white70,
                                          width: Globals.scaler.getWidth(0.2)),
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Material(
                                      elevation: Globals.scaler.getHeight(2),
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Container(
                                          width: Globals.scaler.getWidth(29),
                                          child: Stack(children: [
                                            Align(
                                              child: Text(
                                                "גיל מקסימלי   ",
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                              alignment: Alignment.centerRight,
                                            ),
                                            Container(
                                              width:
                                                  Globals.scaler.getWidth(15),
                                              child: TextField(
                                                controller: maxAgeController,
                                                textAlign: TextAlign.center,
                                                autocorrect: true,
                                                style: TextStyle(
                                                    color: Colors.teal,
                                                    fontSize: Globals.scaler
                                                        .getTextSize(7.2)),
                                                decoration: InputDecoration(
                                                  //  suffixText: "גיל מקסימלי",
                                                  //  hintText: "גיל מקסימלי",
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                    Globals.scaler
                                                        .getWidth(1.3),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                maxLines: 1,
                                                onChanged: (newVal) {
                                                  int? n = int.tryParse(newVal);
                                                  if (n != null) {
                                                    event.maxAge = n;
                                                  }
                                                },
                                              ),
                                            )
                                          ])),
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  FontAwesomeIcons.personCane,
                                  color: Colors.red,
                                  //color: Colors.tealAccent[400],
                                  size: iconSize,
                                ),
                              ],
                            ),
                            SizedBox(height: Globals.scaler.getHeight(2.5)),
                            Center(child: ThirdDotRow()),
                            SizedBox(height: Globals.scaler.getHeight(0.7)),
                            Center(
                              child: FutureBuilder(
                                // future: Globals.db!.getAllEventsAndCreated(null, true, null),
                                future: EventsSelectorBuilder.IinvolvedIn(
                                    myMail: Globals.currentUser!.email!,
                                    filterOldEvents: true,
                                    startFrom: null,
                                    maxEvents: null,
                                    // drop self event(when editing, to avoid false overlap alert)
                                    eventTesters: [
                                      (Event e) => (!event.shouldDuplicate &&
                                              e.id == event.id)
                                          ? null
                                          : e
                                    ]),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.done:
                                      return NextButton(
                                          context: context,
                                          event: this.event,
                                          whichPage: 2,
                                          isEmpty: false,
                                          allUserEvents:
                                              snapshot.data as List<Event>);
                                    case ConnectionState.none:
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                    default:
                                      return NextButton(
                                          context: context,
                                          event: this.event,
                                          whichPage: 2,
                                          isEmpty: false,
                                          allUserEvents: []);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  dropDownList(String text, List<DropdownMenuItem<String>> listDrop, var val) {
    return DropdownButtonHideUnderline(
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
                  blurRadius: Globals.scaler.getHeight(.2)),
            ],
            color: Colors.white70,
            border: Border.all(
                color: Colors.white70, width: Globals.scaler.getWidth(0.2)),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Material(
            elevation: Globals.scaler.getHeight(2),
            borderRadius: BorderRadius.circular(50.0),
            child: ButtonTheme(
              //alignedDropdown: true,
              child: DropdownButton(
                isExpanded: true,
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.teal[400],
                elevation: 1,
                value: val,
                style: const TextStyle(
                  color: Colors.teal,
                ),
                hint: Container(
                    width: Globals.scaler.getWidth(26.5),
                    child: TextField(
                        textAlign: TextAlign.center,
                        textDirection: ui.TextDirection.rtl,
                        autocorrect: true,
                        style: TextStyle(
                            fontSize: Globals.scaler.getTextSize(7.2),
                            color: Colors.teal),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: text))),
                items: listDrop,
                onChanged: (dynamic value) {
                  if (text == "בחרו מין יעד") {
                    gender = value;
                    event.targetGender = gender;
                    setState(() {});
                  } else if (text == "בחרו קבוצת יעד") {
                    targetStatus = value;
                    event.onlyForStatus = value;
                    setState(() {});
                  } else if (text == "בחרו תחום") {
                    if (value == "תורה") {
                      selectedBook = null;
                      loadTorahBooksData();
                    } else if (value == "נביאים") {
                      selectedBook = null;
                      loadNachBooksData();
                    } else if (value == "כתובים") {
                      selectedBook = null;
                      ketuvimBooksData();
                    } else if (value == "תלמוד בבלי") {
                      selectedBook = null;
                      loadBavliBooksData();
                    } else if (value == "תלמוד ירושלמי") {
                      selectedBook = null;
                      loadYerushalmiBooksData();
                    } else if (value == "חסידות") {
                      selectedBook = null;
                      loadHasidutBooksData();
                    } else if (value == "מחשבת ישראל") {
                      selectedBook = null;
                      loadMachshevetBooksData();
                    } else if (value == "אחר") {
                      selectedBook = null;
                      loadOtherBooksData();
                    } else if (value == "הלכה") {
                      selectedBook = null;
                      loadHalachaBooksData();
                    }
                    selectedTopic = value;
                    event.topic = selectedTopic;
                    setState(() {});
                  } else if (text == "בחרו ספר") {
                    selectedBook = value;
                    event.book = selectedBook;
                    setState(() {});
                  } else if (text == "בחרו האם זה שיעור או חברותא") {
                    selectedChoice = value;
                    //event.type = selectedChoice;
                    setState(() {
                      if (selectedChoice == "שיעור") {
                        event.type = "L";
                      } else {
                        event.type = "H";
                      }
                    });
                  }
                },
              ),
            ),
          ),
        )
      ],
    ));
  }

  appBar() {
    return new AppBar(
        leadingWidth: Globals.scaler.getWidth(0),
        toolbarHeight: Globals.scaler.getHeight(1.9),
        elevation: Globals.scaler.getHeight(1),
        shadowColor: Colors.teal[400],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        )),
        backgroundColor: Colors.white,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            widget.barTitle ?? 'קבע אירוע חדש  ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.calendar,
              size: Globals.scaler.getTextSize(9), color: Colors.teal[400])
        ]));
  }
}
