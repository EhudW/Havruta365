import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';

import 'Events.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentState = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            toolbarHeight: 40,
            elevation: 20,
            shadowColor: Colors.teal[400],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            )),
            backgroundColor: Colors.white,
            title: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Text(
                    'Havruta  ',
                    style: TextStyle(fontWeight:FontWeight.bold, color: Colors.teal[400]),
                  ),
                  Icon(FontAwesomeIcons.book, size: 25, color: Colors.teal[400])
                ]))),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            // Navigator.of(context)
            //     .push(MaterialPageRoute(builder: (context) => AddBlog()));
          },
          child: Text(
            "+",
            style: TextStyle(fontSize: 40),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.teal[400],
          shape: CircularNotchedRectangle(),
          notchMargin: 12,
          child: Container(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.settings),
                    color: currentState == 0 ? Colors.white : Colors.white54,
                    onPressed: () {
                      setState(() {
                        currentState = 0;
                      });
                    },
                    iconSize: 40,
                  ),
                  IconButton(
                    icon: Icon(Icons.person),
                    color: currentState == 1 ? Colors.white : Colors.white54,
                    onPressed: () {
                      setState(() {
                        currentState = 1;
                      });
                    },
                    iconSize: 40,
                  )
                ],
              ),
            ),
          ),
        ),
        body: Column(children: <Widget>[Expanded(child: Events())])

        //floatingActionButton: _searchBar(),
        //floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
  }
}
