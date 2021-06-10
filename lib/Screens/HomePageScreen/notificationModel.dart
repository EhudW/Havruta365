import 'package:havruta_project/Globals.dart';
import 'dart:async';
import 'package:havruta_project/DataBase_auth/Notification.dart';

class notificationModel {

  Stream<List<NotificationUser>> stream;
  bool hasMore;
  bool _isLoading;
  List<NotificationUser> _data;
  StreamController<List<NotificationUser>> _controller;

  notificationModel(bool online) {
    _data = List<NotificationUser>();
    _controller = StreamController<List<NotificationUser>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<NotificationUser> postsData) {
      return postsData.map((NotificationUser eventData) {
        return eventData;
      }).toList();
    });
    hasMore = true;
    refresh();
  }

  Future<List<NotificationUser>>  _getExampleServerData(int length) async {
    return Future.delayed(Duration(seconds: 1), () {
      var data = Globals.db.getNotifications();
      return data;
    });
  }
  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<NotificationUser>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;
    return _getExampleServerData(1).then((postsData) {
      _isLoading = false;
      _data.addAll(postsData);
      hasMore = (_data.length < 1);
      _controller.add(_data);
    });
  }
}
