// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/event/create_event/authenitcate.dart';
import 'package:havruta_project/event/create_event/first_dot_row.dart';
import 'package:havruta_project/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:objectid/objectid.dart';
import '../../../data_base/data_representations/notification.dart';
import '../../../mydebug.dart' as MyDebug;
import '../../create_event/wavy_header.dart';
import 'package:firebase_storage/firebase_storage.dart';

PickedFile? image;

class CreateEventAdministrationDetails extends StatefulWidget {
  final Event? event;

  CreateEventAdministrationDetails({Key? key, required this.event})
      : super(key: key);

  @override
  _CreateEventAdministrationDetailsCreateState createState() =>
      _CreateEventAdministrationDetailsCreateState();
}

class _CreateEventAdministrationDetailsCreateState
    extends State<CreateEventAdministrationDetails> {
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
                                if (widget.event!.eventImage == "" ||
                                    widget.event!.eventImage == null) {
                                  widget.event!.eventImage =
                                      MyDebug.MyConsts.DEFAULT_EVENT_IMG;
                                }

                                /// new event:
                                if (widget.event!.id == null ||
                                    widget.event!.shouldDuplicate) {
                                  widget.event!.creationDate = DateTime.now();
                                  widget.event!.participants = [];
                                  widget.event!.waitingQueue = [];
                                  widget.event!.rejectedQueue = [];
                                  widget.event!.leftQueue = [];
                                  mongoDB!.insertEvent(widget.event!).then(
                                      (value) => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage())));
                                } else {
                                  /// update event:
                                  // notify all that the event was updated, or they rejected
                                  var e = widget.event!;
                                  var m = e.maxParticipants!;
                                  var pQ = e.participants!;
                                  var wQ = e.waitingQueue!;
                                  var rQ = e
                                      .rejectedQueue; // no-change unless not targeted
                                  var lQ = e
                                      .leftQueue; // no-change unless not targeted
                                  List toNotify = [];
                                  toNotify.addAll(pQ);
                                  toNotify.addAll(wQ);
                                  // (maxParticipants, not target, typeChange),

                                  // so rejected people will be "forget" and may rejoin/re-send invite
                                  Set noQueue = {}; // like new user for the app
                                  Set accepted = {};
                                  Set waiting = {};
                                  var popAll = (from, to1, [to2]) {
                                    to1.addAll(from);
                                    to2?.addAll(from);
                                    from.clear();
                                  };
                                  bool maxParticipantsConflict = false;

                                  /// maxParticipants conflict
                                  // reset both pQ wQ
                                  if (m < pQ.length) {
                                    maxParticipantsConflict = true;
                                    if (e.type == "H") {
                                      popAll(pQ, wQ, waiting);
                                    } else {
                                      popAll(pQ, noQueue);
                                      popAll(wQ, noQueue);
                                    }
                                  }

                                  /// type conflict

                                  if (e.type == 'L') {
                                    // empty wQ for Shiur,
                                    var thereIsPlace =
                                        m >= wQ.length + pQ.length;
                                    if (thereIsPlace) {
                                      // auto accept all waiting
                                      popAll(wQ, pQ, accepted);
                                    } else {
                                      popAll(wQ, noQueue);
                                    }
                                  }
                                  if (e.type == 'H' && e.firstInitType != 'H') {
                                    // auto move all to waiting
                                    popAll(pQ, wQ, waiting);
                                  }

                                  ///
                                  /// target conflict
                                  ///
                                  Set<String> tmp = {};
                                  await Future.wait((pQ + wQ + lQ + rQ).map(
                                      (mail) =>
                                          mongoDB!.getUser(mail).then((user) {
                                            if (user!.isTargetedForMe(e) ==
                                                false) {
                                              tmp.add(user.email!);
                                            }
                                          })));

                                  tmp.forEach((element) {
                                    pQ.remove(element);
                                    wQ.remove(element);
                                    lQ.remove(element);
                                    rQ.remove(element);
                                    noQueue.add(element);
                                  });

                                  //////
                                  /// dates conflict
                                  /// probably overwritten, or maybe not, anyway it done in ChooseDates.dart
                                  ///
                                  accepted = accepted.difference(noQueue);
                                  waiting = waiting.difference(noQueue);

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
                                      if (noQueue.contains(personToNotify)) {
                                        msg = Globals.currentUser!.gender == 'F'
                                            ? "ביטלה רישומך"
                                            : "ביטל רישומך";
                                        type = "eventUpdated:rejected";
                                      }
                                      if (waiting.contains(personToNotify)) {
                                        msg = Globals.currentUser!.gender == 'F'
                                            ? "הפכה השיעור לחברותא. נרשמת לתור המתנה"
                                            : "הפך השיעור לחברותא. נרשמת לתור המתנה";
                                        if (maxParticipantsConflict) {
                                          msg = "הועברת לתור המתנה";
                                        }
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
                                  }).then((value) => Navigator.pushReplacement(
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
        // widget.event!.eventImage =
        //     MyConsts.DEFAULT_EVENT_IMG;
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
