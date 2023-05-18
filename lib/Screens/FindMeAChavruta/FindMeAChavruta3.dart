// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Authenitcate.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/First_Dot_Row.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:objectid/objectid.dart';
import '../../DataBase_auth/Notification.dart';
import '../../mydebug.dart' as MyDebug;
import 'Wavy_Header.dart';
import 'package:firebase_storage/firebase_storage.dart';

PickedFile? image;

class FindMeAChavruta3 extends StatefulWidget {
  final Event? event;

  FindMeAChavruta3({Key? key, required this.event}) : super(key: key);

  @override
  _FindMeAChavruta3CreateState createState() => _FindMeAChavruta3CreateState();
}

class _FindMeAChavruta3CreateState extends State<FindMeAChavruta3> {
  final AuthService authenticate = AuthService();
  var mongoDB = Globals.db;
  File? image;
  final yeshiva = TextEditingController();
  String yeshiva_str = "";
  final details = TextEditingController();
  String details_str = "";
  String? link;
  double? spaceBetween;
  late TextEditingController linkController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController lecturerController;

  @override
  void initState() {
    super.initState();
    link = widget.event?.link;
    descriptionController =
        TextEditingController(text: widget.event?.description);
    linkController = TextEditingController(text: link);
    locationController = TextEditingController(text: widget.event?.location);
    lecturerController = TextEditingController(text: widget.event?.lecturer);
  }

