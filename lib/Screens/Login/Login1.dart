import 'package:adobe_xd/pinned.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/google_sign_in.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import './Login2.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Login1 extends StatelessWidget {
  final mail = TextEditingController();
  String mail_str = "";
  final password = TextEditingController();
  String password_str = "";

  Login1({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 667),
        orientation: Orientation.portrait);
    ScreenScaler scaler = new ScreenScaler();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          Pinned.fromSize(
            bounds: Rect.fromLTWH(40.w, 378.h, 295.w, 48.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'old user' (group)
            Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 295.w, 48.h),
                  size: Size(295.w, 48.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: GestureDetector(
                    onTap: () async {
                      var res = await Globals.db.checkNewUser(mail_str);
                      print(res);
                      // User not exist
                      if (res == 'User not exist!') {
                        Flushbar(
                          title: 'שגיאה בהתחברות',
                          message: 'משתמש לא קיים',
                          duration: Duration(seconds: 3),
                        )..show(context);
                      } else {
                        // Update current user
                        Globals.currentUser = res;
                        // Go to HomePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.w),
                        color: Colors.teal[400],
                      ),
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(122.w, 11.h, 52.w, 27.h),
                  size: Size(295.w, 48.h),
                  fixedWidth: true,
                  fixedHeight: true,
                  child: Text(
                    'כניסה',
                    style: TextStyle(
                      fontFamily: 'Bauhaus 93',
                      fontSize: 18.sp,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 0.0, 375.w, 172.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'Header' (group)
            Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 375.w, 172.h),
                  size: Size(375.w, 172.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color:Colors.teal[400],
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(87.w, 82.h, 202.w, 40.h),
                  size: Size(375.w, 172.h),
                  fixedWidth: true,
                  fixedHeight: true,
                  child: Text(
                    'פרויקט חברותא',
                    style: TextStyle(
                      fontFamily: 'Bauhaus 93',
                      fontSize: 30.sp,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(176.w, 454.h, 24.w, 4.h),
            size: Size(375.w, 667.h),
            fixedWidth: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'Divider' (shape)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.w),
                color: Colors.teal[200],
              ),
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(57.w, 244.h, 263.w, 34.h),
            size: Size(375.w, 667.h),
            pinRight: true,
            fixedWidth: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'Name' (group)
            Stack(
              children: <Widget>[
                TextField(
                    textAlign: TextAlign.center,
                    controller: mail,
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: "כתובת המייל",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (String text) {
                      mail_str = mail.text;
                    }),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.w, 33.h, 263.w, 1.h),
                  size: Size(263.w, 34.h),
                  pinLeft: true,
                  pinRight: true,
                  pinBottom: true,
                  fixedHeight: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[200],
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(247.w, 0.h, 16.w, 16.h),
                  size: Size(263.w, 34.h),
                  pinRight: true,
                  pinTop: true,
                  fixedWidth: true,
                  fixedHeight: true,
                    child:Icon(FontAwesomeIcons.user,
                        size: 20,
                        color: Colors.red)
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(58.w, 311.h, 262.w, 34.h),
            size: Size(375.w, 667.h),
            pinRight: true,
            fixedWidth: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'Password' (group)
            Stack(
              children: <Widget>[
                TextField(
                    textAlign: TextAlign.center,
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "סיסמא",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (String text) {
                      password_str = password.text;
                    }),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 33.h, 260.w, 1.h),
                  size: Size(262.w, 34.h),
                  pinLeft: true,
                  pinRight: true,
                  pinBottom: true,
                  fixedHeight: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[200],
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(246.w, 0.0, 16.w, 16.h),
                  size: Size(262.w, 34.h),
                  pinRight: true,
                  pinTop: true,
                  fixedWidth: true,
                  fixedHeight: true,
                  child:
                  // Adobe XD layer: 'Lock' (group)
                  Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 16.w, 16.h),
                        size: Size(16.w, 16.h),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: Container(
                          decoration: BoxDecoration(),
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(1.w, 0.0, 14.w, 16.h),
                        size: Size(16.w, 16.h),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                          child:Icon(FontAwesomeIcons.key,
                              size: 20,
                              color: Colors.red)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(40.w, 483.h, 295.w, 48.h),
            size: Size(375.w, 667.h),
            pinLeft: true,
            pinRight: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'new user' (group)
            PageLink(
              links: [
                PageLinkInfo(
                  transition: LinkTransition.SlideLeft,
                  ease: Curves.linear,
                  duration: 0.3,
                  pageBuilder: () => Login2(),
                ),
              ],
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.0, 0.0, 295.w, 48.h),
                    size: Size(295.w, 48.h),
                    pinLeft: true,
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    child: SvgPicture.string(
                      _svg_3jk2us,
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(90.w, 8.h, 116.w, 27.h),
                    size: Size(295.w, 48.h),
                    fixedWidth: true,
                    fixedHeight: true,
                    child: Text(
                      'משתמש חדש',
                      style: TextStyle(
                        fontFamily: 'Bauhaus 93',
                        fontSize: 18.sp,
                        color: Colors.teal[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(195.w, 545.h, 56.w, 56.h),
            size: Size(375.w, 667.h),
            pinBottom: true,
            fixedWidth: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'g+' (group)
            Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 56.w, 56.h),
                  size: Size(56.w, 56.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: GestureDetector(
                    onTap: () {
                      GoogleLogIn g = new GoogleLogIn();
                      g.login();
                      Navigator.of(context).pushNamed('/homeScreen');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.elliptical(9999.w, 9999.h)),
                        border: Border.all(
                            width: 1.0, color:  Colors.teal[200]),
                      ),
                    ),
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(20.w, 20.h, 16.w, 16.h),
                  size: Size(56.w, 56.h),
                  fixedWidth: true,
                  fixedHeight: true,
                  child:
                  // Adobe XD layer: 'g+' (group)
                  Stack(
                    children: <Widget>[
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 16.w, 16.h),
                        size: Size(16.w, 16.h),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: Container(
                          decoration: BoxDecoration(),
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 3.h, 16.w, 10.2.h),
                        size: Size(16.w, 16.h),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_lnfrs0,
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
          Pinned.fromSize(
            bounds: Rect.fromLTWH(125.w, 545.h, 56.w, 56.h),
            size: Size(375.w, 667.h),
            pinBottom: true,
            fixedWidth: true,
            fixedHeight: true,
            child:
            // Adobe XD layer: 'facebook' (group)
            Stack(
              children: <Widget>[
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(20.w, 20.h, 16.w, 16.h),
                  size: Size(56.w, 56.h),
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
                        child: Container(
                          decoration: BoxDecoration(),
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(4.w, 0.0, 8.4.w, 16.h),
                        size: Size(16.w, 16.h),
                        pinTop: true,
                        pinBottom: true,
                        fixedWidth: true,
                        child: SvgPicture.string(
                          _svg_n3j0c2,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
                Pinned.fromSize(
                  bounds: Rect.fromLTWH(0.0, 0.0, 56.w, 56.h),
                  size: Size(56.w, 56.h),
                  pinLeft: true,
                  pinRight: true,
                  pinTop: true,
                  pinBottom: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.elliptical(9999.w, 9999.h)),
                      border: Border.all(
                          width: 1.0, color: Colors.teal[200]),
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

const String _svg_sjnak0 =
    '<svg viewBox="351.0 136.0 16.0 16.0" ><path transform="translate(6471.0, 16226.0)" d="M -6120 -16073.9990234375 L -6120 -16075.998046875 C -6120 -16078.19921875 -6116.3984375 -16080 -6112.0009765625 -16080 C -6107.59912109375 -16080 -6104.00146484375 -16078.19921875 -6104.00146484375 -16075.998046875 L -6104.00146484375 -16073.9990234375 L -6120 -16073.9990234375 Z M -6115.99853515625 -16086 C -6115.99853515625 -16088.208984375 -6114.20947265625 -16089.998046875 -6112.0009765625 -16089.998046875 C -6109.7919921875 -16089.998046875 -6107.9990234375 -16088.208984375 -6107.9990234375 -16086 C -6107.9990234375 -16083.7919921875 -6109.7919921875 -16081.9990234375 -6112.0009765625 -16081.9990234375 C -6114.20947265625 -16081.9990234375 -6115.99853515625 -16083.7919921875 -6115.99853515625 -16086 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_fy8d8n =
    '<svg viewBox="1.0 0.0 14.0 16.0" ><path transform="translate(1.0, 0.0)" d="M 7 8 C 8.100000381469727 8 9 8.899999618530273 9 10 C 9 11.10000038146973 8.100000381469727 12 7 12 C 5.899999618530273 12 5 11.10000038146973 5 10 C 5 8.899999618530273 5.900000095367432 8 7 8 Z M 7 2 C 5.900000095367432 2 5 2.900000095367432 5 4 L 9 4 C 9 2.900000095367432 8.100000381469727 2 7 2 Z M 12 16 L 2 16 C 0.8999999761581421 16 0 15.10000038146973 0 14 L 0 6 C 0 4.900000095367432 0.8999999761581421 4 2 4 L 3 4 C 3 1.799999952316284 4.800000190734863 0 7 0 C 9.199999809265137 0 11 1.799999952316284 11 4 L 12 4 C 13.10000038146973 4 14 4.900000095367432 14 6 L 14 14 C 14 15.10000038146973 13.10000038146973 16 12 16 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_3jk2us =
    '<svg viewBox="40.0 514.0 295.0 48.0" ><path transform="translate(40.0, 514.0)" d="M 24 0 L 271 0 C 284.2548217773438 0 295 10.74516487121582 295 24 C 295 37.25483703613281 284.2548217773438 48 271 48 L 24 48 C 10.74516487121582 48 0 37.25483703613281 0 24 C 0 10.74516487121582 10.74516487121582 0 24 0 Z" fill="#ffffff" stroke="#2699fb" stroke-width="2" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_lnfrs0 =
    '<svg viewBox="0.0 3.0 16.0 10.2" ><path transform="translate(0.0, 3.0)" d="M 16 4.400000095367432 L 16 5.900000095367432 L 14.5 5.900000095367432 L 14.5 7.400000095367432 L 13 7.400000095367432 L 13 5.800000190734863 L 11.5 5.800000190734863 L 11.5 4.400000095367432 L 13 4.400000095367432 L 13 2.900000095367432 L 14.5 2.900000095367432 L 14.5 4.400000095367432 L 16 4.400000095367432 Z M 5.099999904632568 4.400000095367432 L 9.899999618530273 4.400000095367432 C 9.899999618530273 4.700000286102295 10 4.900000095367432 10 5.200000286102295 C 10 8.100000381469727 8.100000381469727 10.20000076293945 5.099999904632568 10.20000076293945 C 2.299999952316284 10.19999980926514 0 7.900000095367432 0 5.099999904632568 C 0 2.299999952316284 2.299999952316284 0 5.099999904632568 0 C 6.5 0 7.599999904632568 0.5 8.5 1.299999952316284 L 7.099999904632568 2.700000047683716 C 6.699999809265137 2.299999952316284 6.099999904632568 1.900000095367432 5.099999904632568 1.900000095367432 C 3.399999856948853 1.900000095367432 1.899999856948853 3.300000190734863 1.899999856948853 5.100000381469727 C 1.899999856948853 6.90000057220459 3.299999713897705 8.300000190734863 5.099999904632568 8.300000190734863 C 7.099999904632568 8.300000190734863 7.899999618530273 6.900000095367432 8 6.100000381469727 L 5.099999904632568 6.100000381469727 L 5.099999904632568 4.400000095367432 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_n3j0c2 =
    '<svg viewBox="4.0 0.0 8.4 16.0" ><path transform="translate(-76.0, 0.0)" d="M 85.42222595214844 16 L 85.42222595214844 8.711111068725586 L 87.91111755371094 8.711111068725586 L 88.26667785644531 5.8666672706604 L 85.42222595214844 5.8666672706604 L 85.42222595214844 4.088889122009277 C 85.42222595214844 3.288889169692993 85.68890380859375 2.666667222976685 86.84445190429688 2.666667222976685 L 88.35556030273438 2.666667222976685 L 88.35556030273438 0.08888889104127884 C 88 0.08888889104127884 87.11111450195313 0 86.13333129882813 0 C 84 0 82.4888916015625 1.333333373069763 82.4888916015625 3.733333110809326 L 82.4888916015625 5.866666793823242 L 80 5.866666793823242 L 80 8.711111068725586 L 82.4888916015625 8.711111068725586 L 82.4888916015625 16 L 85.42222595214844 16 Z" fill="#2699fb" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
