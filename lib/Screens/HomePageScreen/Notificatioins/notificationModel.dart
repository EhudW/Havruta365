import 'package:havruta_project/Globals.dart';
import 'dart:async';
import 'package:havruta_project/DataBase_auth/Notification.dart';

import '../../../mydebug.dart';

// ignore: camel_case_types
class notificationModel {
  bool _wasFetched = false;
  Stream<List<NotificationUser>>? stream;
  List<NotificationUser>? _data;
  NotificationUser? getNewest() {
    try {
      return _data!.first;
    } catch (err) {
      return null;
    }
  }

  int get dataLen => _data?.length ?? 0;
  int get unseenLen => _data?.where((e) => e.unseen).length ?? 0;
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
  Future seenAll() async {
    await Globals.db!.seenNoti(
        _data?.where((element) => element.unseen).map((e) => e.id).toList() ??
            []);
    await refresh();
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

  Future<void> removeAll() {
    if (ignoreRequests) return Future.value();
    var noti = _data!;
    _data = [];
    _controller.add([]);
    return Globals.db!.deleteAllNotifications(noti);
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

    return getData(10).then((postsData) {
      if (clearCachedData) {
        _data = postsData;
      } else {
        _data!.addAll(postsData);
      }
      _controller.add(_data);
      _wasFetched = true;
    });
  }

  // don't fetch from server, but resend item to stream,
  // if was fetch with this model, at least one time
  void simulateRefresh() => _wasFetched ? _controller.add(_data) : null;
}
