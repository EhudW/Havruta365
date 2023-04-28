import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/NotificationView.dart';
import 'package:havruta_project/main.dart';

// ignore: must_be_immutable, camel_case_types
class notificationsScroll extends StatefulWidget {
  NewNotificationManager nnim;

  notificationsScroll(this.nnim);

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
              stream: this.widget.nnim.model.stream,
              builder: (BuildContext _context, AsyncSnapshot _snapshot) {
                if (!_snapshot.hasData) {
                  // no critical side-effects:
                  this.widget.nnim.model.simulateRefresh();
                  return Center(child: CircularProgressIndicator());
                } else {
                  return RefreshIndicator(
                    onRefresh: this.widget.nnim.model.refresh,
                    child: ListView.builder(
                      itemCount: _snapshot.data.length + 1,
                      itemBuilder: (BuildContext _context, int index) {
                        if (index < _snapshot.data.length) {
                          return Dismissible(
                              direction: DismissDirection.startToEnd,
                              resizeDuration: Duration(milliseconds: 200),
                              key: UniqueKey(),
                              onDismissed: (direction) async {
                                await widget.nnim.model
                                    .remove(index)
                                    .catchError((err) => null);
                                // refresh ui if this delete cause that
                                if (widget.nnim.model.dataLen == 0) {
                                  widget.nnim.newNotification = 0;
                                  widget.nnim.refreshAll();
                                }
                              },
                              child: NotificationView(
                                notification: _snapshot.data[index],
                              ));
                        } else if (index == 0 && _snapshot.data.length == 0) {
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
