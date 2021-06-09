import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'Login4.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Login5 extends StatefulWidget {
  Login5({
    Key key,
  }) : super(key: key);

  Login5_state createState() => Login5_state();
}

class Login5_state extends State<Login5> {
  PickedFile _imageFile;
  final ImagePicker _picker = ImagePicker();
  final yeshiva = TextEditingController();
  String yeshiva_str = "";
  final details = TextEditingController();
  String details_str = "";
  String selectedTopic;
  List<DropdownMenuItem<String>> topicsDrop = [];
  List<String> topics = [
    "תורה",
    "נ״ך",
    "תלמוד בבלי",
    "תלמוד ירושלמי",
    " הלכה",
    " מחשבה"
  ];
  void loadTopicsData() {
    topicsDrop = [];
    topicsDrop = topics
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 667),
        orientation: Orientation.portrait);
    return Scaffold(
      backgroundColor: const Color(0xfff1f9ff),
      body: Stack(
        children: <Widget>[
          Transform.translate(
            offset: Offset(161.w, 576.h),
            child:
                // Adobe XD layer: 'points' (group)
                SizedBox(
              width: 54.w,
              height: 6.h,
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.w, 0.h, 6.w, 6.h),
                    size: Size(54.w, 6.h),
                    pinLeft: true,
                    pinTop: true,
                    pinBottom: true,
                    fixedWidth: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(9999.w, 9999.h)),
                        color: const Color(0xffbce0fd),
                      ),
                    ),
                  ),
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(16.w, 0.h, 6.w, 6.h),
                    size: Size(54.w, 6.h),
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
                    bounds: Rect.fromLTWH(32.w, 0.h, 6.w, 6.h),
                    size: Size(54.w, 6.h),
                    pinTop: true,
                    pinBottom: true,
                    fixedWidth: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(9999.w, 9999.h)),
                        color: const Color(0xffbce0fd),
                      ),
                    ),
                  ),
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(48.w, 0.h, 6.w, 6.h),
                    size: Size(54.w, 6.h),
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    fixedWidth: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(9999.w, 9999.h)),
                        color: const Color(0xff2699fb),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(24.w, 484.h),
            child:
                // Adobe XD layer: 'Continue' (group)
                SizedBox(
              width: 327.w,
              height: 48.h,
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.w, 0.h, 327.w, 48.h),
                    size: Size(327.w, 48.h),
                    pinLeft: true,
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    child: SvgPicture.string(
                      _svg_tmar9d,
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(122.1.w, 15.h, 150.w, 16.h),
                    size: Size(400.w, 48.h),
                    fixedWidth: true,
                    fixedHeight: true,
                    child: Text(
                      'מצא לי חברותא',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16.sp,
                        color: const Color(0xff2699fb),
                        height: 0.8571428571428571.h,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(24.w, 340.h),
            child:
                // Adobe XD layer: 'details' (group)
                SizedBox(
              width: 327.w,
              height: 112.h,
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.w, 0.h, 327.w, 112.h),
                    size: Size(327.w, 112.h),
                    pinLeft: true,
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.w),
                          color: const Color(0xffffffff),
                          border: Border.all(
                              width: 1.w, color: const Color(0xffbce0fd)),
                        ),
                        child: TextField(
                            textAlign: TextAlign.center,
                            controller: details,
                            decoration: InputDecoration(
                                hintText: "ספר לנו על עצמך",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none),
                            onChanged: (String text) {
                              details_str = details.text;
                            })),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(183.8.w, 270.3.h),
            child:
                // Adobe XD layer: 'status' (group)
                SizedBox(
              width: 167.w,
              height: 38.h,
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.w, 0.h, 167.w, 37.7.h),
                    size: Size(167.w, 37.7.h),
                    pinLeft: true,
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton(
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.blue,
                          elevation: 1,
                          value: selectedTopic,
                          style: const TextStyle(color: Colors.blue),
                          hint: Text("סטטוס משפחתי"),
                          items: topicsDrop,
                          onChanged: (value) {
                            loadTopicsData();
                            setState(() {
                              selectedTopic = value;
                            });
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(24.w, 200.h),
            child:
                // Adobe XD layer: 'yeshiva' (group)
                SizedBox(
              width: 327.w,
              height: 48.h,
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.w, 0.h, 327.w, 48.h),
                    size: Size(327.w, 48.h),
                    pinLeft: true,
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.w),
                          color: const Color(0xffffffff),
                          border: Border.all(
                              width: 1.w, color: const Color(0xffbce0fd)),
                        ),
                        child: TextField(
                            textAlign: TextAlign.center,
                            controller: yeshiva,
                            obscureText: false,
                            decoration: InputDecoration(
                                hintText: "ישיבה/מדרשה",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none),
                            onChanged: (String text) {
                              yeshiva_str = yeshiva.text;
                            })),
                  ),
                ],
              ),
            ),
          ),
          // Adobe XD layer: 'picture' (shape)
          Container(
            width: 900.w,
            height: 270.h,
            child: imageProfile(),
          ),
          // Adobe XD layer: 'Navigation Bar' (group)
          SizedBox(
            width: 375.w,
            height: 68.h,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.w, 0.h, 375.w, 68.h),
                  size: Size(375.w, 68.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child:
                      // Adobe XD layer: 'Merged bar' (shape)
                      SvgPicture.string(
                    _svg_y73tjv,
                    allowDrawingOutsideViewBox: true,
                    fit: BoxFit.fill,
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(16.w, 36.h, 16.w, 16.h),
                  size: Size(375.w, 68.h),
                  pinLeft: true,
                  fixedWidth: true,
                  fixedHeight: true,
                  child:
                      // Adobe XD layer: 'Backward arrow' (group)
                      PageLink(
                    links: [
                      PageLinkInfo(
                        transition: LinkTransition.Fade,
                        ease: Curves.easeOut,
                        duration: 0.3,
                        pageBuilder: () => Login4(),
                      ),
                    ],
                    child: Stack(
                      children: <Widget>[
                        Pinned.fromSize(
                          bounds: Rect.fromLTWH(0.w, 0.h, 16.w, 16.h),
                          size: Size(16.w, 16.h),
                          pinLeft: true,
                          pinRight: true,
                          pinTop: true,
                          pinBottom: true,
                          child: SvgPicture.string(
                            _svg_pkfj6b,
                            allowDrawingOutsideViewBox: true,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(children: <Widget>[
        CircleAvatar(
          radius: 60.0,
          backgroundImage: _imageFile == null
              ? AssetImage("assets/profile.jpg")
              : FileImage(File(_imageFile.path)),
        ),
        Positioned(
          bottom: 20.0,
          right: 10.0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.blueAccent,
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
            "בחר תמונת פרופיל",
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