  Widget checkIfShiur() {
    if (widget.event!.type == 'L') {
      return Container(
        height: Globals.scaler.getHeight(2.5),
        width: Globals.scaler.getWidth(35),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.teal[400]!, width: Globals.scaler.getWidth(.1)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: new TextField(
          controller: lecturerController,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "פרטי מעביר השיעור",
            focusColor: Colors.teal,
            contentPadding: EdgeInsets.fromLTRB(
                Globals.scaler.getWidth(2),
                Globals.scaler.getHeight(0),
                Globals.scaler.getWidth(2),
                Globals.scaler.getHeight(0)),
          ),
          onChanged: (lecturer) {
            widget.event!.lecturer = lecturer;
            if (widget.event!.lecturer == null) {
              widget.event!.lecturer = "";
            }
          },
        ),
      );
    }
    return Container(height: Globals.scaler.getHeight(0));
  }

  Widget build(BuildContext context) {
    spaceBetween = Globals.scaler.getHeight(2);
    return Scaffold(
      appBar: appBar(),
      body: Builder(
        builder: (context) => Center(
          child: Stack(children: [
            Column(
              children: [
                WavyHeader(),
              ],
            ),
            //------Camera--------
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.only(top: Globals.scaler.getHeight(1.5))),
                  Container(
                    width: Globals.scaler.getWidth(12),
                    height: Globals.scaler.getHeight(5),
                    child: imageProfile(),
                  ),
                  SizedBox(height: spaceBetween),
                  Container(
                    child: checkIfShiur(),
                  ),
                  SizedBox(height: spaceBetween),
                  Stack(
                    children: [
                      SizedBox(height: spaceBetween),
                      Container(
                          height: Globals.scaler.getHeight(2.5),
                          width: Globals.scaler.getWidth(35),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.teal[400]!,
                                width: Globals.scaler.getWidth(0.1)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: new TextField(
                            controller: linkController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "קישור אונליין",
                              focusColor: Colors.teal,
                              contentPadding: EdgeInsets.fromLTRB(
                                  Globals.scaler.getWidth(2),
                                  Globals.scaler.getHeight(0),
                                  Globals.scaler.getWidth(2),
                                  Globals.scaler.getHeight(0)),
                            ),
                            maxLines: 1,
                            onChanged: (link) {
                              widget.event!.link = link;
                            },
                          )),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  Container(
                    height: Globals.scaler.getHeight(2.5),
                    width: Globals.scaler.getWidth(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.teal[400]!,
                          width: Globals.scaler.getWidth(.1)),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: new TextField(
                      controller: locationController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "מיקום ודרכי הגעה",
                        focusColor: Colors.teal,
                        contentPadding: EdgeInsets.fromLTRB(
                            Globals.scaler.getWidth(2),
                            Globals.scaler.getHeight(0),
                            Globals.scaler.getWidth(2),
                            Globals.scaler.getHeight(0)),
                      ),
                      onChanged: (location) {
                        widget.event!.location = location;
                      },
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  Stack(
                    children: [
                      Container(
                          height: Globals.scaler.getHeight(9),
                          width: Globals.scaler.getWidth(35),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.teal[400]!,
                                width: Globals.scaler.getWidth(0.1)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: TextField(
                              controller: descriptionController,
                              textDirection: TextDirection.rtl,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "...פרטים נוספים",
                                helperText: "פרטים נוספים",
                                focusColor: Colors.blue,
                                contentPadding: EdgeInsets.fromLTRB(
                                    Globals.scaler.getWidth(2),
                                    Globals.scaler.getHeight(0),
                                    Globals.scaler.getWidth(2),
                                    Globals.scaler.getHeight(0.5)),
                              ),
                              onChanged: (description) {
                                widget.event!.description = description;
                              },
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  FirstDotRow(),
                  SizedBox(height: spaceBetween! - 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(children: [
                        Container(
                            width: Globals.scaler.getWidth(28),
                            height: Globals.scaler.getHeight(2.3),
                            decoration: BoxDecoration(
                              color: Colors.teal[400],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal),
                              onPressed: () async {
                                /// new and update event:
                                widget.event!.creatorUser =
                                    Globals.currentUser!.email;
                                if (widget.event!.eventImage == "") {
                                  widget.event!.eventImage =
                                      'https://breastfeedinglaw.com/wp-content/uploads/2020/06/book.jpeg';
                                }

                                /// new event:
                                if (widget.event!.id == null ||
                                    widget.event!.shouldDuplicate) {
                                  widget.event!.creationDate = DateTime.now();
                                  widget.event!.participants = [];
                                  widget.event!.waitingQueue = [];
                                  mongoDB!.insertEvent(widget.event!).then(
                                      (value) => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage())));
                                } else {
                                  /// update event:
                                  // notify all that the event was updated, or they rejected
                                  var e = widget.event!;
                                  var m = e.maxParticipants!;
                                  var p = e.participants!;
                                  var wq = e.waitingQueue!;
                                  List toNotify = [];
                                  toNotify.addAll(p);
                                  toNotify.addAll(wq);
                                  Set rejected = {};
                                  Set accepted = {};
                                  Set waiting = {};

                                  ///
                                  /// maxParticipants conflict [affect rejected,waitingQueue,participants]
                                  ///
                                  // due to the new max participants value, reset lists:
                                  if (m >= p.length + wq.length) {
                                    // don't reset lists
                                  } else if (m >= p.length) {
                                    /*// reset only wq
                                    rejected.addAll(wq);
                                    widget.event!.waitingQueue = [];*/
                                  } else {
                                    // reset both p wq
                                    rejected.addAll(p);
                                    rejected.addAll(wq);
                                    widget.event!.participants = [];
                                    widget.event!.waitingQueue = [];
                                  }

                                  //////
                                  /// type conflict  [affect waiting,accepted,waitingQueue,participants]
                                  ///
                                  wq = widget.event!.waitingQueue!;
                                  p = widget.event!.participants!;
                                  if (e.type == 'L') {
                                    // if there is place,
                                    if (m >= wq.length + p.length) {
                                      // auto accept all waiting
                                      e.participants!.addAll(e.waitingQueue!);
                                      accepted.addAll(e.waitingQueue!);
                                      e.waitingQueue = [];
                                    } else {
                                      // reset only wq
                                      rejected.addAll(wq);
                                      widget.event!.waitingQueue = [];
                                    }
                                  } else if (e.type == 'H' &&
                                      e.firstInitType != 'H') {
                                    // auto move all to waiting
                                    e.waitingQueue!.addAll(e.participants!);
                                    waiting.addAll(e.participants!);
                                    e.participants = [];
                                  }

                                  ///
                                  /// target[Gender] conflict  [affect rejected,waitingQueue,participants]
                                  ///
                                  Set<String> tmp = {};
                                  var rejectDueGender = (List list) async =>
                                      Future.wait(list.map((mail) =>
                                          mongoDB!.getUser(mail).then((user) {
                                            /*String? avoid = <String?, String>{
                                              "F": "גברים",
                                              "M": "נשים"
                                            }[user.gender];
                                            if (avoid == e.targetGender) {*/
                                            if (!user.isTargetedForMe(e)) {
                                              tmp.add(user.email!);
                                            }
                                          })));
                                  await rejectDueGender(e.participants!);
                                  await rejectDueGender(e.waitingQueue!);
                                  rejected.addAll(tmp);
                                  e.participants = e.participants!
                                      .where((v) => !tmp.contains(v))
                                      .toList();
                                  e.waitingQueue = e.waitingQueue!
                                      .where((v) => !tmp.contains(v))
                                      .toList();
                                  //////
                                  /// dates conflict
                                  /// probably overwritten, or maybe not, anyway it done in ChooseDates.dart
                                  ///
                                  accepted = accepted.difference(rejected);
                                  waiting = waiting.difference(rejected);
                                  // update event
                                  mongoDB!.updateEvent(widget.event!).then(
                                      // then
                                      (_) {
                                    // for each user that is/was in my event
                                    for (String personToNotify in toNotify) {
                                      String type = "eventUpdated";
                                      // notify msg format:
                                      var t = widget.event!.type == 'H'
                                          ? "חברותא"
                                          : "שיעור";
                                      var g = Globals.currentUser!.gender == 'F'
                                          ? "עידכנה"
                                          : "עידכן";
                                      var msg = g + " " + t;
                                      // rejected msg format:
                                      if (rejected.contains(personToNotify)) {
                                        msg = Globals.currentUser!.gender == 'F'
                                            ? "ביטלה רישומך"
                                            : "ביטל רישומך";
                                        type = "eventUpdated:rejected";
                                      }
                                      if (waiting.contains(personToNotify)) {
                                        msg = Globals.currentUser!.gender == 'F'
                                            ? "הפכה השיעור לחברותא. נרשמת לתור המתנה"
                                            : "הפך השיעור לחברותא. נרשמת לתור המתנה";
                                      }
                                      if (accepted.contains(personToNotify)) {
                                        msg = Globals.currentUser!.gender == 'F'
                                            ? "הפכה החברותא לשיעור. צורפת אוטומטית"
                                            : "הפך החברותא לשיעור. צורפת אוטומטית";
                                      }
                                      var m = {
                                        'creatorUser':
                                            Globals.currentUser!.email,
                                        'destinationUser': personToNotify,
                                        'creationDate': DateTime.now(),
                                        'message': msg, // rejected / notify
                                        'type': type,
                                        'idEvent': e.id,
                                        'name': Globals.currentUser!.name,
                                      };

                                      Globals.db!.insertNotification(
                                          NotificationUser.fromJson(m));
                                    }
                                  }).then((value) => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage())));
                                }
                              },
                              child: Icon(FontAwesomeIcons.check,
                                  color: Colors.white,
                                  textDirection: TextDirection.rtl),

                              /*new Text(
                                  //"מצא לי חברותא",
                                  "אישור",
                                  style: TextStyle(
                                      fontSize: Globals.scaler.getTextSize(9),
                                      color: Colors.white),
                                )*/
                            ))
                      ])
                    ],
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(children: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            showModalBottomSheet(
                context: context, builder: ((builder) => bottomSheet()));
          },
          child: CircleAvatar(
            radius: 60.0,
            backgroundColor: Colors.teal,
            backgroundImage: (widget.event!.eventImage!.isNotEmpty)
                ? NetworkImage(widget.event!.eventImage!)
                : null,
          ),
        ),
        Positioned(
          bottom: Globals.scaler.getHeight(1.5),
          right: Globals.scaler.getWidth(4.3),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: Globals.scaler.getTextSize(11),
            ),
          ),
        ),
      ]),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: Globals.scaler.getHeight(5.5),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: Globals.scaler.getWidth(3),
        vertical: Globals.scaler.getHeight(1),
      ),
      child: Column(
        children: <Widget>[
          Text(
            widget.event!.type == 'L'
                ? (Globals.currentUser!.gender == 'F'
                    ? "בחרי תמונה לשיעור"
                    : "בחר תמונה לשיעור")
                : (Globals.currentUser!.gender == 'F'
                    ? "בחרי תמונה לחברותא"
                    : "בחר תמונה לחברותא"),
            style: TextStyle(
              fontSize: Globals.scaler.getTextSize(8.5),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () async {
                uploadImage(ImageSource.camera);
                Navigator.pop(context);
              },
              label: Text("Camera"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                uploadImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  // TODO : ?? Future<File> uploadImage(ImageSource source) async {
  Future<void> uploadImage(ImageSource source) async {
    final _storage = FirebaseStorage.instance;
    XFile? image;
    final picker = ImagePicker();
    dynamic result = await authenticate.signInAnon();
    if (result == null) {
      MyDebug.myPrint("error signing in", MyDebug.MyPrintType.None);
    } else {
      MyDebug.myPrint('signed in', MyDebug.MyPrintType.None);
    }
    image = await picker.pickImage(source: source);
    String fileName = ObjectId().toString();
    var file = File(image?.path ?? "");
    //check if an image was picked
    if (image != null) {
      var snapshot =
          await _storage.ref().child('Images/$fileName').putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        widget.event!.eventImage = downloadUrl;
      });
    } else {
      setState(() {
        widget.event!.eventImage =
            'https://breastfeedinglaw.com/wp-content/uploads/2020/06/book.jpeg';
      });
    }
  }

  appBar() {
    return AppBar(
        leadingWidth: Globals.scaler.getWidth(0),
        toolbarHeight: Globals.scaler.getHeight(2),
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
            'פרטים נוספים',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          //Icon(FontAwesomeIcons.calendar, size: 25, color: Colors.teal[400])
        ]));
  }
}
