import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'dart:math';

/// Example data as it might be returned by an external service
/// ...this is often a `Map` representing `JSON` or a `FireStore` document

class EventsModel {
  Stream<List<Event>> stream;
  bool hasMore;
  String searchData;
  bool _isLoading;
  List<Map> _data;
  StreamController<List<Map>> _controller;
  bool onlineBit;

  EventsModel(bool online) {
    _data = List<Map>();
    _controller = StreamController<List<Map>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<Map> postsData) {
      return postsData.map((Map eventData) {
        return Event.fromServerMap(eventData);
      }).toList();
    });
    hasMore = true;
    onlineBit = online;
    refresh();
  }

  Future<List<Map>>  _getExampleServerData(int length) async {
    var rng = new Random();
    if (searchData == "null") {
      print("1111");
    }
    if (onlineBit == true){
      return Future.delayed(Duration(seconds: 1), () {
        return List<Map>.generate(length, (int index) {
          return {
            "book": WordPair.random().asPascalCase,
            "eventImage":'https://freenaturestock.com/wp-content/uploads/freenaturestock-170${rng.nextInt(9)}-1024x683.jpg',
            "topic": WordPair.random().asPascalCase,
            "description": '123'
          };
        });
      });
    }
    return Future.delayed(Duration(seconds: 1), () {
      return List<Map>.generate(length, (int index) {
        return {
          "book": WordPair.random().asPascalCase,
          "eventImage":'https://randomuser.me/api/portraits/men/${rng.nextInt(100)}.jpg',
          "topic": WordPair.random().asPascalCase,
          "frequency": 'חודשי',
          "participants": ['1','2'],
         "creatorUser": '4yona@gmail.com',
          "type": 'type',
          "date": 'date',
          "link": 'link',
          "description": 'description',
          "lecturer": 'lecturer',
          "starRating": 1

        };
      });
    });
  }
  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData || searchData != null) {
      _data = List<Map>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;
    return _getExampleServerData(10).then((postsData) {
      _isLoading = false;
      _data.addAll(postsData);
      hasMore = (_data.length < 10);
      _controller.add(_data);
    });
  }
}
