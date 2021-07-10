import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/HomePageScreen/notifications.dart';
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
    return Scaffold(
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: floatingActionButton(),
        bottomNavigationBar: bottomAppBar());
  }

  appBar(BuildContext context) {
    return new AppBar(
        leadingWidth: 40,
        toolbarHeight: 40,
        elevation: 10,
        leading: Builder(
            builder: (context) => new IconButton(
                  icon: currentStateAppBar == 0
                      ? Icon(Icons.notifications, color: Colors.teal[400],size: scaler.getTextSize(9))
                      : Icon(Icons.notifications_none, color: Colors.teal[400],size:scaler.getTextSize(9)),
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
        title: Container(
          width: scaler.getWidth(28),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Text(
            "Havruta  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(fontWeight: FontWeight.bold,  fontSize: 20, color:Colors.teal[400]),
          ),
                Icon(FontAwesomeIcons.book, size: 25, color: Colors.teal[400])
              ]),
        ));
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
                icon: Icon(Icons.settings),
                color: Colors.white54,
                onPressed: () {},
                iconSize: scaler.getTextSize(10),
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.white54,
                onPressed: () {},
                iconSize: scaler.getTextSize(10),
              )
            ],
          ),
        ),
      ),
    );
  }
}
