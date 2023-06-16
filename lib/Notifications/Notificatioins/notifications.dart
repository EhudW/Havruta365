import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:havruta_project/Event/CreateEvent/Next_Button.dart';
import 'package:havruta_project/Notifications/Notificatioins/NotificationModel.dart';
import 'package:havruta_project/main.dart';

import 'NotificationScroll.dart';

class Notifications extends StatefulWidget {
  final NewNotificationManager nnim;
  Notifications({
    Key? key,
    required this.nnim,
  }) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    /*notificationModel model = widget.nnim.model;
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        model.loadMore();
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new notificationsScroll(widget.nnim),
      floatingActionButton: StreamBuilder(
          stream: this.widget.nnim.model.stream,
          builder: (BuildContext _context, AsyncSnapshot _snapshot) {
            if (_snapshot.hasData == false ||
                _snapshot.data == null ||
                _snapshot.data.isEmpty == true) {
              return SizedBox();
            } else {
              return SizedBox(
                  height: ScreenScaler().getHeight(5),
                  width: ScreenScaler().getWidth(4),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => NextButton.bottomSheet(
                                context, "למחוק כל ההתראות?", () async {
                              await widget.nnim.model
                                  .removeAll()
                                  .catchError((err) => null);
                              // refresh ui,fcm if this delete cause that

                              widget.nnim.refreshAll(
                                  debuglbl: "rmv all",
                                  forceRefresh: true,
                                  tryAvoidNext2Sec: false);

                              Navigator.pop(context);
                            }, () => Navigator.pop(context))),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ));
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
