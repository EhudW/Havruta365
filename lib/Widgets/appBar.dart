import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends AppBar {
  CustomAppBar()
      : super(
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.teal[400]),
                  ),
                  Icon(FontAwesomeIcons.book, size: 25, color: Colors.teal[400])
                ])));
}
