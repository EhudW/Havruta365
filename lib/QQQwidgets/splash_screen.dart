//import 'package:flutter/cupertino.dart';
// ignore_for_file: unused_field, unused_local_variable

import 'package:flutter/material.dart';
import 'package:havruta_project/QQQglobals.dart';
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Color> _kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.green,
    Colors.tealAccent,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 50.0,
      fontFamily: 'Horizon',
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   'חברותא',
            //   style: GoogleFonts.mPlus1p(
            //       textStyle: TextStyle(
            //     color: Colors.brown,
            //     fontSize: Globals.scaler.getTextSize(13),
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 8,
            //   )),
            // ),
            SizedBox(
              height: 60,
            ),
            Container(
                width: 200,
                height: 200,
                child: Image(
                  image: AssetImage("images/AppIcon2.png"),
                  alignment: Alignment.center,
                  width: 160,
                  height: 160,
                )),
            SizedBox(
              height: 150,
            ),
            Text(
              'חברותא+',
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Yiddish',
                color: Colors.brown,
                fontSize: Globals.scaler.getTextSize(10),
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            // Container(
            //   width: Globals.scaler.getWidth(6),
            //   height: Globals.scaler.getHeight(6),
            //   child: LoadingIndicator(
            //       indicatorType: Indicator.ballScaleMultiple,
            //       /// Required, The loading type of the widget
            //       colors: _kDefaultRainbowColors,
            //       /// Optional, The color collections
            //       strokeWidth: 2,
            //       /// Optional, The stroke of the line, only applicable to widget which contains line
            //       backgroundColor: Colors.transparent,
            //       /// Optional, Background of the widget
            //       pathBackgroundColor: Colors.black
            //       /// Optional, the stroke backgroundColor
            //       ),
            // ),
          ],
        ),
      ),
    );
  }
}
