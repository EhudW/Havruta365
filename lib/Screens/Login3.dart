import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import './Login2.dart';
import './Login4.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';

class Login3 extends StatefulWidget {
  Login3({
    Key key,
  }) : super(key: key);

  Login3_state createState() => Login3_state();
}

class Login3_state extends State<Login3> {
  final user_name = TextEditingController();
  String user_name_str = "";
  final address = TextEditingController();
  String address_str = "";
  String gender = '';
  DateTime _dateTime;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      width: 375,
      height: 667,
    );
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      backgroundColor: const Color(0xfff1f9ff),
      body: Stack(
        children: <Widget>[
          Pinned.fromSize(
            bounds: Rect.fromLTWH(161.w, 576.h, 54.w, 6.h),
            size: Size(375.w, 667.h),
            pinBottom: true,
            fixedWidth: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'points' (group)
                Stack(
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.w, 9999.h)),
                      color: const Color(0xff2699fb),
                    ),
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
                      color: const Color(0xffbce0fd),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(24.w, 484.h, 327.w, 48.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'Next' (group)
                Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.w, 0.h, 327.w, 48.h),
                  size: Size(327.w, 48.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: Scaffold(
                    body: GestureDetector(
                      onTap: () {
                        // Update user details

                        // go to login4
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login4()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.w),
                          color: const Color(0xff2699fb),
                        ),
                      ),
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(156.w, 16.h, 16.w, 16.h),
                  size: Size(327.w, 48.h),
                  fixedWidth: true,
                  fixedHeight: true,
                  child: PageLink(
                    links: [
                      PageLinkInfo(
                        transition: LinkTransition.SlideLeft,
                        ease: Curves.linear,
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
                            _svg_ru0g9a,
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
          Pinned.fromSize(
            bounds: Rect.fromLTWH(25.w, 239.h, 327.w, 48.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'place' (group)
                Stack(
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
                            width: 1.0, color: const Color(0xffbce0fd)),
                      ),
                      child: TextField(
                          textAlign: TextAlign.center,
                          controller: address,
                          obscureText: false,
                          decoration: InputDecoration(
                              hintText: "כתובת מגורים",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                          onChanged: (String text) {
                            address_str = address.text;
                          })),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(120.w, 311.h, 132.w, 48.h),
            size: Size(375.w, 667.h),
            pinRight: true,
            fixedWidth: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'gender' (group)
                Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(69.w, 18.h, 63.w, 30.h),
                  size: Size(132.w, 48.h),
                  pinRight: true,
                  pinBottom: true,
                  fixedWidth: true,
                  fixedHeight: true,
                  child:
                      // Adobe XD layer: 'Radio button - Sele…' (group)
                      Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(33.w, 10.h, 30.w, 30.h),
                        size: Size(63.w, 30.h),
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        fixedWidth: true,
                        child: Radio(
                            value: "F",
                            groupValue: gender,
                            onChanged: (val) {
                              setState(() {
                                gender = val;
                              });
                            }),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.w, 4.h, 40.w, 40.h),
                        size: Size(63.w, 10.h),
                        child: Text(
                          'אישה',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16.sp,
                            color: const Color(0xff2699fb),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.w, 18.h, 53.w, 30.h),
                  size: Size(132.w, 48.h),
                  pinLeft: true,
                  pinBottom: true,
                  fixedWidth: true,
                  fixedHeight: true,
                  child:
                      // Adobe XD layer: 'Radio button - Empty' (group)
                      Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(23.w, 10.h, 30.w, 30.h),
                        size: Size(53.w, 30.h),
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        fixedWidth: true,
                        child: Radio(
                            value: "M",
                            groupValue: gender,
                            onChanged: (val) {
                              setState(() {
                                gender = val;
                              });
                            }),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.w, 10.h, 40.w, 40.h),
                        size: Size(53.w, 30.h),
                        child: Text(
                          'גבר',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16.sp,
                            color: const Color(0xff2699fb),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(60.w, 390.h, 250.w, 80.h),
            size: Size(375.w, 667.h),
            fixedWidth: true,
            fixedHeight: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('בחר תאריך לידה'),
                  onPressed: () {
                    showDatePicker(
                            context: context,
                            initialDate: _dateTime = DateTime.now(),
                            firstDate: DateTime(1960),
                            lastDate: DateTime(2022))
                        .then((date) {
                      setState(() {
                        _dateTime = date;
                      });
                    });
                  },
                ),
                Text(_dateTime == null
                    ? 'לא הוכנס תאריך'
                    : new DateFormat("yyyy-MM-dd").format(_dateTime))
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(24.w, 152.h, 327.w, 48.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'user name' (group)
                Stack(
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
                            width: 1.0, color: const Color(0xffbce0fd)),
                      ),
                      child: TextField(
                          textAlign: TextAlign.center,
                          controller: user_name,
                          obscureText: false,
                          decoration: InputDecoration(
                              hintText: "שם משתמש",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                          onChanged: (String text) {
                            user_name_str = user_name.text;
                          })),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.w, 0.h, 375.w, 68.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'Navigation Bar' (group)
                Stack(
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
                  bounds: Rect.fromLTWH(135.w, 31.h, 106.w, 22.h),
                  size: Size(375.w, 68.h),
                  fixedWidth: true,
                  fixedHeight: true,
                  child: Text(
                    'פרטים נוספים',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 20.sp,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.center,
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
                        pageBuilder: () => Login2(),
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
}

const String _svg_ru0g9a =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path  d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_krrenf =
    '<svg viewBox="48.0 152.0 327.0 48.0" ><path transform="translate(48.0, 152.0)" d="M 24 0 L 303 0 C 316.2548217773438 0 327 10.74516487121582 327 24 C 327 37.25483703613281 316.2548217773438 48 303 48 L 24 48 C 10.74516487121582 48 0 37.25483703613281 0 24 C 0 10.74516487121582 10.74516487121582 0 24 0 Z" fill="#ffffff" stroke="#bce0fd" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_7zbdqc =
    '<svg viewBox="0.0 0.0 9.4 6.1" ><path transform="translate(-2.0, -2.0)" d="M 6.699999809265137 8.100000381469727 L 2 3.400000095367432 L 3.400000095367432 2 L 6.699999809265137 5.300000190734863 L 10 2 L 11.39999961853027 3.400000095367432 L 6.699999809265137 8.100000381469727 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_al74a7 =
    '<svg viewBox="219.0 590.0 117.0 50.0" ><path transform="translate(219.0, 590.0)" d="M 0 0 L 117 0 L 117 50 L 0 50 L 0 0 Z" fill="#ffffff" stroke="#bce0fd" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_y73tjv =
    '<svg viewBox="0.0 0.0 375.0 68.0" ><path transform="translate(-4907.0, -1089.0)" d="M 4907.00048828125 1156.999633789063 L 4907.00048828125 1108.999389648438 L 5282.00048828125 1108.999389648438 L 5282.00048828125 1156.999633789063 L 4907.00048828125 1156.999633789063 Z M 4907.00048828125 1108.999389648438 L 4907.00048828125 1088.999877929688 L 5282.00048828125 1088.999877929688 L 5282.00048828125 1108.999389648438 L 4907.00048828125 1108.999389648438 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_pkfj6b =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path transform="matrix(-1.0, 0.0, 0.0, -1.0, 16.0, 16.0)" d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
