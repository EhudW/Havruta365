import 'dart:io';
import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Third_dot_row.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'Wavy_Header.dart';

class FindMeAChavruta3 extends StatefulWidget {
  final Event event;

  FindMeAChavruta3({Key key, @required this.event}) : super(key: key);

  @override
  _FindMeAChavruta3CreateState createState() => _FindMeAChavruta3CreateState();
}

class _FindMeAChavruta3CreateState extends State<FindMeAChavruta3> {
  var mongoDB = Globals.db;
  PickedFile _imageFile;
  final ImagePicker _picker = ImagePicker();
  final yeshiva = TextEditingController();
  String yeshiva_str = "";
  final details = TextEditingController();
  String details_str = "";
  String link;
  double spaceBetween;

  Widget checkIfShiur(ScreenScaler scaler) {
    print("Event type" + widget.event.type);
    if (widget.event.type == 'שיעור') {
      return Container(
        height: scaler.getHeight(2.2),
        width: scaler.getWidth(33),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.teal[400], width: 1.0),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: new TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "פרטי מעביר השיעור",
            focusColor: Colors.teal,
            contentPadding: EdgeInsets.fromLTRB(scaler.getWidth(2), scaler.getHeight(1), scaler.getWidth(2), scaler.getHeight(.5)),
          ),
          onChanged: (lecturer) {
            widget.event.lecturer = lecturer;
            print(widget.event.lecturer);
            if (widget.event.lecturer == null) {
              widget.event.lecturer = "";
              print(widget.event.lecturer);
            }
            //print(widget.event.link);
          },
        ),
      );
    }
    return Container(height: 0);
  }

  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler();
    spaceBetween = scaler.getHeight(2);
    return Scaffold(
        appBar: appBar(),
        body: Builder(
          builder: (context) => Center(
            child: Stack(children: [
              Column(
                children: [
                  Padding(
                      padding:  EdgeInsets.only(bottom: scaler.getHeight(0)),
                      child: WavyHeader()),
                ],
              ),
              //------Camera--------
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(padding:  EdgeInsets.only(top: scaler.getHeight(2))),
                    Container(
                      width: scaler.getWidth(12),
                      height: scaler.getHeight(5),
                      child: imageProfile(),
                    ),
                    SizedBox(height: spaceBetween),
                    Container(
                      child: checkIfShiur(scaler),
                    ),
                    SizedBox(height: spaceBetween),
                    Stack(
                      children: [
                        SizedBox(height: spaceBetween),
                        Container(
                            height: scaler.getHeight(2.2),
                            width: scaler.getWidth(33),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.teal[400], width: scaler.getWidth(0.1)),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: new TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "קישור לזום",
                                focusColor: Colors.teal,
                                contentPadding: EdgeInsets.fromLTRB(scaler.getWidth(2), scaler.getHeight(1), scaler.getWidth(2), scaler.getHeight(.5)),
                              ),
                              maxLines: 1,
                              onChanged: (link) {
                                widget.event.link = link;
                                print("Link" + widget.event.link);
                                if (widget.event.link == null) {
                                  widget.event.link = "";
                                  print("Link" + widget.event.link);
                                }
                              },
                            )),
                      ],
                    ),
                    SizedBox(height: spaceBetween),
                    Stack(
                      children: [
                        Container(
                            height: scaler.getHeight(8),
                            width: scaler.getWidth(33),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.teal[400], width: 1.0),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextField(
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "פרטים נוספים",
                                focusColor: Colors.blue,
                                contentPadding: EdgeInsets.fromLTRB(scaler.getWidth(2), scaler.getHeight(1), scaler.getWidth(2), scaler.getHeight(.5)),
                              ),
                              onChanged: (description) {
                                widget.event.description = description;
                                print("Description" + widget.event.description);
                                if (widget.event.description == null) {
                                  widget.event.description = "";
                                  print(
                                      "Description" + widget.event.description);
                                }
                              },
                            )),
                      ],
                    ),
                    SizedBox(height: spaceBetween),
                    ThirdDotRow(),
                    SizedBox(height: spaceBetween - 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(children: [
                          Container(
                              width: scaler.getWidth(30),
                              height: scaler.getHeight(2.5),
                              decoration: BoxDecoration(
                                color: Colors.teal[400],
                              ),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.teal),
                                  onPressed: () {
                                    widget.event.creationDate = DateTime.now();
                                    widget.event.participants = [];
                                    widget.event.creatorUser = "";
                                    widget.event.eventImage =
                                        'https://breastfeedinglaw.com/wp-content/uploads/2020/06/book.jpeg';
                                    mongoDB.insertEvent(widget.event).then(
                                        (value) => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage())));
                                  },
                                  child: new Text(
                                    "מצא לי חברותא",
                                    style: TextStyle(
                                        fontSize: scaler.getTextSize(8.5), color: Colors.white),
                                  )))
                        ])
                      ],
                    ),
                  ],
                ),
              )
            ]),
          ),
        ));
  }

  Widget imageProfile() {
    return Center(
      child: Stack(children: <Widget>[
        CircleAvatar(
          radius: 60.0,
          backgroundColor: Colors.teal,

          // backgroundImage: _imageFile == null
          //     ? AssetImage("assets/profile.jpg")
          //     : FileImage(File(_imageFile.path)),
        ),
        Positioned(
          bottom: 35.0,
          right: 45.0,
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
              size: 28.0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "בחר תמונה לחברותא",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () {
                openCamera(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                openCamera(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Future<File> openCamera(source) async {
    File _image;
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(source: source);
    print('PickedFile: ${pickedFile.toString()}');

    setState(() {
      _image = File(pickedFile.path);
    });
    if (_image != null) {
      return _image;
    }
    return null;
  }

  appBar() {
    return AppBar(
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
            'פרטים נוספים',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[400]),
          ),
          //Icon(FontAwesomeIcons.calendar, size: 25, color: Colors.teal[400])
        ]));
  }
}
