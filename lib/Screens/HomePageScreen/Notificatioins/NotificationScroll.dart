import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notificationModel.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/NotificationView.dart';
import 'package:havruta_project/Globals.dart';

// ignore: must_be_immutable, camel_case_types
class notificationsScroll extends StatefulWidget {
  notificationModel? model;

  notificationsScroll(this.model);

  @override
  _notificationsScrollState createState() => _notificationsScrollState();
}

// ignore: camel_case_types
class _notificationsScrollState extends State<notificationsScroll> {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: Material(
            color: Colors.grey.withOpacity(0.8),
            child: StreamBuilder(
              stream: this.widget.model!.stream,
              builder: (BuildContext _context, AsyncSnapshot _snapshot) {
                if (!_snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return RefreshIndicator(
                    onRefresh: this.widget.model!.refresh,
                    child: ListView.builder(
                      itemCount: _snapshot.data.length + 1,
                      itemBuilder: (BuildContext _context, int index) {
                        if (index < _snapshot.data.length) {
                          return Dismissible(
                              direction: DismissDirection.startToEnd,
                              resizeDuration: Duration(milliseconds: 200),
                              key: ObjectKey(_snapshot.data[index]),
                              onDismissed: (direction) async {
                                await Globals.db!
                                    .deleteNotification(_snapshot.data[index]);
                              },
                              child: NotificationView(
                                notification: _snapshot.data[index],
                              ));
                        } else if (_snapshot.data.length == 0) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: Text("אין לך התראות")),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                          );
                        }
                      },
                    ),
                  );
                }
              },
            )));
  }
}
