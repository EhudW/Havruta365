import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/Third_dot_row.dart';

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

  Widget checkIfShiur() {
    print("Event type" + widget.event.type);
    if (widget.event.type == 'שיעור') {
      return Container(
        height: 42,
        width: 380,
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
            contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 10.0, 10.0),
            // border: OutlineInputBorder(
            //     borderRadius: BorderRadius.circular(20.0),
            //     borderSide: const BorderSide(
            //         color: Colors.blue, width: 2.0))),
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
    spaceBetween = 40;
    return Scaffold(
        appBar: appBar(),
        body: Builder(
          builder: (context) => Center(
            child: Stack(children: [
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: WavyHeader()),
                ],
              ),
              //------Camera--------
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.only(top: 45.0)),
                    Container(
                      width: 150,
                      height: 100,
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
                            height: 42,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.teal[400], width: 1.0),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: new TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "קישור לזום",
                                focusColor: Colors.teal,
                                contentPadding:
                                    EdgeInsets.fromLTRB(8.0, 10.0, 10.0, 10.0),
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
                            height: 130,
                            width: 380,
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
                                contentPadding:
                                    EdgeInsets.fromLTRB(8.0, 10.0, 10.0, 10.0),
                                // border: OutlineInputBorder(
                                //     borderRadius: BorderRadius.circular(20.0),
                                //     borderSide: const BorderSide(
                                //         color: Colors.blue, width: 2.0))),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                    ),
                    ThirdDotRow(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(children: [
                          Container(
                              height: 42,
                              width: 350,
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
                                        'https://romancebooks.co.il/wp-content/uploads/2019/06/default-user-image.png';
                                    //print(widget.event.creationDate);
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
                                        fontSize: 20.0, color: Colors.white),
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
                takePhoto(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
    );
    setState(() {
      _imageFile = pickedFile;
    });
  }
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
