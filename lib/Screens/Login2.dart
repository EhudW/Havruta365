import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Globals.dart';
import './Login1.dart';
import './Login3.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Login2 extends StatelessWidget {
  final name = TextEditingController();
  String name_str = "";
  final mail = TextEditingController();
  String mail_str = "";
  final password = TextEditingController();
  String password_str = "";
  final password_con = TextEditingController();
  String password_con_str = "";
  Login2({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 667),
        orientation: Orientation.portrait);
    return Scaffold(

      resizeToAvoidBottomInset: false,

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
                      bounds: Rect.fromLTWH(0.0, 0.0, 54.w, 6.h),
                      size: Size(54.w, 6.h),
                      pinLeft: true,
                      pinRight: true,
                      pinTop: true,
                      pinBottom: true,
                      child:
                      // Adobe XD layer: 'Pagination' (group)
                      Stack(
                        children: <Widget>[
                          Pinned.fromSize(
                            bounds: Rect.fromLTWH(0.0, 0.0, 6.w, 6.h),
                            size: Size(54.w, 6.h),
                            pinLeft: true,
                            pinTop: true,
                            pinBottom: true,
                            fixedWidth: true,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(9999.w, 9999.h)),
                                color: const Color(0xff2699fb),
                              ),
                            ),
                          ),
                          Pinned.fromSize(
                            bounds: Rect.fromLTWH(16.0, 0.0, 6.w, 6.h),
                            size: Size(54.w, 6.h),
                            pinTop: true,
                            pinBottom: true,
                            fixedWidth: true,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(9999.w, 9999.h)),
                                color: const Color(0xffbce0fd),
                              ),
                            ),
                          ),
                          Pinned.fromSize(
                            bounds: Rect.fromLTWH(32.0, 0.0, 6.w, 6.h),
                            size: Size(54.w, 6.h),
                            pinTop: true,
                            pinBottom: true,
                            fixedWidth: true,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(9999.w, 9999.h)),
                                color: const Color(0xffbce0fd),
                              ),
                            ),
                          ),
                          Pinned.fromSize(
                            bounds: Rect.fromLTWH(48.0, 0.0, 6.w, 6.h),
                            size: Size(54.w, 6.h),
                            pinRight: true,
                            pinTop: true,
                            pinBottom: true,
                            fixedWidth: true,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(9999.w, 9999.h)),
                                color: const Color(0xffbce0fd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Adobe XD layer: 'Navigation Bar' (group)
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
                    // Adobe XD layer: 'Merged bar' (shape)
                    SvgPicture.string(
                      _svg_y73tjv,
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(130.w, 30.h, 120.w, 22.h),
                    size: Size(375.w, 68.h),
                    fixedWidth: true,
                    fixedHeight: true,
                    child: Text(
                      'משתמש חדש',
                      style: TextStyle(
                        fontFamily: 'Bauhaus 93',
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
                          transition: LinkTransition.SlideRight,
                          ease: Curves.easeOut,
                          duration: 0.3,
                          pageBuilder: () => Login1(),
                        ),
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
                      child: Scaffold(
                        body: GestureDetector(
                          onTap: () async{
                            if (password_con_str.isEmpty || password_con_str == null
                            || password_str.isEmpty || password_str == null ||
                                mail_str.isEmpty || mail_str == null ||
                                name_str.isEmpty || name_str == null){
                              Flushbar(
                                title: 'שגיאה בהרשמה',
                                messageText: Text(
                                  'ודא שמילאת את כל השדות',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.lightBlue,
                                  fontSize: 20)
                                ),
                                duration: Duration(seconds: 3),
                              )..show(context);
                              return;
                            }
                            // Check if the passwords are equals
                            if (password_str != password_con_str){
                              Flushbar(
                                title: 'שגיאה בהרשמה',
                                messageText: Text(
                                  'סיסמאות לא תואמות',
                                  textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.lightBlue,
                                        fontSize: 20)
                                ),
                                duration: Duration(seconds: 3),
                              )..show(context);
                              return;
                            }
                            bool userExist = await Globals.db.isUserExist(mail_str);
                            if (userExist){
                              Flushbar(
                                title: 'שגיאה בהרשמה',
                                messageText: Text(
                                  'קיים חשבון עבור מייל זה',
                                  textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.lightBlue,
                                        fontSize: 20)
                                ),
                                duration: Duration(seconds: 3),
                              )..show(context);
                              return;
                            }
                            User user = new User();
                            Globals.currentUser = user;
                            user.email = mail_str;
                            user.name = name_str;
                            user.password = password_str;
                            var res = Globals.db.insertNewUser(user);
                            print("Registration Succeeded");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login3()),
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
                      child:
                      PageLink(
                        links: [
                          PageLinkInfo(
                          transition: LinkTransition.SlideLeft,
                          ease: Curves.linear,
                          duration: 0.3,
                          ),
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
            ),
            Transform.translate(
              offset: Offset(24.w, 384.h),
              child:
              // Adobe XD layer: 'password confirm' (group)
              SizedBox(
                width: 327.w,
                height: 65.h,
                child: Stack(
                  children: <Widget>[
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(0.0, 17.h, 327.w, 48.h),
                      size: Size(327.w, 65.h),
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
                              controller: password_con,
                              obscureText: true,
                              showCursor: true,
                              decoration: InputDecoration(
                                  hintText: "אישור סיסמא",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none
                              ),
                              onChanged: (String text)
                              {
                                password_con_str = password_con.text;
                              })
                      ),
                    ),
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(290.w, 0.0, 51.w, 11.h),
                      size: Size(327.w, 65.h),
                      pinRight: true,
                      pinTop: true,
                      fixedWidth: true,
                      fixedHeight: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24.w, vertical:302.h),
              child:
              // Adobe XD layer: 'password' (group)
              SizedBox(
                width: 327.w,
                height: 63.h,
                child: Stack(
                  children: <Widget>[
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(0.0, 16.h, 327.w, 48.h),
                      size: Size(327.w, 63.h),
                      pinLeft: true,
                      pinRight: true,
                      pinTop: true,
                      pinBottom: true,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.w),
                            color: const Color(0xffffffff),
                            border: Border.all(
                                width: 1.0.w, color: const Color(0xffbce0fd)),
                          ),
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: password,
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintText: "סיסמא חדשה",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none
                              ),
                              onChanged: (String text)
                              {
                                password_str = password.text;
                              })
                      ),
                    ),
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(290.w, 0.0, 26.w, 11.h),
                      size: Size(327.w, 64.h),
                      pinRight: true,
                      pinTop: true,
                      fixedWidth: true,
                      fixedHeight: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24.w, vertical:220.h),
              child:
              // Adobe XD layer: 'mail' (group)
              SizedBox(
                width: 327.w,
                height: 63.h,
                child: Stack(
                  children: <Widget>[
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(0.0, 15.h, 327.w, 48.h),
                      size: Size(327.w, 63.h),
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
                              controller: mail,
                              obscureText: false,
                              decoration: InputDecoration(
                                  hintText: "כתובת המייל",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none
                              ),
                              onChanged: (String text)
                              {
                                mail_str = mail.text;
                              })
                      ),
                    ),
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(284.w, 0.0, 24.w, 11.h),
                      size: Size(327.w, 63.h),
                      pinRight: true,
                      pinTop: true,
                      fixedWidth: true,
                      fixedHeight: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24.w, vertical:135.h),
              child:
              // Adobe XD layer: 'name' (group)
              SizedBox(
                width: 327.w,
                height: 65.h,
                child: Stack(
                  children: <Widget>[
                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(0.0, 17.h, 327.w, 48.h),
                      size: Size(327.w, 65.h),
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
                              controller: name,
                              obscureText: false,
                              decoration: InputDecoration(
                                  hintText: "שם פרטי ושם משפחה",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none
                              ),
                              onChanged: (String text)
                              {
                                name_str = name.text;
                              })
                      ),
                    ),

                    Pinned.fromSize(
                      bounds: Rect.fromLTWH(284.w, 0.0, 32.w, 11.h),
                      size: Size(327.w, 65.h),
                      pinRight: true,
                      pinTop: true,
                      fixedWidth: true,
                      fixedHeight: true,
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );

  }

}

const String _svg_y73tjv =
    '<svg viewBox="0.0 0.0 375.0 68.0" ><path transform="translate(-4907.0, -1089.0)" d="M 4907.00048828125 1156.999633789063 L 4907.00048828125 1108.999389648438 L 5282.00048828125 1108.999389648438 L 5282.00048828125 1156.999633789063 L 4907.00048828125 1156.999633789063 Z M 4907.00048828125 1108.999389648438 L 4907.00048828125 1088.999877929688 L 5282.00048828125 1088.999877929688 L 5282.00048828125 1108.999389648438 L 4907.00048828125 1108.999389648438 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_pkfj6b =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path transform="matrix(-1.0, 0.0, 0.0, -1.0, 16.0, 16.0)" d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_ru0g9a =
    '<svg viewBox="0.0 0.0 16.0 16.0" ><path  d="M 8 0 L 6.545454978942871 1.454545497894287 L 12.05194854736328 6.961039066314697 L 0 6.961039066314697 L 0 9.038961410522461 L 12.05194854736328 9.038961410522461 L 6.545454978942871 14.54545497894287 L 8 16 L 16 8 L 8 0 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
