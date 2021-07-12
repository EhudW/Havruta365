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
import "dart:async";
import 'Next_Button.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';



class FindMeAChavruta1 extends StatefulWidget {
  @override
  _FindMeAChavruta1CreateState createState() => _FindMeAChavruta1CreateState();
}

List<String> topics = [];
List<String> humashBooks = [];
List<String> neviimBooks = [];
List<String> ketuvimBooks = [];
List<String> talmudBavliBooks = [];
List<String> talmudYerushalmiBooks = [];
List<String> halachaBooks = [];
List<String> booksDrop = [];



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
  List<String> genderList = MyData().gender;

  //User user = User();
  String user = "yonatan";
  Event event = Event();

  Future<List<Topic>> getTopics() async {
    final topicsList = await Globals.db.getTopics();
    topics = [];
    humashBooks = [];
    neviimBooks = [];
    ketuvimBooks = [];
    talmudBavliBooks = [];
    talmudYerushalmiBooks = [];
    halachaBooks = [];
    for (var i in topicsList) {
      final title = i.title;
      if (title == "תחומים") {
        for (var j in i.tags) {
          topics.add(j);
        }
      } else if (title == "תורה") {
        for (var j in i.tags) {
          humashBooks.add(j);
        }
      } else if (title == "נביאים") {
        for (var j in i.tags) {
          neviimBooks.add(j);
        }
      } else if (title == "כתובים") {
        for (var j in i.tags) {
          ketuvimBooks.add(j);
        }
      } else if (title == "תלמוד בבלי") {
        for (var j in i.tags) {
          talmudBavliBooks.add(j);
        }
      } else if (title == "תלמוד ירושלמי") {
        for (var j in i.tags) {
          talmudYerushalmiBooks.add(j);
        }
      } else if (title == "הלכה") {
        for (var j in i.tags) {
          halachaBooks.add(j);
        }
      }
    }
    loadTopicssData();
    return topicsList;
  }

  Future<void> loadTopicssData() async {
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
            value: val))
        .toList();
  }

  void loadTorahBooksData() {
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
    humashBooks = [];
  }

  void loadNachBooksData() {
    //booksDrop = [];
    booksDrop = neviimBooks
        .map((val) => DropdownMenuItem<String>(
              child: Container(
                child: Text(val),
                width: 231,
                alignment: Alignment.center,
              ),
              value: val,
            ))
        .toList();
  }

  void loadBavliBooksData() {
    //booksDrop = [];
    booksDrop = talmudBavliBooks
        .map((val) => DropdownMenuItem<String>(
              child: Container(
                child: Text(val),
                width: 231,
                alignment: Alignment.center,
              ),
              value: val,
            ))
        .toList();
  }

  void loadChoices() {
    choiceDrop = [];
    choiceDrop = choice
        .map((val) => DropdownMenuItem<String>(
              child: Container(
                width: 231,
                alignment: Alignment.center,
                child: Text(
                  val,
                  textAlign: TextAlign.center,
                  // style: TextStyle(
                  //     fontSize: 15
                  // ),
                ),
              ),
              value: val,
            ))
        .toList();
  }

  void ketuvimBooksData() {
    booksDrop = [];
    booksDrop = ketuvimBooks
        .map((val) => DropdownMenuItem<String>(
      child: Container(
        width: 231,
        alignment: Alignment.center,
        child: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25
          ),
        ),
      ),
      value: val,
    ))
        .toList();
  }

  void loadYerushalmiBooksData() {
    booksDrop = [];
    booksDrop = talmudYerushalmiBooks
        .map((val) => DropdownMenuItem<String>(
      child: Container(
        width: 231,
        alignment: Alignment.center,
        child: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25
          ),
        ),
      ),
      value: val,
    ))
        .toList();
  }

  void loadHalachaBooksData() {
    booksDrop = [];
    booksDrop = halachaBooks
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

  void loadGenderData() {
    genderDrop = [];
    genderDrop = genderList
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

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler();
    if (this.counter == 0) {
      intializeEvent(this.event);
      this.counter += 1;
    }
    spaceBetween = scaler.getHeight(1.2);
    height = scaler.getHeight(3);
    width = scaler.getWidth(27);
    iconSize = scaler.getTextSize(11);
    loadGenderData();
    loadChoices();
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                return Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                            padding:  EdgeInsets.only(bottom: scaler.getHeight(0)),
                            child: WavyHeader()),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: scaler.getHeight(3))),
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
                                        isExpanded: false,
                                        elevation: 1,
                                        value: selectedChoice,
                                        style: const TextStyle(
                                          color: Colors.teal,
                                        ),
                                        hint: Container(
                                            width: scaler.getWidth(10),
                                            child: TextField(
                                                textAlign: TextAlign.center,
                                                autocorrect: true,
                                                style: const TextStyle(
                                                    color: Colors.teal),
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
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
                              padding:  EdgeInsets.all(scaler.getWidth(1.5)),
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
                                padding: EdgeInsets.fromLTRB(scaler.getWidth(10), scaler.getHeight(1), scaler.getWidth(10), scaler.getHeight(1)),
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
                                    border: Border.all(
                                        color: Colors.white70, width: 2.5),
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
                                        style:  TextStyle(
                                            color: Colors.teal, fontSize: scaler.getTextSize(7)),
                                        decoration: InputDecoration(
                                          hintText: "מספר משתתפים",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              scaler.getWidth(1.5), 15.0, 20.0, 10.0),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        maxLines: 1,
                                        onChanged: (newVal) {
                                          var numOfParticapints =
                                              int.parse(newVal);
                                          event.maxParticipants =
                                              numOfParticapints;
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
                              padding:  EdgeInsets.all(scaler.getWidth(1.5)),
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
                                        isExpanded: false,
                                        elevation: 1,
                                        value: selectedTopic,
                                        style: const TextStyle(
                                          color: Colors.teal,
                                        ),
                                        hint: Container(
                                            width: scaler.getWidth(10),
                                            child: TextField(
                                                textAlign: TextAlign.center,
                                                autocorrect: true,
                                                style: const TextStyle(
                                                    color: Colors.teal),
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
                                                    hintText: "בחרו תחום"))),
                                        items: topicsDrop,
                                        onChanged: (value) {
                                          if (value == "תורה") {
                                            topics = [];
                                            loadTorahBooksData();
                                          } else if (value == "נביאים") {
                                            topics = [];
                                            loadNachBooksData();
                                          } else if (value == "כתובים") {
                                            topics = [];
                                            ketuvimBooksData();
                                          }else if (value == "תלמוד בבלי") {
                                            topics = [];
                                            loadBavliBooksData();
                                          }
                                          else if (value == "תלמוד ירושלמי") {
                                            topics = [];
                                            loadYerushalmiBooksData();
                                          }
                                          else if (value == "הלכה") {
                                            topics = [];
                                            loadHalachaBooksData();
                                          }
                                          selectedTopic = value;
                                          event.topic = selectedTopic;
                                          setState(() {
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                            Padding(
                              padding:  EdgeInsets.all(scaler.getWidth(1.5)),
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
                                            width: scaler.getWidth(10),
                                            child: TextField(
                                                textAlign: TextAlign.center,
                                                autocorrect: true,
                                                style: const TextStyle(
                                                    color: Colors.teal),
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
                                                    hintText: "בחרו ספר"))),
                                        items: booksDrop,
                                        onChanged: (value) {
                                          selectedBook = value;
                                          event.book = selectedBook;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            Padding(
                              padding:  EdgeInsets.all(scaler.getWidth(1.5)),
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
                                              width: scaler.getWidth(10),
                                              child: TextField(
                                                  textAlign: TextAlign.center,
                                                  autocorrect: true,
                                                  style: const TextStyle(
                                                      color: Colors.teal),
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      hintText:
                                                          "בחרו מין יעד"))),
                                          items: genderDrop,
                                          onChanged: (value) {
                                            gender = value;
                                            this.event.targetGender = gender;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                              Padding(
                                padding:  EdgeInsets.all(scaler.getWidth(1.5)),
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
                        SizedBox(height: scaler.getHeight(1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            NextButton(
                                context: context,
                                event: this.event,
                                whichPage: 2,
                                isEmpty: false),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }
            }),
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
