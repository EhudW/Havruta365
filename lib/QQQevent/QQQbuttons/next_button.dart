import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/event/screens/create_event_screen/create_event_administration_details.dart';
import 'package:havruta_project/QQQglobals.dart';
import 'package:havruta_project/event/create_event/choose_dates.dart';
import 'dart:ui' as ui;

class NextButton extends StatelessWidget {
  final Event? event;
  final int whichPage;
  final BuildContext context;
  final bool isEmpty;
  final List<Event>? allUserEvents;
  NextButton(
      {Key? key,
      required this.context,
      required this.event,
      required this.whichPage,
      required this.isEmpty,
      this.allUserEvents})
      : super(key: key);

  askIfProblems(
      Function toRun, List<bool> problems, List<String> whatToAsk) async {
    bool answer = true;
    for (int i = 0; i < problems.length; i++) {
      if (!problems[i]) {
        continue;
      }
      answer = answer &&
          await showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet(
                      context,
                      whatToAsk[i],
                      () => Navigator.pop(context, true),
                      () => Navigator.pop(context, false),
                    )),
              ) ==
              true;
    }
    if (answer == true) toRun();
  }

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
                  if (event!.minAge <= event!.maxAge) {
                    var apply = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChooseDates(
                                event: this.event,
                                allUserEvents: allUserEvents)));

                    var problem =
                        event?.id != null && event!.shouldDuplicate == false;
                    int m = event?.maxParticipants ?? 0;
                    int p = event?.participants?.length ?? 0;
                    int wq = event?.waitingQueue?.length ?? 0;

                    bool targetGenderProblem = problem &&
                        event?.firstInitTargetGender != event?.targetGender &&
                        {"גברים", "נשים"}.contains(event?.targetGender);
                    bool targetAgesProblem = problem &&
                        (event!.firstInitMinAge < event!.minAge ||
                            event!.firstInitMaxAge > event!.maxAge);
                    var a = event!.firstInitOnlyForStatus;
                    var aa = Event.statusesCanJoin(a!);
                    var b = event!.onlyForStatus;
                    var bb = Event.statusesCanJoin(b!);
                    var cc = aa.intersection(bb);
                    bool targetStatusProblem = problem &&
                        a != b &&
                        (cc.length !=
                            aa.length); // its ok that now more people can join: || cc.length != bb.length);
                    bool typeChangeProblem =
                        problem && event?.type != event?.firstInitType;
                    bool maxParticipantsProblem = problem && m < p /*+ wq*/;

                    List<bool> problems = [
                      maxParticipantsProblem,
                      typeChangeProblem,
                      targetGenderProblem,
                      targetAgesProblem,
                      targetStatusProblem,
                    ];
                    List<String> whatToAsk = [
                      "הקטנת מספר המשתתפים תבטל נרשמים קיימים",
                      event?.type == 'L'
                          ? "שינוי סוג לשיעור יגרור אישור או דחייה מיידיים של הממתינים"
                          : "שינוי סוג לחברותא יגרור העברה של כל המשתתפים לתור המתנה לאישור",
                      "שינוי קבוצת יעד גברים/נשים עלול לגרור ביטול השתתפות של חלק",
                      "שינוי טווח גילאי קבוצת יעד עלול לגרור ביטול השתתפות של חלק",
                      "שינוי סטטוס משפחתי של קבוצת יעד עלול לגרור ביטול השתתפות של חלק",
                    ];
                    askIfProblems(apply, problems, whatToAsk);
                  } else {
                    showErrorSnackBar(context,
                        'גיל מינימלי צריך להיות קטן יותר מגיל מקסימלי');
                  }
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
          child: Icon(Icons.arrow_forward_outlined,
              textDirection: TextDirection.rtl),
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
              textDirection: ui.TextDirection.rtl,
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

  static Widget bottomSheet(
      BuildContext context, String title, Function ok, Function ignore) {
    return Container(
      height: Globals.scaler.getHeight(8.5),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: Globals.scaler.getWidth(3),
        vertical: Globals.scaler.getHeight(1),
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            textDirection: ui.TextDirection.rtl,
            style: TextStyle(
              fontSize: Globals.scaler.getTextSize(8.5),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.check),
              onPressed: () {
                ok();
              },
              label: Text("בכל זאת"),
            ),
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.circleXmark),
              onPressed: () {
                ignore();
              },
              label: Text("בטל פעולה"),
            ),
          ])
        ],
      ),
    );
  }
}
