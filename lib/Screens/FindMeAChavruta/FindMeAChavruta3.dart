// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
//import 'package:flutter/cupertino.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Authenitcate.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter/rendering.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Third_dot_row.dart';
//import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
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
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "קישור לשיעור",
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
                              textDirection: TextDirection.rtl,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "פרטים נוספים",
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
                  ThirdDotRow(),
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
                                onPressed: () {
                                  widget.event!.creationDate = DateTime.now();
                                  widget.event!.participants = [];
                                  widget.event!.creatorUser =
                                      Globals.currentUser!.email;
                                  if (widget.event!.eventImage == "") {
                                    widget.event!.eventImage =
                                        'https://breastfeedinglaw.com/wp-content/uploads/2020/06/book.jpeg';
                                  }
                                  mongoDB!.insertEvent(widget.event!).then(
                                      (value) => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage())));
                                },
                                child: new Text(
                                  "מצא לי חברותא",
                                  style: TextStyle(
                                      fontSize: Globals.scaler.getTextSize(9),
                                      color: Colors.white),
                                )))
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
            "בחר תמונה לחברותא",
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
      print("error signing in");
    } else {
      print('signed in');
    }
    image = await picker.pickImage(source: source);
    var file = File(image?.path ?? "");
    //check if an image was picked
    if (image != null) {
      var snapshot =
          await _storage.ref().child('folderName/imageName').putFile(file);
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
