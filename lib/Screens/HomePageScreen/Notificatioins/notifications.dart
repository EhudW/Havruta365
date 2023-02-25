import 'package:flutter/material.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notificationModel.dart';
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
    notificationModel model = widget.nnim.model;
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        model.loadMore();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: new notificationsScroll(widget.nnim));
  }
}
