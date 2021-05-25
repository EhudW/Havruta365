import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FindMeAChavruta2 extends StatefulWidget {
  @override
  _FindMeAChavruta2CreateState createState() => _FindMeAChavruta2CreateState();
}

class _FindMeAChavruta2CreateState extends State<FindMeAChavruta2> {
  PickedFile _imageFile;
  final ImagePicker _picker = ImagePicker();
  final yeshiva = TextEditingController();
  String yeshiva_str = "";
  final details = TextEditingController();
  String details_str = "";

  Widget build(BuildContext context) {
    ScreenUtil.init(BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 667),
        orientation: Orientation.portrait);
    return Scaffold(
      appBar: CustomAppBar(
        title: "חברותא חדשה",
        gradientBegin: Colors.blue,
        gradientEnd: Colors.greenAccent,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 20, 20),
            ),
            //------Camera--------
            Container(
              width: 150,
              height: 100,
              child: imageProfile(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 30, 20, 20),
            ),
            Stack(
              children: [
                Container(
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

                          hintText: "קישור לזום",
                          focusColor: Colors.teal,
                          contentPadding:
                              EdgeInsets.fromLTRB(8.0, 10.0, 10.0, 10.0),
                          // border: OutlineInputBorder(
                          //     borderRadius: BorderRadius.circular(20.0),
                          //     borderSide: const BorderSide(
                          //         color: Colors.blue, width: 2.0))),
                        ),
                        maxLines: 1)),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 30, 20, 20),
            ),
            Stack(
              children: [
                Container(
                    height: 180,
                    width: 380,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.teal[400], width: 1.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: new TextField(
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
                        maxLines: 1)),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 20, 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 54,
                  height: 6,
                  child: Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(16.0, 0.0, 6.0, 6.0),
                        size: Size(54.0, 6.0),
                        pinTop: true,
                        pinBottom: true,
                        fixedWidth: true,
                        child: SvgPicture.string(
                          _svg_h36wzl,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(32.0, 0.0, 6.0, 6.0),
                        size: Size(54.0, 6.0),
                        pinTop: true,
                        pinBottom: true,
                        fixedWidth: true,
                        child: SvgPicture.string(
                          _svg_h36wzl,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(48.0, 0.0, 6.0, 6.0),
                        size: Size(54.0, 6.0),
                        pinTop: true,
                        pinBottom: true,
                        fixedWidth: true,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.elliptical(9999.0, 9999.0)),
                            color: Colors.teal[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                          onPressed: () {},
                          child: new Text(
                            "מצא לי חברותא",
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                          )))
                ])
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(children: <Widget>[
        CircleAvatar(
          radius: 60.0,

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
            FlatButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            FlatButton.icon(
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

const String _svg_h36wzl =
    '<svg viewBox="16.0 0.0 6.0 6.0" ><path transform="translate(16.0, 0.0)" d="M 3 0 C 4.656854152679443 0 6 1.343145847320557 6 3 C 6 4.656854152679443 4.656854152679443 6 3 6 C 1.343145847320557 6 0 4.656854152679443 0 3 C 0 1.343145847320557 1.343145847320557 0 3 0 Z" fill="#bce0fd" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_tmar9d =
    '<svg viewBox="40.0 514.0 327.0 48.0" ><path transform="translate(40.0, 514.0)" d="M 26.60338973999023 0 L 300.3966064453125 0 C 315.0892639160156 0 327 10.74516487121582 327 24 C 327 37.25483703613281 315.0892639160156 48 300.3966064453125 48 L 26.60338973999023 48 C 11.91074275970459 48 0 37.25483703613281 0 24 C 0 10.74516487121582 11.91074275970459 0 26.60338973999023 0 Z" fill="#ffffff" stroke="#2699fb" stroke-width="2" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_iknsck =
    '<svg viewBox="225.0 588.0 167.0 37.7" ><path transform="translate(225.0, 588.0)" d="M 0 0 L 167.02587890625 0 L 167.02587890625 37.6683349609375 L 0 37.6683349609375 L 0 0 Z" fill="#ffffff" stroke="#bce0fd" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_pkfj6b =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path transform="matrix(-1.0, 0.0, 0.0, -1.0, 16.0, 16.0)" d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_y73tjv =
    '<svg viewBox="0.0 0.0 375.0 68.0" ><path transform="translate(-4907.0, -1089.0)" d="M 4907.00048828125 1156.999633789063 L 4907.00048828125 1108.999389648438 L 5282.00048828125 1108.999389648438 L 5282.00048828125 1156.999633789063 L 4907.00048828125 1156.999633789063 Z M 4907.00048828125 1108.999389648438 L 4907.00048828125 1088.999877929688 L 5282.00048828125 1088.999877929688 L 5282.00048828125 1108.999389648438 L 4907.00048828125 1108.999389648438 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
