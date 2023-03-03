import 'dart:async';
import 'package:havruta_project/DataBase_auth/Event.dart';
//import 'dart:math';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/Events/Events.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';

/// class to get events(lessons) data as stream-like object
/// pullingLogic is control what functions will be called, if needed (when refreshing, for example)
class EventsModel {
  Stream<List<Event>>? stream;
  late bool hasMore;
  String? searchData;
  String? typeFilter;
  late bool _isLoading;
  List<Event>? _data;
  int startPageLimit;
  int? _currPageLimit;
  int? _currSkip; // => _currPage * pageLimit;
  late StreamController<List<Event>?> _controller;
  bool? _onlineBit;
  late PullingLogic _pullingLogic;

  // the reason why pagelimit = 40 ,
  // so wont happen that empty rslt will returned and hasMore will set to false
  // I think limit will limit but, may be fetch 10(limit at server) and limit 2(at client)
  // so if some result ignored (like old dates) it's a problem, I assume each big number that problem won't be,
  // or another mechanic need to be done? like increasing limit <= 4*startPageLimit?
  EventsModel(bool online,
      {PullingLogic? logic,
      bool refreshNow = false,
      this.startPageLimit = 40}) {
    this._currPageLimit = startPageLimit;
    this._currSkip = 0;
    this._pullingLogic = logic ?? PullingLogic();
    _data = [];
    _controller = StreamController<List<Event>?>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<Event>? postsData) {
      return postsData!.map((Event eventData) {
        return eventData;
      }).toList();
    });
    hasMore = true;
    _onlineBit = online;
    if (refreshNow) {
      refresh();
    }
  }

  Future<List<Event>> _getExampleServerData(int length) async {
    // print(searchData + 'db');
    if (searchData != null) {
      return Future.delayed(MyConsts.defaultDelay, () {
        final String? tmp = searchData;
        if (tmp == null) {
          return Future.value([]);
        }
        return this._pullingLogic.search(length, tmp, typeFilter);
      });
    }
    if (_onlineBit == true) {
      //return Future.delayed(MyConsts.defaultDelay, () {
      // right now _onlineBit <> recommendation system; constant list(in Globals)
      // (which even not taking account live/online lecture)
      this.hasMore = false;
      return this._pullingLogic.nextOnline(length, typeFilter);
      //});
    }
    return Future.delayed(MyConsts.defaultDelay, () {
      return this._pullingLogic.next(length, this, typeFilter);
    });
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  bool _needToRefresh = false;
  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData) {
      //|| searchData != null) {
      //?//             _needToRefresh = true;       //?//
      _currPageLimit = startPageLimit;
      _currSkip = 0;
      _data = [];
      hasMore = true;
    }
    if ((_isLoading || !hasMore)) {
      //&& searchData != null) {
      return _needToRefresh
          ? Future.delayed(MyConsts.defaultDelay, refresh)
          : Future.value();
    }
    _needToRefresh = false;
    _isLoading = true;
    _pullingLogic.pageLimit = _currPageLimit!;
    //return _getExampleServerData(_data!.length).then((postsData) {
    return _getExampleServerData(_currSkip!).then((postsData) {
      _data!.addAll(postsData);
      hasMore = hasMore && postsData.length > 0;
      bool maybeUnFinishedCases = _pullingLogic.createdBy == null &&
          _pullingLogic.withParticipant == null &&
          _onlineBit! == false;
      // even in created by != null, it uses the search api (if search!=null)so if fetch part..part
      maybeUnFinishedCases = maybeUnFinishedCases || searchData != null;
      maybeUnFinishedCases =
          _pullingLogic.withParticipant2 != null || maybeUnFinishedCases;
      // even on fail we know to move-on (even when not maybeUnFinishedCases )
      _currSkip = _currSkip! + _currPageLimit!;
      if (hasMore && maybeUnFinishedCases) {
        _currPageLimit = startPageLimit;
      } else if (_currPageLimit! < 4 * startPageLimit && maybeUnFinishedCases) {
        // increasing data(always...) <= 4 meaning 5 fetch[1,2,3,4,5]*startPageLimit
        // _currPageLimit = _currPageLimit! + startPageLimit;
        // but here, huge data, but only 2 fetch [1,4]*startPageLimit
        _currPageLimit = 4 * startPageLimit;
        //give one more try ***
        hasMore = true;
      }
      _controller.add(_data);
      _isLoading = false;
      // *** no need - Future.delayed(MyConsts.defaultDelay, () => loadMore());
      // since the "טוען" will also auto load more
    });
  }
}

class EventsModelMultiFilter extends EventsModel {
  EventsModel _emNew =
      EventsModel(false, refreshNow: false, logic: PullingLogic());
  EventsModel _emJoined = EventsModel(false,
      refreshNow: false,
      logic: PullingLogic(withParticipant: Globals.currentUser!.email));
  EventsModel _emCreated = EventsModel(false,
      refreshNow: false,
      logic: PullingLogic(
        createdBy: Globals.currentUser!.email,
      ));
  EventsModel _emOnlyReq = EventsModel(false,
      refreshNow: false,
      logic: PullingLogic(
        createdBy: Globals.currentUser!.email,
        onlyReq: true,
      ));
  late EventsModel _emCurr;
  int delme = 0;
  EventsModelMultiFilter({bool refreshNow = false})
      : super(false, refreshNow: false) {
    _emCurr = _emNew;
    _controller = StreamController<List<Event>?>.broadcast();
    stream = _controller.stream.map((List<Event>? postsData) {
      return postsData!.map((Event eventData) {
        return eventData;
      }).toList();
    });
    if (refreshNow) {
      refresh();
    }
  }

