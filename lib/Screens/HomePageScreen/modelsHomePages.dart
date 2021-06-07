import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'dart:math';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Globals.dart';


/// Example data as it might be returned by an external service
/// ...this is often a `Map` representing `JSON` or a `FireStore` document

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
    if (searchData != null) {
      return Future.delayed(Duration(seconds: 1), () {
        return Globals.db.searchEvents(searchData);
      });
    }
    if (onlineBit == true){
      return Future.delayed(Duration(seconds: 1), () {
        return Globals.db.getSomeEventsOnline();
      });
    }
    return Future.delayed(Duration(seconds: 1), () {
      return Globals.db.getSomeEvents();
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
