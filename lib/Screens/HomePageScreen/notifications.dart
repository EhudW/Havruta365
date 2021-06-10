import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:havruta_project/Screens/HomePageScreen/notificationModel.dart';
import 'package:havruta_project/Screens/HomePageScreen/NotificationView.dart';
import 'package:havruta_project/Globals.dart';
import 'dart:async';
import 'package:havruta_project/DataBase_auth/Notification.dart';

class Notifications extends StatefulWidget {
  const Notifications({
    Key key,
  }) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final scrollController = ScrollController();

  notificationModel notifications;

  @override
  void initState() {
    notifications = notificationModel(false);
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        notifications.loadMore();
      }
    });
    super.initState();
    NotificationUser n = new NotificationUser();
    n.message = 'התראה';
    n.type = '';
    n.idEvent = '60bbda688b4c85a59e40886f';
    n.creatorUser = 'yonatan4';
    n.creationDate = DateTime.now();
    n.description = '';
    Globals.db.insertNotification(n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true, body: eventsScroll());
  }

  eventsScroll() {
    return Scrollbar(
        child: StreamBuilder(
      stream: notifications.stream,
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (!_snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return RefreshIndicator(
            onRefresh: notifications.refresh,
            child: ListView.builder(
              itemCount: _snapshot.data.length + 1,
              itemBuilder: (BuildContext _context, int index) {
                if (index < _snapshot.data.length) {
                  return Dismissible(
                      direction: DismissDirection.startToEnd,
                      resizeDuration: Duration(milliseconds: 200),
                      key: ObjectKey(_snapshot.data[index]),
                      onDismissed: (direction) {
                        _snapshot.data.removeAt[index];

                        // TODO: implement your delete function and check direction if needed
                      },
                      child: NotificationView(
                        notification: _snapshot.data[index],
                      ));
                } else if (notifications.hasMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child:Text("אין התראות")),
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
    ));
  }
}
