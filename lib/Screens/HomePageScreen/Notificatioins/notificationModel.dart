import 'package:havruta_project/Globals.dart';
import 'dart:async';
import 'package:havruta_project/DataBase_auth/Notification.dart';

import '../../../mydebug.dart';

// ignore: camel_case_types
class notificationModel {
  bool _wasFetched = false;
  Stream<List<NotificationUser>>? stream;
  List<NotificationUser>? _data;
  bool get isDataEmpty => _data?.isEmpty ?? true;
  late StreamController<List<NotificationUser>?> _controller;
  bool ignoreRequests = false;
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
    if (ignoreRequests) return [];
    return Future.delayed(MyConsts.defaultDelay, () {
      var data = Globals.db!.getNotifications();
      return data;
    });
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> remove(int idx) {
    if (ignoreRequests) return Future.value();
    var noti = _data![idx];
    _data!.remove(noti);
    _controller.add(_data);
    return Globals.db!.deleteNotification(noti);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (ignoreRequests) return Future.value();
    if (clearCachedData) {
      _data = <NotificationUser>[];
    }

    return getData(10).then((postsData) {
      _data!.addAll(postsData);
      _controller.add(_data);
      _wasFetched = true;
    });
  }

  // don't fetch from server, but resend item to stream,
  // if was fetch with this model, at least one time
  void simulateRefresh() => _wasFetched ? _controller.add(_data) : null;
}
