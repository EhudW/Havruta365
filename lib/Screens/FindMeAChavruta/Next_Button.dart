import 'package:havruta_project/DataBase_auth/Event.dart';

import 'package:adobe_xd/page_link.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta2.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta3.dart';

class NextButton extends StatelessWidget {
  final Event event;
  final int whichPage;

  NextButton({@required this.event, @required this.whichPage});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 280,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (this.whichPage == 2) {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          FindMeAChavruta2(event: this.event)));
            } else {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          FindMeAChavruta3(event: this.event)));
            }
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.teal,
              shape: StadiumBorder(),
              shadowColor: Colors.grey.withOpacity(1)),
          child: Icon(Icons.arrow_forward_outlined),
        ));
  }
}
