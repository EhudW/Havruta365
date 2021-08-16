import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_animation_set/animation_set.dart';
import 'package:flutter_animation_set/animator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

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
              SizedBox(height: 60,),
              Container(
                width: 200,
                height: 200,
                child: AnimatorSet(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Globals.scaler.getTextSize(12)),
                    child: Image(
                        image: AssetImage("images/AppIcon2.png"),
                        alignment: Alignment.center,
                        width: 160,
                        height: 160,),
                  ),
                  animatorSet: [
                    //SX(from: 0.1, to: 2, duration: 2000, delay: 0, curve: Curves.bounceInOut),
                    //SY(from: 0.1, to: 2, duration: 2000, delay: 0, curve: Curves.bounceInOut),
                    O(from: 0.3, to: 1, duration: 1500, delay: 0, curve: Curves.easeInOut),
                    O(from: 1, to: 0, duration: 1500, delay: 0, curve: Curves.easeInOut),
                  ],
                  animationType: AnimationType.repeat,
                  debug: false,
                ),
              ),
              SizedBox(height: 150,),
              Text(
                'חברותא',
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
