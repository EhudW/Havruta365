import 'package:havruta_project/Globals.dart';
import 'dart:async';
import 'package:havruta_project/DataBase_auth/Notification.dart';

// ignore: camel_case_types
class notificationModel {
  Stream<List<NotificationUser>>? stream;
  List<NotificationUser>? _data;
  bool get isDataEmpty => _data?.isEmpty ?? true;
  late StreamController<List<NotificationUser>?> _controller;

  notificationModel() {
    _data = <NotificationUser>[];
    _controller = StreamController<List<NotificationUser>?>.broadcast();
    stream = _controller.stream.map((List<NotificationUser>? postsData) {
      return postsData!.map((NotificationUser eventData) {
        return eventData;
      }).toList();
    });
    refresh();
  }

  Future<List<NotificationUser>> getData(int length) async {
    return Future.delayed(Duration(seconds: 1), () {
      var data = Globals.db!.getNotifications();
      return data;
    });
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> remove(int idx) {
    var noti = _data![idx];
    print(_data?.length);
    _data!.remove(noti);
    print(_data?.length);
    _controller.add(_data);
    return Globals.db!.deleteNotification(noti);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = <NotificationUser>[];
    }

    return getData(10).then((postsData) {
      _data!.addAll(postsData);
      _controller.add(_data);
    });
  }
}
