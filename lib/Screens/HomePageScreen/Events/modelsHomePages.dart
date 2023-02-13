import 'dart:async';
import 'package:havruta_project/DataBase_auth/Event.dart';
//import 'dart:math';
import 'package:havruta_project/Globals.dart';

/// class to get events(lessons) data as stream-like object
/// pullingLogic is control what functions will be called, if needed (when refreshing, for example)
class EventsModel {
  Stream<List<Event>>? stream;
  late bool hasMore;
  String? searchData;
  String? typeFilter;
  late bool _isLoading;
  List<Event>? _data;
  late StreamController<List<Event>?> _controller;
  bool? onlineBit;
  late PullingLogic pullingLogic;

  EventsModel(bool online, {PullingLogic? logic}) {
    this.pullingLogic = logic ?? PullingLogic();
    _data = [];
    _controller = StreamController<List<Event>?>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<Event>? postsData) {
      return postsData!.map((Event eventData) {
        return eventData;
      }).toList();
    });
    hasMore = true;
    onlineBit = online;
    refresh();
  }

  Future<List<Event>> _getExampleServerData(int length) async {
    // print(searchData + 'db');
    if (searchData != null) {
      return Future.delayed(Duration(seconds: 1), () {
        final String? tmp = searchData;
        if (tmp == null) {
          return Future.value([]);
        }
        return this.pullingLogic.search(length, tmp, typeFilter);
      });
    }
    if (onlineBit == true) {
      return Future.delayed(Duration(seconds: 1), () {
        return this.pullingLogic.nextOnline(length, typeFilter);
      });
    }
    return Future.delayed(Duration(seconds: 1), () {
      return this.pullingLogic.next(length, this, typeFilter);
    });
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData) {
      //|| searchData != null) {
      _data = [];
      hasMore = true;
    }
    if ((_isLoading || !hasMore)) {
      //&& searchData != null) {
      return Future.value();
    }
    _isLoading = true;

    return _getExampleServerData(_data!.length).then((postsData) {
      _isLoading = false;
      _data!.addAll(postsData);
      hasMore = hasMore && postsData.length > 0;
      _controller.add(_data);
    });
  }
}

// helper class to decide how to pull the data about events from the db
// for now, old events are filtered if this is general, and not filtered if it's specific for the user
class PullingLogic {
  String? withParticipant; // email
  String? createdBy; // email
  PullingLogic({this.withParticipant, this.createdBy})
      : assert(createdBy == null || withParticipant == null) {
    //print("constructor as $emailFilter");
  }
  Future<List<Event>> search(
      int length, String searchData, String? typeFilter) {
    //print("search as $emailFilter");
    return Globals.db!.searchEvents(searchData,
        filterOldEvents: this.withParticipant == null && this.createdBy == null,
        maxEvents: 10,
        startFrom: length,
        withParticipant: this.withParticipant,
        createdBy: this.createdBy,
        typeFilter: typeFilter);
  }

  Future<List<Event>> next(int length, EventsModel model, String? typeFilter) {
    if (withParticipant != null) {
      // right now, get events returns ALL events,with no filter for time
      // so in order to avoid infinite addition to the stream:
      model.hasMore = false;
      // even if getEvens will return only few, still there is race problem
      return Globals.db!.getEvents(withParticipant, false, typeFilter);
    } else if (createdBy != null) {
      model.hasMore = false;

      var query = (collection) async =>
          await collection.find({"creatorUser": createdBy}).toList();
      if (typeFilter != null) {
        query = (collection) async => await collection
            .find({"creatorUser": createdBy, "type": typeFilter}).toList();
      }
      return Globals.db!.getEventsByQuery(query: query, filterOldEvents: false);
    }
    return Globals.db!.getSomeEvents(length, typeFilter);
  }

  Future<List<Event>> nextOnline(int length, String? typeFilter) {
    return Globals.db!.getSomeEventsOnline(length, typeFilter);
  }
}
