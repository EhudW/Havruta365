import 'package:flutter/material.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:havruta/DataBase_auth/User.dart';
import 'package:havruta/DataBase_auth/mongo.dart';
import 'package:havruta/Screens/Login3.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_screenutil/screenutil.dart';

class Login4 extends StatefulWidget {
  @override
  _Login4CreateState createState() => _Login4CreateState();
}

class _Login4CreateState extends State<Login4> {
  List<DropdownMenuItem<String>> topicsDrop = [];
  List<String> topics = [
    "תורה",
    "נ״ך",
    "תלמוד בבלי",
    "תלמוד ירושלמי",
    " הלכה",
    " מחשבה"
  ];
  String selectedTopic;
  String selectedBook;
  List<DropdownMenuItem<String>> booksDrop = [];
  List<String> books = [
    "בראשית",
    "שמואל א",
     "ירמיהו",
    "so done with this"
  ];


  /// Function to load the data for the dropdown list
  void loadTopicsData() {
    topicsDrop = [];
    topicsDrop = topics
        .map((val) => DropdownMenuItem<String>(
              child: Text(val),
              value: val,
            ))
        .toList();
  }

  void loadBooksData() {
    booksDrop = [];
    booksDrop = books
        .map((val) => DropdownMenuItem<String>(
      child: Text(val),
      value: val,
    ))
        .toList();
  }

  final name = TextEditingController();
  String name_str = "";

  //final mail = TextEditingController();
  String mail_str = "";
  final password = TextEditingController();
  String password_str = "";
  final password_con = TextEditingController();
  String password_con_str = "";
  String _value1 = "";

