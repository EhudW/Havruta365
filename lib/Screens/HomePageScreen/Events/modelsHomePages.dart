import 'dart:async';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/EventsSelectorBuilder.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/HomePageScreen/Events/Events.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';

String? shiurHavTypeOf(Map boolMapFilters) {
  if (EventsFilters.test(EventsFilters.ToHav, boolMapFilters)!) return 'H';
  if (EventsFilters.test(EventsFilters.ToShiur, boolMapFilters)!) return 'L';
  return null;
}

/// class to get events(lessons) data as stream-like object
class EventsModel {
  Stream<List<Event>>? stream;
  late bool hasMore;
  //String? searchData;
  //String? typeFilter;
  late Map filterData;
  late bool _isLoading;
  List<Event>? _data;
  int startPageLimit;
  int? _currPageLimit;
  int? _currSkip; // => _currPage * pageLimit;
  late StreamController<List<Event>?> _controller;
  bool? _onlineBit;

  // the reason why pagelimit = 40 ,
  // so wont happen that empty rslt will returned and hasMore will set to false
  // I think limit will limit but, may be fetch 10(limit at server) and limit 2(at client)
  // so if some result ignored (like old dates) it's a problem, I assume each big number that problem won't be,
  // or another mechanic need to be done? like increasing limit <= 4*startPageLimit?
  EventsModel(bool online,
      {bool refreshNow = false,
      this.startPageLimit = 40,
      Map<String, dynamic> modelData = const {}}) {
    this.filterData = logicMap()..addAll(modelData);
    this._currPageLimit = startPageLimit;
    this._currSkip = 0;
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

  static Map<String, dynamic> logicMap({
    Map<EventsFilters, bool>? BoolMapFilters,
    String? search,
    String? withParticipant,
    String? withParticipant2,
    String? createdBy,
    //bool onlyReq = false,
    //bool filterOldEvents = true,
    // eventTesters return null / the origin event / modified event / new event
    List<Event? Function(Event)> testers = const [],
    //bool withWaitingQueue = true,
  }) {
    return {
      "createdBy": createdBy,
      "testers": testers,
      //"filterOldEvents": filterOldEvents,
      //"onlyReq": onlyReq,
      "search": search,
      "BoolMapFilters": BoolMapFilters ?? EventsFilters.NoFilter,
      "withParticipant2": withParticipant2,
      "withParticipant": withParticipant,
      //"withWaitingQueue": withWaitingQueue
    };
  }

  bool shouldFetchAll() {
    if (filterData["withParticipant2"] != null) return true;
    if (filterData["withParticipant"] != null) return true;
    if (filterData["createdBy"] != null) return true;
    if (_onlineBit!) return true;
    if (filterData["search"] != null) return false;
    return false;
  }

  int? shouldFetchAllUsing(int? val) {
    return shouldFetchAll() ? null : val;
  }

  Future<List<Event>> _getExampleServerData() async {
    final _filterData = filterData;
    bool onlyReq = EventsFilters.test(
        EventsFilters.ToPendingHavReq, _filterData["BoolMapFilters"])!;
    // can't force to be part of my own lecture(assuming withParticipant - myMail/null)
    assert((_filterData["createdBy"] == null ||
        _filterData["withParticipant"] == null));
    // withParticipant-myMail 2-other person
    assert((_filterData["withParticipant2"] == null ||
        _filterData["withParticipant"] != null));
    // onlyReq is only when I look for my own hav
    assert((!onlyReq || _filterData["createdBy"] != null));
    if (_onlineBit == true) {
      this.hasMore = false;
      return (await Globals.rec.waitData() ?? []);
    }
    return Future.delayed(MyConsts.defaultDelay, () {
      return EventsSelectorBuilder.fetchFrom(
        createdBy: _filterData["createdBy"],
        eventTesters: _filterData["testers"] ?? [],
        filterOldDates: true,
        //filterOldEvents: filterData["filterOldEvents"],
        filterOldEvents: (_filterData["createdBy"] == null &&
                _filterData["withParticipant"] == null) ||
            onlyReq, //dont show old req
        maxEvents: shouldFetchAllUsing(_currPageLimit),
        newestFirst: true,
        onlyReq: onlyReq,
        search: _filterData["search"],
        startFrom: shouldFetchAllUsing(_currSkip),
        typeFilter: shiurHavTypeOf(_filterData["BoolMapFilters"]),
        withParticipant2: _filterData["withParticipant2"],
        withParticipant: _filterData["withParticipant"],
        withWaitingQueue: true, //_filterData["withWaitingQueue"],
        // don't show rejected as 'my classes', but show it in cross mode(where I\Him the lecturer of the havruta)
        withRejectedLeftQueue: _filterData["withParticipant2"] != null,
        // cross mode -> withRejectedLeftQueue = true, so null filter on rejectedQueue
        // only created / myevents filter / all events then filter where I was rejected
        ensureNotRejected: _filterData["withParticipant2"] != null
            ? null
            : _filterData["withParticipant"],
      );
    });
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  bool _needToRefresh = false;
  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData) {
      //?//             _needToRefresh = true;       //?//
      _currPageLimit = startPageLimit;
      _currSkip = 0;
      _data = [];
      hasMore = true;
    }
    if ((_isLoading || !hasMore)) {
      return _needToRefresh
          ? Future.delayed(MyConsts.defaultDelay, refresh)
          : Future.value();
    }
    _needToRefresh = false;
    _isLoading = true;
    return _getExampleServerData().then((postsData) {
      _data!.addAll(postsData);
      bool maybeUnFinishedCases = !shouldFetchAll();
      hasMore = hasMore && postsData.length > 0 && maybeUnFinishedCases;
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
