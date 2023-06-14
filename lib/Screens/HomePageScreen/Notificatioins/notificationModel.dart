import 'package:havruta_project/Globals.dart';
import 'dart:async';
import 'package:havruta_project/DataBase_auth/Notification.dart';

import '../../../mydebug.dart';

// ignore: camel_case_types
class notificationModel {
  bool _wasFetched = false;
  Stream<List<NotificationUser>>? stream;
  List<NotificationUser>? _data;
  Set<dynamic> _ignore_ids = {};
  NotificationUser? getNewest() {
    try {
      return _data!.first;
    } catch (err) {
      return null;
    }
  }

  //int get dataLen => _data?.length ?? 0;
  int get unseenLen => _data?.where((e) => e.unseen).length ?? 0;
  late StreamController<List<NotificationUser>?> _controller;
  bool ignoreRequests = false;
  notificationModel() {
    _data = <NotificationUser>[];
    _controller = StreamController<List<NotificationUser>?>.broadcast();
    stream = _controller.stream.map((List<NotificationUser>? postsData) {
      return postsData!.where((NotificationUser eventData) {
        return !_ignore_ids.contains(eventData.id);
      }).toList();
    });
    refresh();
  }
  Future seenAll() async {
    var notis =
        _data?.where((element) => element.unseen).map((e) => e.id).toList() ??
            [];
    if (notis.isEmpty) return;
    await Globals.db!.seenNoti(notis);
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
    _ignore_ids.addAll(noti.map((e) => e.id)); //avoid auto refresh interrupt
    _data = [];
    _controller.add([]);
    return Globals.db!
        .deleteAllNotifications(noti)
        .catchError((value) => _ignore_ids.removeAll(noti.map((e) => e.id)));
  }

  Future<void> remove(NotificationUser noti, {bool autoSimulate = false}) {
    if (ignoreRequests) return Future.value();
    _ignore_ids.add(noti.id);
    _data!.removeWhere((item) => item.id == noti.id);
    if (autoSimulate) _controller.add(_data);
    return Globals.db!
        .deleteNotification(noti)
        .catchError((_) => _ignore_ids.remove(noti.id));
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (ignoreRequests) return Future.value();

    return getData(10).then((postsData) {
      postsData.forEach((element) {
        if (element.type == "eventUpdated:rejected" ||
            element.type ==
                "joinReject") // stay sub to forum of deleted event "eventDeleted" ?
          Globals.db!
              .updateUserSubs_Topics(remove: [element.idEvent.toString()]);
      });
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
