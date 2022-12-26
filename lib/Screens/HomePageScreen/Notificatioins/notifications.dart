import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'package:havruta_project/Screens/HomePageScreen/Notificatioins/notificationModel.dart';

import 'NotificationScroll.dart';

class Notifications extends StatefulWidget {
  const Notifications({
    Key? key,
  }) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final scrollController = ScrollController();

  notificationModel? model;

  @override
  void initState() {
    model = notificationModel();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        model!.loadMore();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: new notificationsScroll(model));
  }
}