  late StreamController<List<Event>?> _controller;

  Stream<List<Event>>? stream;

  bool get hasMore => _emCurr.hasMore;
  //set hasMore(bool x) => _emCurr.hasMore = x;

  String? searchData;

  String? typeFilter;

  Map<EventsFilter, bool> filter = Map.of(EventsFilters.NoFilter);
  EventsModel _chooseEm() {
    var tmp = _emCurr;
    tmp = EventsFilters.test(filter, EventsFilters.ToNewEvents, false)! == true
        ? _emNew
        : tmp;
    tmp = EventsFilters.test(filter, EventsFilters.ToIcreated, false)! == true
        ? _emCreated
        : tmp;
    tmp = EventsFilters.test(filter, EventsFilters.ToIjoined, false)! == true
        ? _emJoined
        : tmp;
    tmp = EventsFilters.test(filter, EventsFilters.ToPendingHavReq, false)! ==
            true
        ? _emOnlyReq
        : tmp;
    typeFilter = EventsFilters.test(filter, EventsFilters.ToHav, false)! == true
        ? "H"
        : typeFilter;
    typeFilter =
        EventsFilters.test(filter, EventsFilters.ToShiur, false)! == true
            ? "L"
            : typeFilter;
    typeFilter =
        EventsFilters.test(filter, EventsFilters.ToShiurAndHav, false)! == true
            ? null
            : typeFilter;

    _emCurr = tmp;
    return tmp;
    //EventsFilters.
  }

  Future<void> loadMore({bool clearCachedData = false}) async {
    var tmp = _chooseEm()
      ..searchData = searchData
      ..typeFilter = typeFilter;
    var next = tmp.stream!.first;
    await tmp.loadMore(clearCachedData: clearCachedData);
    _controller.add(await next);
    //await tmp.stream!.drain();
    //_controller.add([]);
  }

  Future<void> refresh() => loadMore(clearCachedData: true);
}

// helper class to decide how to pull the data about events from the db
// for now, old events are filtered if this is general, and not filtered if it's specific for the user
class PullingLogic {
  int pageLimit = 10;
  bool onlyReq;
  String?
      withParticipant; // email,   checks in both waitingQueue & participants
  String? withParticipant2; // mention withParticipant2, for cross ;
  // then check where both joined, or one is creator and other waiting*/joined,
  // but not reveal that thay both in waitingQueue for third person
  // * because withWaitingQueue=true
  String? createdBy; // email
  PullingLogic(
      {this.withParticipant,
      this.createdBy,
      this.withParticipant2,
      this.onlyReq = false})
      : assert((createdBy == null || withParticipant == null) &&
            (withParticipant2 == null || withParticipant != null) &&
            (!onlyReq || createdBy != null));
  Future<List<Event>> search(
      int length, String searchData, String? typeFilter) {
    // this.withParticipant: both waitingQueue & participants (if withParticipant!= null)
    // because  withWaitingQueue: true,
    return Globals.db!.searchEvents(searchData,
        filterOldEvents: this.withParticipant == null && this.createdBy == null,
        maxEvents: pageLimit,
        startFrom: length,
        withParticipant: this.withParticipant,
        withParticipant2: this.withParticipant2,
        withWaitingQueue: true,
        createdBy: this.createdBy,
        onlyReq: onlyReq,
        typeFilter: typeFilter);
  }

  Future<List<Event>> next(int length, EventsModel model, String? typeFilter) {
    if (withParticipant2 != null) {
      //model.hasMore = false;
      return Globals.db!.cross(
          maxEvents: pageLimit,
          startFrom: length,
          withParticipant: withParticipant!,
          withParticipant2: withParticipant2!,
          typeFilter: typeFilter,
          filterOldEvents: false);
    }
    if (withParticipant != null) {
      // right now, get events returns ALL events,with no filter for time
      // so in order to avoid infinite addition to the stream:
      model.hasMore = false;
      // even if getEvens will return only few, still there is race problem
      // this.withParticipant: both waitingQueue & participants (if withParticipant!= null)
      return Globals.db!.getEvents(withParticipant, false, typeFilter);
    } else if (createdBy != null) {
      model.hasMore = false;

      var prefix = where.eq("creatorUser", createdBy);
      prefix = !onlyReq
          ? prefix
          : prefix.ne("waitingQueue", null).ne("waitingQueue", []);
      prefix = typeFilter == null ? prefix : prefix.eq("type", typeFilter);
      var query = (collection) async => await collection.find(prefix).toList();
      return Globals.db!.getEventsByQuery(query: query, filterOldEvents: false);
    }
    return Globals.db!.getSomeEvents(length, typeFilter, limit: pageLimit);
  }

  Future<List<Event>> nextOnline(int length, String? typeFilter) async {
    //return Globals.db!.getSomeEventsOnline(length, typeFilter);
    return (await Globals.rec.waitData() ?? []);
  }
}
