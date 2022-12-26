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
List<String> chasidutBooks = [];
List<String> machsehvetBooks = [];
List<String> otherBooks = [];

List<String> booksDrop = [];

class _FindMeAChavruta1CreateState extends State<FindMeAChavruta1> {
  var db = Globals.db;
  final format = DateFormat("yyyy-MM-dd");
  DateTime? val;
  String? value,
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
  double? spaceBetween, height, width, iconSize;
  int counter = 0;
  List<String> choice = MyData().choice;
  List<String> genderList = MyData().gender;
  String user = "yonatan";
  Event event = Event();

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
      child: Text(val),
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
    event.maxParticipants = 0;
    event.targetGender = '';
    event.book = '';
    event.topic = '';
    event.type = '';
    event.description = '';
    event.lecturer = '';
    event.dates = [];
    event.creatorName = Globals.currentUser!.name;
    event.creatorUser = Globals.currentUser!.email;
    event.eventImage = '';
    event.participants = [];
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
                                  FontAwesomeIcons.questionCircle,
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
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          autocorrect: true,
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontSize: Globals.scaler
                                                  .getTextSize(7.2)),
                                          decoration: InputDecoration(
                                            hintText: "מספר משתתפים",
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(
                                              Globals.scaler.getWidth(1.3),
                                              Globals.scaler.getWidth(1.3),
                                              Globals.scaler.getWidth(1.3),
                                              Globals.scaler.getWidth(1.3),
                                            ),
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
                                            if (event.maxParticipants == null) {
                                              event.maxParticipants = 1;
                                            }
                                          },
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
                                    Icons.face,
                                    color: Colors.red,
                                    //color: Colors.tealAccent[400],
                                    size: iconSize,
                                  ),
                                ]),
                            SizedBox(height: Globals.scaler.getHeight(2.5)),
                            Center(child: FirstDotRow()),
                            SizedBox(height: Globals.scaler.getHeight(0.7)),
                            Center(
                              child: NextButton(
                                  context: context,
                                  event: this.event,
                                  whichPage: 2,
                                  isEmpty: false),
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
            'קבע אירוע חדש  ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.calendar,
              size: Globals.scaler.getTextSize(9), color: Colors.teal[400])
        ]));
  }
}
