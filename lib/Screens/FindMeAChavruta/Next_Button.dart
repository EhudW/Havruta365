import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/FindMeAChavruta3.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/FindMeAChavruta/ChooseDates.dart';

class NextButton extends StatelessWidget {
  final Event? event;
  final int whichPage;
  final BuildContext context;
  final bool isEmpty;

  NextButton(
      {Key? key,
      required this.context,
      required this.event,
      required this.whichPage,
      required this.isEmpty})
      : super(key: key);

  @override
  Widget build(context) {
    return Container(
        width: Globals.scaler.getWidth(29),
        height: Globals.scaler.getHeight(3),
        child: ElevatedButton(
          onPressed: () {
            if (!this.isEmpty) {
              if (this.whichPage == 2) {
                if (!(this.event!.type == "" ||
                    this.event!.topic == '' ||
                    this.event!.targetGender == "" ||
                    // this.event.book == "" ||
                    this.event!.maxParticipants == 0)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChooseDates(event: this.event)));
                } else {
                  showErrorSnackBar(
                      context, 'צריך למלא את כל השדות לפני שמתקדמים');
                }
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FindMeAChavruta3(event: this.event)));
              }
            } else {
              if (this.whichPage == 2)
                showErrorSnackBar(
                    context, 'צריך למלא את כל השדות לפני שמתקדמים');
              else {
                showErrorSnackBar(context, "צריך להוסיף לפחות זמן אחד");
              }
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: StadiumBorder(),
              shadowColor: Colors.grey.withOpacity(1)),
          child: Icon(Icons.arrow_forward_outlined),
        ));
  }

  void showErrorSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: Globals.scaler.getTextSize(10)),
          SizedBox(width: Globals.scaler.getWidth(5)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: Globals.scaler.getTextSize(8)),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.fixed,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
