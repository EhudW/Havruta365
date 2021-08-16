import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/notifications.dart';
import 'package:havruta_project/Screens/ProfileScreen/ProfileScreen.dart';
import 'Events.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta1.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentStateAppBar = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  ScreenScaler scaler = new ScreenScaler();

  //GlobalKey<ScaffoldState> scaffold = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return;
      },
      child: Center(
        child: Scaffold(
            body: Scaffold(
                body: Column(children: <Widget>[Expanded(child: Events())]),
                key: _scaffoldKey,
                drawer: Drawer(
                    child: Container(
                        color: Colors.transparent,
                        child: Column(children: <Widget>[
                          Expanded(child: Notifications())
                        ])))),
            backgroundColor: Colors.white,
            appBar: appBar(context),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            resizeToAvoidBottomInset: false,
            floatingActionButton: floatingActionButton(),
            bottomNavigationBar: bottomAppBar()),
      ),
    );
  }

  appBar(BuildContext context) {
    return new AppBar(
        leadingWidth: Globals.scaler.getWidth(3),
        toolbarHeight: Globals.scaler.getHeight(2.2),
        elevation: 10,
        leading: Builder(
            builder: (context) => new IconButton(
                  icon: Center(
                    child: Icon(Icons.notifications,
                        color: Colors.teal[400], size: scaler.getTextSize(10)),
                  ),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                  onPressed: () {
                    if (_scaffoldKey.currentState.isDrawerOpen == false) {
                      _scaffoldKey.currentState.openDrawer();
                    } else {
                      _scaffoldKey.currentState.openEndDrawer();
                    }
                    setState(() {
                      currentStateAppBar = 1;
                    });
                  },
                )),
        shadowColor: Colors.teal[400],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        )),
        backgroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Center(
                child: Text(
                  'חברותא',
                  style: TextStyle(
                    fontFamily: 'Yiddish',
                    color: Colors.teal,
                    fontSize: Globals.scaler.getTextSize(10),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
              SizedBox(width: Globals.scaler.getWidth(0.8),)
            ],
          ),
        ],
        // title: Container(
        //   width: scaler.getWidth(28),
          // child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       Text(
          //         "חברותא",
          //         textAlign: TextAlign.center,
          //         style: GoogleFonts.alef(
          //             fontWeight: FontWeight.bold,
          //             fontSize: Globals.scaler.getTextSize(9),
          //             color: Colors.teal[400],
          //         letterSpacing: 8),
          //       ),
          //       SizedBox(width: Globals.scaler.getWidth(1),),
          //       Icon(FontAwesomeIcons.book,
          //           size: Globals.scaler.getTextSize(8),
          //           color: Colors.teal[400])
          //     ]),
        );
  }

  floatingActionButton() {
    return SizedBox(
        height: scaler.getHeight(5),
        width: scaler.getWidth(4),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FindMeAChavruta1()));
          },
          child: Text(
            "+",
            style: TextStyle(fontSize: scaler.getTextSize(10)),
          ),
        ));
  }

  bottomAppBar() {
    return BottomAppBar(
      color: Colors.teal[400],
      shape: CircularNotchedRectangle(),
      notchMargin: scaler.getTextSize(5),
      child: Container(
        height: scaler.getHeight(2.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app_outlined),
                color: Colors.white54,
                onPressed: () {
                  // exit(0);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                iconSize: scaler.getTextSize(10),
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.white54,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                iconSize: scaler.getTextSize(10),
              )
            ],
          ),
        ),
      ),
    );
  }
}
