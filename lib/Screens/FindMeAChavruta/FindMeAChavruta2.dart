import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Second_Dot_Row.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'Next_Button.dart';
import 'SetDates.dart';
import 'arc_banner_image.dart';

class FindMeAChavruta2 extends StatefulWidget {
  Event event;

  FindMeAChavruta2({this.event});

  @override
  _FindMeAChavruta2CreateState createState() => _FindMeAChavruta2CreateState();
}

class _FindMeAChavruta2CreateState extends State<FindMeAChavruta2> {
  var db = Globals.db;
  double spaceBetween;
  List<String> dateTimes = [];
  List<DateTime> dateTimeListForMongo = [];
  String text = "בחרו זמנים ללמוד", dayStr, startDate, endDate, fullDate;
  int indexForDbList = 0;

  @override
  Widget build(BuildContext context) {
    spaceBetween = 20;
    return Scaffold(
        appBar: appBar(),
        body: Builder(
            builder: (context) => Center(
                  child: Stack(children: [
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: ArcBannerImage(
                              "https://images.unsplash.com/photo-1435527173128-983b87201f4d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1494&q=80"),
                        ),
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                              ),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ListView.builder(
                                          itemCount: this.dateTimes.length,
                                          shrinkWrap: true,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(15.0),
                                          itemBuilder: (context, index) {
                                            final item = this.dateTimes[index];
                                            var chavrutaInfoMessage =
                                                ('${this.dateTimes[index]}');
                                            return Dismissible(
                                              key: Key(item),
                                              direction:
                                                  DismissDirection.endToStart,
                                              onDismissed: (direction) {
                                                setState(() {
                                                  print(dateTimes);
                                                  this
                                                      .dateTimes
                                                      .removeAt(index);
                                                  widget.event.dates.removeAt(
                                                      indexForDbList - 1);
                                                  widget.event.dates.removeAt(
                                                      indexForDbList - 2);
                                                  indexForDbList -= 2;
                                                  return widget.event.dates;
                                                });
                                              },
                                              background:
                                                  buildSwipeActionRight(),
                                              child: Card(
                                                shape: Border(
                                                    right: BorderSide(
                                                        color: Colors.green,
                                                        width: 5)),
                                                child: Material(
                                                  elevation: 15,
                                                  shadowColor: Colors.black,
                                                  child: ListTile(
                                                    title: Text(
                                                      chavrutaInfoMessage,
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
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
                                                          setState(() {
                                                            this
                                                                .dateTimes
                                                                .removeAt(
                                                                    index);
                                                            widget.event.dates
                                                                .removeAt(
                                                                    indexForDbList -
                                                                        1);
                                                            widget.event.dates
                                                                .removeAt(
                                                                    indexForDbList -
                                                                        2);
                                                            indexForDbList -= 2;
                                                            return widget
                                                                .event.dates;
                                                          });
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            );
                                          })))
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(80, 7, 80, 0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(108, 0, 80, 0)),
                            //Padding(padding: padding)
                            FloatingActionButton(
                              backgroundColor: Colors.green,
                              onPressed: () async {
                                final List<DateTime> dTList =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SetDate(event: widget.event)));
                                this.indexForDbList += 2;
                                setState(() {
                                  widget.event.dates.add(dTList[0]);
                                  widget.event.dates.add(dTList[1]);
                                  this.startDate =
                                      DateFormat('MM-dd-yyyy: kk:mm')
                                          .format(dTList[0]);
                                  this.endDate =
                                      DateFormat('kk:mm').format(dTList[1]);
                                  this.fullDate =
                                      startDate + " - " + this.endDate;
                                  this.dateTimes.add(fullDate);
                                  //print(widget.event.dates);
                                });
                              },
                              mini: true,
                              child: Text(
                                "+",
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(55, 25, 10, 0),
                        ),
                        SecondDotRow(),
                        //########### ----NEXT ARROW----########
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.event.dates.isEmpty
                                ? NextButton(
                                    context: context,
                                    event: widget.event,
                                    whichPage: 3,
                                    isEmpty: true)
                                : NextButton(
                                    context: context,
                                    event: widget.event,
                                    whichPage: 3,
                                    isEmpty: false)
                          ],
                        ),
                        SizedBox(height: spaceBetween)
                      ],
                    ),
                  ]),
                )));
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
            'הוסיפו זמני לימוד  ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.clock, size: 25, color: Colors.teal[400])
        ]));
  }

  Widget buildSwipeActionRight() => Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete_forever, color: Colors.white, size: 32),
      );

  alertMessage() {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("אי אפשר לשמור את התאריך"),
      content: Text("זמן התחלה צריך להיות לפני זמן סיום"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
