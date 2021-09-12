import 'dart:async';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'dart:math';
import 'package:havruta_project/Globals.dart';



class EventsModel {
  Stream<List<Event>> stream;
  bool hasMore;
  String searchData;
  bool _isLoading;
  List<Event> _data;
  StreamController<List<Event>> _controller;
  bool onlineBit;


  EventsModel(bool online) {
    _data = List<Event>();
    _controller = StreamController<List<Event>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<Event> postsData) {
      return postsData.map((Event eventData) {
        return eventData;
      }).toList();
    });
    hasMore = true;
    onlineBit = online;
    refresh();
  }

  Future<List<Event>>  _getExampleServerData(int length) async {
   // print(searchData + 'db');
    if (searchData != null) {
      return Future.delayed(Duration(seconds: 1), () {
        return Globals.db.searchEvents(searchData);
      });
    }
    if (onlineBit == true){
      return Future.delayed(Duration(seconds: 1), () {
        return Globals.db.getSomeEventsOnline(length);
      });
    }
    return Future.delayed(Duration(seconds: 1), () {
      return Globals.db.getSomeEvents(length);
    });
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData || searchData != null) {
      _data = List<Event>();
      hasMore = true;
    }
    if ((_isLoading || !hasMore)&& searchData != null) {
      return Future.value();
    }
    _isLoading = true;
    return _getExampleServerData(_data.length).then((postsData) {
      _isLoading = false;
      _data.addAll(postsData);
      hasMore =  true;
      _controller.add(_data);
    });
  }
}


