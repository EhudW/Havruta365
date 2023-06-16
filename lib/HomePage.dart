import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Notifications/Notificatioins/Notifications.dart';
import 'package:havruta_project/Chat/Screens/ChatsFeedScreen.dart';
import 'package:havruta_project/Users/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:havruta_project/main.dart';
import 'Event/Screens/EventScrollerScreen/Events.dart';
import 'package:havruta_project/Event/Screens/CreateEventScreen/FindMeAChavruta1.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'Event/Widgets/modelsHomePages.dart';

class HomePage extends StatefulWidget {
  final bool openNotificationOnStart;
  HomePage({
    Key? key,
    this.openNotificationOnStart = false,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentStateAppBar = 0;
  // ignore: unused_field
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  ScreenScaler scaler = new ScreenScaler();
  //Events events = Events(new EventsModel(false), new EventsModel(true));
  var em1 = new EventsModel(false);
  var em2 = new EventsModel(true);
  //GlobalKey<ScaffoldState> scaffold = new GlobalKey();
  //use NewNotificationManager.onlyLast for build()
  NewNotificationManager? get nnim => NewNotificationManager.onlyLast;
  // call before/then each navigator.push
  setRefresh(bool on, {bool andRefreshNow = true}) {
    if (on) {
      Globals.onNewMsg = () => !mounted ? null : setState(() {});
      nnim!.refreshMe[this] = () => !mounted ? null : setState(() {});
      //nnim!.start();
      if (andRefreshNow && mounted) setState(() {});
    } else {
      Globals.onNewMsg = () => null;
      nnim!.refreshMe[this] = () => null;
      // nnim!.cancel(); keep looking for new notification even if not in this screen (for fcm update)
    }
  }

  @override
  void initState() {
    super.initState();
    setRefresh(true);
    if (widget.openNotificationOnStart)
      Timer(Duration(milliseconds: 700),
          () => _scaffoldKey.currentState?.openDrawer());
  }

  @override
  void dispose() {
    setRefresh(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Scaffold(
            body: Scaffold(
                body: Column(
                    children: <Widget>[Expanded(child: Events(em1, em2))]),
                key: _scaffoldKey,
                drawer: Drawer(
                    child: Container(
                        color: Colors.transparent,
                        child: Column(children: <Widget>[
                          Expanded(
                              child: Notifications(
                                  nnim: NewNotificationManager.onlyLast!))
                        ])))),
            backgroundColor: Colors.white,
            appBar: appBar(context),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            resizeToAvoidBottomInset: false,
            floatingActionButton: floatingActionButton(),
            bottomNavigationBar: BottomAppBar(
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
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(FontAwesomeIcons.envelope),
                            color: /*Globals.hasNewMsg
                                ? Colors.redAccent
                                :*/
                                Colors.white54,
                            onPressed: () async {
                              setRefresh(false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatsFeedScreen()),
                              ).then((value) => setRefresh(true));
                              // this.events.events.refresh();
                              // this.events.eventsOnline.refresh();
                            },
                            iconSize: scaler.getTextSize(10),
                          ),
                          CircleAvatar(
                            radius:
                                Globals.msgWithFriendsUnread == 0 ? 0 : 13.0,
                            backgroundColor: Colors.red[900],
                            child: Text(
                              Globals.msgWithFriendsUnread.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.person),
                        color: Colors.white54,
                        onPressed: () {
                          setRefresh(false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()),
                          ).then((value) => setRefresh(true));
                        },
                        iconSize: scaler.getTextSize(10),
                      )
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  appBar(BuildContext context) {
    return new AppBar(
      leadingWidth: Globals.scaler.getWidth(7),
      toolbarHeight: Globals.scaler.getHeight(2.2),
      elevation: 10,
      leading: Builder(
          builder: (context) => new IconButton(
                icon:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Stack(
                    children: [
                      Row(children: [
                        SizedBox(
                            width: Globals.scaler.getWidth(
                                (NewNotificationManager
                                                .onlyLast?.newNotification ??
                                            0) >
                                        0
                                    ? 1.2
                                    : 0)),
                        Icon(
                            /*((NewNotificationManager.onlyLast?.newNotification ??
                                      0) >
                                  0)
                              ? Icons.notification_important
                              : */
                            Icons.notifications,
                            color: /*((NewNotificationManager
                                          .onlyLast?.newNotification ??
                                      0) >
                                  0)
                              ? Colors.redAccent
                              :*/
                                Colors.teal[400],
                            size: scaler.getTextSize(10)),
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: CircleAvatar(
                          radius: (NewNotificationManager
                                          .onlyLast?.newNotification ??
                                      0) >
                                  0
                              ? 13
                              : 0,
                          backgroundColor: Colors.red[900],
                          child: Text(
                            (NewNotificationManager.onlyLast?.newNotification ??
                                    0)
                                .toString(),
                            style: TextStyle(
                                //fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: () {
                  if (_scaffoldKey.currentState!.isDrawerOpen == false) {
                    _scaffoldKey.currentState!.openDrawer();
                  } else {
                    _scaffoldKey.currentState!.openEndDrawer();
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
                'חברותא+',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Yiddish',
                  color: Colors.teal,
                  fontSize: Globals.scaler.getTextSize(10),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),
            SizedBox(
              width: Globals.scaler.getWidth(0.8),
            )
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
            setRefresh(false);
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FindMeAChavruta1()))
                .then((value) => setRefresh(true));
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
                onPressed: () async {
                  // var currentUser;
                  // if (await GoogleSignInApi.isSignedIn()) {
                  //   currentUser = GoogleSignInApi.currentUser();
                  //   print("Signed in");
                  //   print(currentUser);
                  //   await GoogleSignInApi.logout();
                  // }
                  // // Remove mail from local phone and go to Login page
                  // final SharedPreferences prefs = await _prefs;
                  // await prefs.setString('id', "");
                  // Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(builder: (context) => Login()));
                },
                iconSize: scaler.getTextSize(10),
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.white54,
                onPressed: () {
                  setRefresh(false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  ).then((value) => setRefresh(true));
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