  //Login4({Key key,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    loadTopicsData();
    ScreenUtil.init(
      context,
      width: 375,
      height: 667,
    );
    return Scaffold(
      backgroundColor: const Color(0xfff1f9ff),
      body: Stack(children: <Widget>[
        //==============NAVIGATION BAR===================
        SizedBox(
          width: 375.w,
          height: 68.h,
          child: Stack(
            children: <Widget>[
              Pinned.fromSize(
                bounds: Rect.fromLTWH(0.0, 0.0, 375.w, 68.h),
                size: Size(375.w, 68.h),
                pinLeft: true,
                pinRight: true,
                pinTop: true,
                pinBottom: true,
                child:
                    //==============MERGED BAR===================
                    SvgPicture.string(
                  _svg_y73tjv,
                  allowDrawingOutsideViewBox: true,
                  fit: BoxFit.fill,
                ),
              ),
              //==============TOP BAR===================
              Pinned.fromSize(
                bounds: Rect.fromLTWH(130.w, 30.h, 120.w, 22.h),
                size: Size(363.w, 68.h),
                fixedWidth: false,
                fixedHeight: true,
                child: Text(
                  'מה תרצו ללמוד?',
                  style: TextStyle(
                    fontFamily: 'Bauhaus 93',
                    fontSize: 18.0.sp,
                    color: const Color(0xffffffff),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Pinned.fromSize(
                bounds: Rect.fromLTWH(16.w, 36.h, 16.w, 16.h),
                size: Size(400.w, 68.h),
                pinLeft: true,
                fixedWidth: true,
                fixedHeight: true,
                child:
                    // Adobe XD layer: 'Backward arrow' (group)
                    PageLink(
                  links: [
                    PageLinkInfo(
                      transition: LinkTransition.SlideRight,
                      ease: Curves.easeOut,
                      duration: 0.3,
                      pageBuilder: () => Login3(),
                    ),
                    // PageLinkInfo(
                    //   transition: LinkTransition.SlideLeft,
                    //   ease: Curves.easeOut,
                    //   duration: 0.1,
                    //   pageBuilder: () => Login3(),
                    // ),
                  ],
                  child: Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 16.w, 16.h),
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
        //==============BOTTOM ARROW=================
        Transform.translate(
          offset: Offset(24.w, 484.h),
          child:
              // Adobe XD layer: 'Next' (group)
              SizedBox(
            width: 327.w,
            height: 48.h,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 327.w, 48.h),
                  size: Size(327.w, 48.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: GestureDetector(
                    onTap: () async {
                      Mongo mongo = new Mongo();
                      User user = new User();
                      user.email = mail_str;
                      user.name = name_str;
                      user.password = password_str;
                      if (password_str != password_con_str) {
                        //final snackBar = new SnackBar(content: new Text("Password not match"));
                        //Scaffold.of(context).showSnackBar(snackBar);
                        print("Password not match");
                        return;
                      }
                      String res = await mongo.insertNewUser(user);
                      print(res);
                      if (res != null) {
                        // final snackBar = new SnackBar(content: new Text(res.toString()));
                        // Scaffold.of(context).showSnackBar(snackBar);
                      } else {
                        // connect and go to homePage
                        // Navigator.of(context).pushNamed('/Login3');
                        print("Connection Succeeded");
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.w),
                        color: const Color(0xff2699fb),
                      ),
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(156.w, 16.h, 16.w, 16.h),
                  size: Size(327.w, 48.h),
                  fixedWidth: true,
                  fixedHeight: true,
                  child: Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 16.w, 16.h),
                        size: Size(16.w, 16.h),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_ru0g9a,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        //FIRST DROPDOWN BOX
        Transform.translate(
          offset: Offset(5.w, -10.h),
          child: Center(
            child: Column(
              children: <Widget>[
                //==============FIRST DROPDOWN LIST=================
                DropdownButtonHideUnderline(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(20, 150, 20, 100),
                        child: Stack(
                          children: [
                            Container(
                              height: 40,
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: Colors.blue,
                                    elevation: 1,
                                    value: selectedTopic,
                                    style: const TextStyle(color: Colors.blue),
                                    hint: Text("בחרו תחום"),
                                    items: topicsDrop,
                                    onChanged: (value) {
                                      loadBooksData();
                                      selectedTopic = value;
                                      setState(() {});
                                    }),

                              ),
                            ),
                          ],
                        )
                    )
                ),
                DropdownButtonHideUnderline(
                    child: Container(

                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Stack(
                          children: [
                            Container(
                              height: 40,
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: Colors.blue,
                                    elevation: 0,
                                    value: selectedBook,
                                    style: const TextStyle(color: Colors.blue),
                                    hint: Text("בחרו ספר"),
                                    items: booksDrop,
                                    onChanged: (value) {
                                      //loadBooksData();
                                      selectedBook = value;
                                      setState(() {});
                                    }
                              ),
                              ),
                            ),
                          ],
                        )
                    )
                )
              ],
            ),
          ),
        ),

        Transform.translate(
          offset: Offset(161.0, 576.0),
          child:
              // Adobe XD layer: 'points' (group)
              SizedBox(
            width: 54.0,
            height: 6.0,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 6.0, 6.0),
                  size: Size(54.0, 6.0),
                  pinLeft: true,
                  pinTop: true,
                  pinBottom: true,
                  fixedWidth: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      color: const Color(0xffbce0fd),
                    ),
                  ),
                ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      color: const Color(0xff2699fb),
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(48.0, 0.0, 6.0, 6.0),
                  size: Size(54.0, 6.0),
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  fixedWidth: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      color: const Color(0xffbce0fd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(325.0, 425.0),
          child:
              // Adobe XD layer: 'plus' (group)
              SizedBox(
            width: 40.0,
            height: 40.0,
            child: Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 40.0, 40.0),
                  size: Size(40.0, 40.0),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      color: const Color(0xff2699fb),
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(12.0, 12.0, 16.0, 16.0),
                  size: Size(40.0, 40.0),
                  fixedWidth: true,
                  fixedHeight: true,
                  child:
                      // Adobe XD layer: '+' (group)
                      Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 16.0, 16.0),
                        size: Size(16.0, 16.0),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_spzoa6,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

const String _svg_pkfj6b =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path transform="matrix(-1.0, 0.0, 0.0, -1.0, 16.0, 16.0)" d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_y73tjv =
    '<svg viewBox="0.0 0.0 375.0 68.0" ><path transform="translate(-4907.0, -1089.0)" d="M 4907.00048828125 1156.999633789063 L 4907.00048828125 1108.999389648438 L 5282.00048828125 1108.999389648438 L 5282.00048828125 1156.999633789063 L 4907.00048828125 1156.999633789063 Z M 4907.00048828125 1108.999389648438 L 4907.00048828125 1088.999877929688 L 5282.00048828125 1088.999877929688 L 5282.00048828125 1108.999389648438 L 4907.00048828125 1108.999389648438 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_ru0g9a =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path  d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_h36wzl =
    '<svg viewBox="16.0 0.0 6.0 6.0" ><path transform="translate(16.0, 0.0)" d="M 3 0 C 4.656854152679443 0 6 1.343145847320557 6 3 C 6 4.656854152679443 4.656854152679443 6 3 6 C 1.343145847320557 6 0 4.656854152679443 0 3 C 0 1.343145847320557 1.343145847320557 0 3 0 Z" fill="#bce0fd" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_spzoa6 =
    '<svg viewBox="301.0 111.0 16.0 16.0" ><path transform="translate(4921.0, 111.0)" d="M -4613.00048828125 15.99948692321777 L -4613.00048828125 8.999783515930176 L -4620 8.999783515930176 L -4620 6.999702930450439 L -4613.00048828125 6.999702930450439 L -4613.00048828125 0 L -4611 0 L -4611 6.999702930450439 L -4604.00048828125 6.999702930450439 L -4604.00048828125 8.999783515930176 L -4611 8.999783515930176 L -4611 15.99948692321777 L -4613.00048828125 15.99948692321777 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';