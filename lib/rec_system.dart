// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'DataBase_auth/EventsSelectorBuilder.dart';

/// RecommendationSystem
///       abstract class RecommendationSystem<T> [interface]
///       class MultiRecommendationSystem<T> extends RecommendationSystem<T> [combine systems]
///       class CriticMyEvents<O> [rank feature by Appearance]
///       class MultiConsiderations extends RecommendationSystem<Event> [system for ranking feature by Appearance]
///       class ByEventSuccess extends RecommendationSystem<Event> [rank event by 'success'(participants)]
///       class ExampleRecommendationSystem [basic use of above classes(see the class)]
/// Evalution
///       enum ModelEvalutionMethod [for  ModelEvalution.calcRange(k)]
///       abstract class ModelEvalution<T> [interface]
///       class EventModelEvaluation extends ModelEvalution<Event> [implentation for evaluate Event rec system]
///       void testEventsRecommendation() ["heavy" method to test p@k & mrr over all users in mongodb]

////////////////////////////////////
////////////////////////////////////
///      RecommendationSystem
////////////////////////////////////
////////////////////////////////////

// RecommendationSystem<T> r = ...
// r.setData({...});
// await r.calc();
// r.getTop();
abstract class RecommendationSystem<T> {
  Map<String, dynamic>? data;
  void setData(Map<String, dynamic> data) {
    this.data = data;
  }

  // true on success; false on error
  // topAmount for maybe optimizing fast calc
  // calc().topAmount should be <= possible recommendations
  Future<bool> calc([int? topAmount]);

  // getTop()[0] is the most recommended
  // getTop().amount should be <= calc().topAmount
  List<T> top = [];
  List<T> getTop([int amount = 10]) {
    return top.sublist(0, amount <= top.length ? amount : top.length);
  }
}

class MultiRecommendationSystem<T> extends RecommendationSystem<T> {
  List<RecommendationSystem<T>> systems;
  List<int> weights;
  int topAmount;
  MultiRecommendationSystem({
    required this.systems,
    required this.weights,
    required this.topAmount,
  })  : assert(weights.length == systems.length),
        assert(
            (weights.reduce((value, element) => value + element) == topAmount));

  @override
  void setData(Map<String, dynamic> data) {
    super.setData(data);
    systems.forEach((sys) {
      sys.setData(data);
    });
  }

  @override
  Future<bool> calc([int? topAmount]) {
    assert(topAmount == null || topAmount == this.topAmount);

    var results =
        Future.wait(systems.map((e) => e.calc())).onError((error, stackTrace) {
      return [false];
    });
    var asOneResult = results.then((list) {
      return list.every((element) => element);
    });
    return asOneResult;
  }

  @override
  List<T> getTop([int amount = 10]) {
    assert(amount == topAmount);
    this.top = [];
    for (int i = 0; i < systems.length; i++) {
      this.top.addAll(systems[i].getTop(weights[i]));
    }
    return super.getTop(amount);
  }

  List<List<T>> getTops() {
    List<List<T>> tops = [];
    for (int i = 0; i < systems.length; i++) {
      tops.add(<T>[]);
      tops[i].addAll(systems[i].getTop(weights[i]));
    }
    return tops;
  }
}

// helper class for recommendation for Event
// due to my Events, test what option[O] in ONE feature[F] I liked the most (exactly ==)
class CriticMyEvents<O> {
  int _total = 0;
  String? field;
  List<Event> myEvents;
  Map<O, double> rank = {};
  O Function(Event)? classify;
  List<O> Function(Event)? classifyList;
  num weight;
  CriticMyEvents(
      {this.field, // not needed for calc
      required this.myEvents,
      required this.classify,
      required this.classifyList,
      this.weight = 1.0}) {
    _calc();
    _norm(soft: 1);
  }

  void _calc() {
    myEvents.forEach((element) {
      if (classifyList != null) {
        var indexes;
        try {
          indexes = classifyList!(element);
        } catch (e) {
          return;
        }
        for (var idx in indexes) {
          rank[idx] = (rank[idx] ?? 0) + 1;
          _total++;
        }
      } else if (classify != null) {
        var idx;
        try {
          idx = classify!(element);
        } catch (e) {
          return;
        }
        _total++;
        rank[idx] = (rank[idx] ?? 0) + 1;
      }
    });
  }

  void _norm({int? soft}) {
    if (_total == 0) {
      return;
    }
    _total += soft ?? 0;
    for (var option in List.of(rank.keys)) {
      rank[option] = rank[option]! / _total * weight;
    }
    _total -= soft ?? 0;
  }

  Map<Event, double> rankOtherEvents(List<Event> events) {
    return Map.fromIterable(events, value: (element) {
      var evaluate = 0.0;
      if (classifyList != null) {
        var indexes;
        try {
          indexes = classifyList!(element);
          for (var idx in indexes) {
            var val = (rank[idx] ?? 0.0);
            evaluate = val > evaluate ? val : evaluate;
          }
        } catch (e) {}
      } else if (classify != null) {
        var idx;
        try {
          idx = classify!(element);
          evaluate = (rank[idx] ?? 0.0);
        } catch (e) {}
      }
      return evaluate;
    });
  }
}

// check if there is overlap between 2 times
bool rangesOverlap(List<double> rangeA, List<double> rangeB, [double? modulo]) {
  double a = rangeA.first;
  double b = rangeA.last;
  double x = rangeB.first;
  double y = rangeB.last;
  assert(b >= a && y >= x);
  //            x------y
  //        a------b
  //    x------y
  // moudulo
  //                         x------y
  //              a------b
  //    x------y
  //
  var option1 = (a, x, b) {
    while (x < a && modulo != null) {
      x += modulo;
    }
    return a <= x && x <= b;
  };
  var option2 = (a, x, b) {
    while (x > b && modulo != null) {
      x -= modulo;
    }
    return a <= x && x <= b;
  };
  between(a, x, b) => option1(a, x, b) || option2(a, x, b);
  return between(a, x, b) || between(x, a, y);
}

bool rangeDateOverlap(List<double> rangeA, DateTime d, int duration) {
  double h = d.toLocal().hour + d.toLocal().minute / 60;
  return rangesOverlap(rangeA, [h.toDouble(), (h + duration / 60)], 24);
}

enum PartOfDay {
  hour0to4,
  hour4to8,
  hour8to12,
  hour12to16,
  hour16to20,
  hour20to24
}

List<PartOfDay> getPartsOfDayOf(DateTime d, int duration) {
  List<PartOfDay> rslt = [];
  for (List l in [
    [PartOfDay.hour0to4, 0, 4],
    [PartOfDay.hour4to8, 4, 8],
    [PartOfDay.hour8to12, 8, 12],
    [PartOfDay.hour12to16, 12, 16],
    [PartOfDay.hour16to20, 16, 20],
    [PartOfDay.hour20to24, 20, 24],
  ]) {
    if (rangeDateOverlap([l[1].toDouble(), l[2].toDouble()], d, duration)) {
      rslt.add(l[0]);
    }
  }
  return rslt;
}

class MultiConsiderations extends RecommendationSystem<Event> {
  // auto filtered by EvenesSelectorBuildder.targetForMe()
  static Future<List<Event>> getAllEvents([int maxEvents = 100]) =>
      EventsSelectorBuilder.fetchFrom(
          startFrom: 0,
          maxEvents: maxEvents,
          filterOldEvents: true,
          filterOldDates: true,
          newestFirst: true,
          withRejectedQueue: false // useless since withParticipant == null
          );
  //Globals.db!.getSomeEvents(0, null, limit: 100, newestFirst: true);
  static Future<List<Event>> getMyEvents(String myMail,
          {bool filterOld = false}) =>
      // Globals.db!.getEvents(myMail, false, null);
      EventsSelectorBuilder.fetchFrom(
          withParticipant: myMail,
          filterOldDates: filterOld,
          filterOldEvents: filterOld,
          maxEvents: null,
          startFrom: null,
          withWaitingQueue: true,
          withRejectedQueue:
              false // don't consider those events, not for good, not for bad
          );
  // won't check isTargetedForMe
  static bool thisEventIsNewForMeAndAvailable(
      Event e, String myMail, DateTime timeNow) {
    if ((e.participants ?? []).length /*+ (e.waitingQueue ?? []).length*/ >=
        (e.maxParticipants ?? 0)) {
      return false;
    }
    bool isNew = true;
    isNew = isNew && e.creatorUser != myMail;
    bool timeIsNew = false;
    for (DateTime d in e.dates!) {
      var timeIsOld =
          timeNow.subtract(Duration(minutes: e.duration ?? 0)).isAfter(d);
      if (!timeIsOld) {
        timeIsNew = true;
        break;
      }
    }
    isNew = isNew && timeIsNew;
    isNew = isNew && !(e.participants ?? []).contains(myMail);
    isNew = isNew && !(e.waitingQueue ?? []).contains(myMail);
    isNew = isNew && !e.rejectedQueue.contains(myMail);
    isNew = isNew && !e.leftQueue.contains(myMail);
    return isNew;
  }

  static List<Event> getSortedList(Map<Event, double> rank) {
    var list = List.of(rank.keys);
    // b,a instead of a,b so the higher is in the beginning
    list.sort((b, a) => (rank[a] ?? 0.0).compareTo((rank[b]) ?? 0.0));
    return list;
  }

  MultiConsiderations({
    Future<List<Event>>? compareToMe,
    Future<List<Event>>? possibleEvents,
    String? myMail,
    bool saveLastRank = false,
    bool clearCacheAfter = true,
  }) {
    setData({
      "compareToMe": compareToMe,
      "possibleEvents": possibleEvents,
      "myMail": myMail,
      "saveLastRank": saveLastRank,
      "clearCacheAfter": clearCacheAfter,
    });
  }
  static Map<String, User> _users_cache = {};
  Map<Event, double> last_rank = {};
  static void clear_cache() => _users_cache.clear();
  Future<Map<Event, double>> calcTotalRank(
      List<Event> possibleEvents, List<Event> compareToMe) {
    ///
    var whoTeacher = (Event e) => e.lecturer?.trim() != ""
        ? e.lecturer!.trim().toLowerCase()
        : e.creatorName!.trim().toLowerCase();
    var uniqueString = (String? x) {
      x = x?.toLowerCase().trim() ?? "";
      return x == "" ? UniqueKey().toString() : x;
    };

    var fillUsersCache = (List<Event> list) async {
      for (Event e in list) {
        for (String user in e.participants ?? []) {
          _users_cache[user] = _users_cache[user] ?? await getUser(user);
        }
        for (String user in e.waitingQueue ?? []) {
          _users_cache[user] = _users_cache[user] ?? await getUser(user);
        }
      }
    };

    /// for rank for specific target group (people who preffer small/big lecture, etc..)
    var considerationsFactory = (events) => [
          /* need await fillUsersCache()
          // by how age of others are similiar to my age
          {"classify":
            (Event e) {
              double total = 0.0;
              var thisYear = DateTime.now().year;
              var both = (e.participants ?? []) + (e.waitingQueue ?? []);
              for (String user in both) {
                total += thisYear - users_cache[user]!.birthDate!.year;
              }
              double diff = total / both.length -
                  (thisYear - Globals.currentUser!.birthDate!.year);
              diff = diff > 0 ? diff : -diff;
              if (both.length == 1) {
                // only me
                return UniqueKey().toString();
              }
              return diff > 10 ? ">10" : (diff > 5 ? "5-10" : "<5");
            },
            "weight":1,
            },
          // by what is the status of the majority of others
          {"classify":
            (Event e) {
              Map<String, int> status_count = {};
              var both = (e.participants ?? []) + (e.waitingQueue ?? []);
              for (String user in both) {
                var s = users_cache[user]!.status!;
                status_count[s] = (status_count[s] ?? 0) + 1;
              }
              String? max = status_count.keys.fold(
                  null,
                  (previousValue, element) => previousValue != null
                      ? (status_count[previousValue]! >= status_count[element]!
                          ? previousValue
                          : element)
                      : element);
              if (both.length == 1) {
                // only me
                return UniqueKey().toString();
              }
              return max ?? UniqueKey().toString();
            },
            "weight":1,
            },
          */
          // by part of day
          {
            "classifyList":
                // (Event e) => getPartsOfDayOf(e.dates!.first, e.duration ?? 0),
                (Event e) {
              List rslt = [];
              int duration = e.duration ?? 0;
              e.dates!.forEach(
                  (time) => rslt.addAll(getPartsOfDayOf(time, duration)));
              return rslt;
            },
            "weight": 1,
          },
          // by who is the creator
          {
            "classify": (Event e) => e.creatorUser!,
            "weight": 2,
          },
          // by who are the people with me
          {
            "classifyList": (Event e) => e.participants ?? [],
            "weight": 1,
          },
          // by what is the book
          {
            "classify": (Event e) => uniqueString(e.book),
            "weight": 2,
          },
          // by who is the teacher
          {
            "classify": whoTeacher,
            "weight": 1,
          },
          // by what is the topic
          {
            "classify": (Event e) => uniqueString(e.topic),
            "weight": 1.5,
          },
          // by if it is havruta or shiur
          {
            "classify": (Event e) => e.type!.toLowerCase(),
            "weight": 1,
          },
          // by what day it takes place
          {
            "classifyList": (Event e) =>
                e.dates?.map((d) => d.toLocal().weekday).toList() ?? [],
            "weight": 1,
          },
          // by the duration of the class
          {
            "classify": (Event e) {
              if (e.duration == null || e.duration! <= 30) {
                return "0-30";
              } else if (e.duration! > 60) {
                return "61+";
              }
              return "31-60";
            },
            "weight": 1,
          },
          // by the size of the class
          {
            "classify": (Event e) => e.maxParticipants! >= 10 ? ">=10" : "<10",
            "weight": 1,
          },
          // by its target gender(to both gender? only mine?)
          {
            "classify": (Event e) => e.targetGender?.toLowerCase(),
            "weight": 1,
          },
          // by its target status
          {
            "classify": (Event e) => e.onlyForStatus,
            "weight": 1,
          },
          // by its target min age
          {
            "classify": (Event e) {
              int min = 0;
              //int max = 120;
              for (int i = 0; i < 121; i += 10) {
                if (i <= e.minAge) min = i;
                //if (120 - i >= e.maxAge) max = i;
              }
              return min; //"$min,$max";
            },
            "weight": 1,
          },
          // by its location
          {
            "classify": (Event e) => uniqueString(e.location),
            "weight": 1,
          },
          // by if it has a link (The user don't know until the time=live),
          // but probably online lessons has link
          {
            "classify": (Event e) =>
                (e.link?.trim() ?? "") != "" ? true : false,
            "weight": 0.5,
          },
        ]
            .map((e) => CriticMyEvents(
                classify: e["classify"] as dynamic Function(Event)?,
                classifyList:
                    e["classifyList"] as List<dynamic> Function(Event)?,
                weight: e["weight"] as num? ?? 1.0,
                myEvents: events))
            .toList();

    var getTotalRank =
        (List<Event> possibleEvents, List<Event> compareToMe) async {
      var considerations = considerationsFactory(compareToMe);
      // very heavy(100 events can have 2000 users)
      // await fillUsersCache(possibleEvents);
      // await fillUsersCache(compareToMe);
      Map<Event, double> totalRank = {};
      for (CriticMyEvents partOfRank in considerations) {
        var part = partOfRank.rankOtherEvents(possibleEvents);
        for (Event event in part.keys) {
          totalRank[event] = (totalRank[event] ?? 0.0) + part[event]!;
        }
      }
      return totalRank;
    };
    return getTotalRank(possibleEvents, compareToMe).then((value) {
      this.last_rank = this.data!["saveLastRank"] ? value : last_rank;
      return value;
    }).whenComplete(() => this.data!["clearCacheAfter"] ? clear_cache() : null);
  }

  @override
  Future<bool> calc([int? topAmount]) async {
    bool success = true;
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
    var possibleEvents = await ((this.data?['possibleEvents'] ?? getAllEvents())
        .catchError((error) {
      success = false;
      return [];
    }));
    if (!success) {
      return success;
    }
    var myMail = data!["myMail"] ?? Globals.currentUser!.email!;
    var compareToMe = await ((this.data?['compareToMe'] ?? getMyEvents(myMail))
        .catchError((error) {
      success = false;
      return [];
    }));

    if (!success) {
      return success;
    }
    var timeNow = DateTime.now();
    // won't check isTargetedForMe, assuming given possibleEvents might filtered by it, if needed
    this.top = getSortedList(await calcTotalRank(possibleEvents, compareToMe))
        .where((Event e) => thisEventIsNewForMeAndAvailable(e, myMail, timeNow))
        .toList();
    return success;
  }
}

class ByEventSuccess extends RecommendationSystem<Event> {
  // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
  static Future<List<Event>> getAllEvents() =>
      MultiConsiderations.getAllEvents();
  static Future<List<Event>> getMyEvents(String myMail) =>
      MultiConsiderations.getMyEvents(myMail);

  ByEventSuccess({
    Future<List<Event>>? possibleEvents,
    String? myMail,
  }) {
    setData({"possibleEvents": possibleEvents, "myMail": myMail});
  }
  Future<bool> calc([int? topAmount]) async {
    bool success = true;
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
    var possibleEvents = await ((this.data?['possibleEvents'] ?? getAllEvents())
        .catchError((error) {
      success = false;
      return [];
    }));
    if (!success) {
      return success;
    }
    Map<Event, double> rank = Map.fromIterable(
      possibleEvents,
      value: (element) => 0.0,
    );
    // rank Event by:
    // how much participants there are
    for (Event event in rank.keys) {
      // ignoring rejectedQueue, but waiting do teach us, so rank could be > 1
      int amount =
          (event.participants?.length ?? 0) + (event.waitingQueue?.length ?? 0);
      int soft =
          ((event.maxParticipants ?? 0) > 0 ? event.maxParticipants! : 100);
      soft++;
      rank[event] = rank[event]! + amount / soft;
    }

    var myMail = data!["myMail"] ?? Globals.currentUser!.email!;
    var timeNow = DateTime.now();
    // won't check isTargetedForMe, assuming given possibleEvents might filtered by it, if needed
    this.top = MultiConsiderations.getSortedList(rank)
        .where((Event e) => MultiConsiderations.thisEventIsNewForMeAndAvailable(
            e, myMail, timeNow))
        .toList();
    return success;
  }
}

// RecommendationSystem<T> r = ExampleRecommendationSystem.create();
// bool success = await r.calc();
// if (success) {
//  var top10events = r.getTop();
// } else ...
//
// or just:
// var top10events = await ExampleRecommendationSystem.calcAndGetTop10();

class ExampleRecommendationSystem {
  static MultiRecommendationSystem<Event> create(String myMail) {
    var myEvents = MultiConsiderations.getMyEvents(myMail);
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
    var allEvents = MultiConsiderations.getAllEvents();
    var data = {
      "compareToMe": myEvents,
      "possibleEvents": allEvents,
      "myMail": myMail,
      "clearCacheAfter": true,
      "saveLastRank": false,
    };
    var rslt = MultiRecommendationSystem<Event>(
        systems: [MultiConsiderations(), ByEventSuccess()],
        topAmount: 20,
        // 10 for each, so even if both will give same top10, we will have 10 unique events
        weights: [10, 10]);
    rslt.setData(data);
    return rslt;
  }

  static Future<List<Event>> calcAndGetTop10(String myMail,
      {bool suppressException: true}) async {
    MultiRecommendationSystem<Event> r =
        ExampleRecommendationSystem.create(myMail);
    return r.calc().then((success) {
      if (!success && !suppressException) {
        throw Exception("ExampleRecommendationSystem failed");
      }
      // from list of some recommendations (matrix)  [[..] [..]]
      List<List<Event>> eventsLists = r.getTops();
      Set<ObjectId> eventsSet = Set();
      List<Event> events = [];
      int maxLen = eventsLists.fold(
          0,
          (previousValue, oneList) =>
              previousValue > oneList.length ? previousValue : oneList.length);
      // add to events (flattened array), max 10 events
      for (int n = 0;
          n < maxLen * eventsLists.length && events.length < 10;
          n++) {
        int i = n % eventsLists.length;
        var list = eventsLists[i];
        int j = (n / eventsLists.length).floor();
        //each event must be unique
        if (list.length > j && !eventsSet.contains(list[j].id)) {
          events.add(list[j]);
          eventsSet.add(list[j].id);
        }
      }
      // return flattened array of unique events , combined [ [1,2] [a,b,c] ] -> [1,a,2,b,c] ,
      //(max 10, but probably so, because in create() we asked each system for 10)
      return events;
    });
  }
}

///////////////////////////
///////////////////////////
/// Evalution
///////////////////////////
///////////////////////////
enum ModelEvalutionMethod { PrecisionK, RecallK, MRR, ARHR, MAE, RMSE }

abstract class ModelEvalution<T> {
  static final double inf = 1.0 / 0.0;
  static Map<ModelEvalutionMethod, List<double>> calcRange(int k) {
    var sum = 0.0;
    for (int i = 1; i <= k; i++) {
      sum += 1 / k;
    }
    return {
      ModelEvalutionMethod.PrecisionK: [0, 1],
      ModelEvalutionMethod.RecallK: [0, 1],
      ModelEvalutionMethod.MRR: [0, 1],
      ModelEvalutionMethod.ARHR: [0, sum],
      ModelEvalutionMethod.MAE: [0, ModelEvalution.inf],
      ModelEvalutionMethod.RMSE: [0, ModelEvalution.inf],
    };
  }

  // #hit&prediction / #prediction
  double precision_k_one_user(List<T> prediction, List<T> hit, int? fixedK);
  double precision_k(List<List<List<T>>> prediction_hits, int? fixedK);
  double precision_k_ver2(List<List<List<T>>> prediction_hits, int? fixedK) {
    double val_so_far = 0.0;
    for (var pair in prediction_hits) {
      val_so_far += precision_k_one_user(pair[0], pair[1], fixedK) /
          prediction_hits.length;
    }
    return val_so_far;
  }

  // #hit&prediction / #hits
  double recall_k_one_user(List<T> prediction, List<T> hits, int? fixedK);
  double recall_k(List<List<List<T>>> prediction_hits, int? fixedK);
  double recall_ver2(List<List<List<T>>> prediction_hits, int? fixedK) {
    double val_so_far = 0.0;
    for (var pair in prediction_hits) {
      val_so_far +=
          recall_k_one_user(pair[0], pair[1], fixedK) / prediction_hits.length;
    }
    return val_so_far;
  }

  // sum(1/(k*#users) for all hits for all users)
  double MRR(List<List<List<T>>> prediction_hits, int? fixedK);
  // sum(1/(j*#users) for all hits that predicted at pos j for all users)
  // pos j = human index which start from 1
  double ARHR(List<List<List<T>>> prediction_hits, int? fixedK);
  dynamic getDiff(dynamic tblA, dynamic tblB);
  double MAE(dynamic distanceTable);
  double RMSE(dynamic distanceTable);
}

class EventModelEvaluation extends ModelEvalution<Event> {
  // k is prediction.length => p@k = #hits_found / #predicted
  double precision_k_one_user(
      List<Event> prediction, List<Event> hits, int? fixedK) {
    assert(fixedK == null || prediction.length <= fixedK);
    Set hitsID = hits.map((e) => e.id).toSet();
    Set predictionID = prediction.map((e) => e.id).toSet();
    Set intersectionID = hitsID.intersection(predictionID);
    int n = fixedK ?? predictionID.length;
    if (n == 0) {
      return double.nan;
    }
    return intersectionID.length / n;
  }

  // k is prediction.length => r@k = #hits_found / #total_hits
  // k is prediction.length => p@k = #hits_found / #predicted
  // so r@k = p@k * #predicted / total_hits
  double recall_k_one_user(
      List<Event> prediction, List<Event> hits, int? fixedK) {
    assert(fixedK == null || prediction.length <= fixedK);
    Set hitsID = hits.map((e) => e.id).toSet();
    Set predictionID = prediction.map((e) => e.id).toSet();
    Set intersectionID = hitsID.intersection(predictionID);
    if (hitsID.length == 0) {
      return double.nan;
    }
    return intersectionID.length / hitsID.length;
  }

  @override
  double MRR(List<List<List<Event>>> prediction_hits, int? fixedK) {
    var users = prediction_hits.length;
    var rslt = 0.0;
    for (List<List<Event>> pair in prediction_hits) {
      List<Event> prediction = pair[0];
      assert(fixedK == null || prediction.length <= fixedK);
      List<Event> hits = pair[1];
      Set hitsID = hits.map((e) => e.id).toSet();
      Set predictionID = prediction.map((e) => e.id).toSet();
      Set intersectionID = hitsID.intersection(predictionID);
      rslt += intersectionID.length / (fixedK ?? predictionID.length);
    }
    return rslt / users;
  }

  @override
  double ARHR(List<List<List<Event>>> prediction_hits, int? fixedK) {
    var users = prediction_hits.length;
    var rslt = 0.0;
    for (List<List<Event>> pair in prediction_hits) {
      List<Event> prediction = pair[0];
      assert(fixedK == null || prediction.length <= fixedK);
      List<Event> hits = pair[1];
      Set hitsID = hits.map((e) => e.id).toSet();
      List predictionID = prediction.map((e) => e.id).toList();
      int k = (fixedK ?? predictionID.length);
      k = k <= predictionID.length ? k : predictionID.length;
      for (int j = 0; j < k; j++) {
        rslt += hitsID.contains(predictionID[j]) ? 1 / (j + 1) : 0;
      }
    }
    return rslt / users;
  }

  @override
  getDiff(dynamic tblA, dynamic tblB) {
    Map<ObjectId, double> a = (tblA as Map<Event, double>)
        .map((key, value) => MapEntry(key.id, value));
    Map<ObjectId, double> b = (tblB as Map<Event, double>)
        .map((key, value) => MapEntry(key.id, value));
    Set<ObjectId> both = a.keys.toSet().intersection(b.keys.toSet());
    return both.map((i) => a[i]! - b[i]!).toList();
  }

  @override
  double MAE(dynamic distanceTable) {
    return (distanceTable as List<double>)
            .fold<double>(0.0, (pre, e) => pre + e.abs()) /
        distanceTable.length;
  }

  @override
  double RMSE(distanceTable) {
    var x = (distanceTable as List<double>)
        .fold<double>(0.0, (pre, e) => pre + e * e);
    return sqrt(x / distanceTable.length);
  }

  @override
  double precision_k(List<List<List<Event>>> prediction_hits, int? fixedK) {
    // one option is to sum all precision_k_one_user And divide #users
    // second option is below:

    var rslt = 0.0;
    var totalN = 0;
    for (List<List<Event>> pair in prediction_hits) {
      List<Event> prediction = pair[0];
      assert(fixedK == null || prediction.length <= fixedK);
      List<Event> hits = pair[1];
      Set hitsID = hits.map((e) => e.id).toSet();
      Set predictionID = prediction.map((e) => e.id).toSet();
      Set intersectionID = hitsID.intersection(predictionID);
      int n = fixedK ?? predictionID.length;
      rslt += intersectionID.length;
      totalN += n;
    }
    return totalN == 0 ? double.nan : (rslt / totalN);
  }

  @override
  double recall_k(List<List<List<Event>>> prediction_hits, int? fixedK) {
    // one option is to sum all recall_k_one_user And divide #users
    // second option is below:

    var rslt = 0.0;
    var totalN = 0;
    for (List<List<Event>> pair in prediction_hits) {
      List<Event> prediction = pair[0];
      assert(fixedK == null || prediction.length <= fixedK);
      List<Event> hits = pair[1];
      Set hitsID = hits.map((e) => e.id).toSet();
      Set predictionID = prediction.map((e) => e.id).toSet();
      Set intersectionID = hitsID.intersection(predictionID);
      rslt += intersectionID.length;
      totalN += hitsID.length;
    }
    return totalN == 0 ? double.nan : (rslt / totalN);
  }
}

void testEventsRecommendation([int k = 4, int? put100IfYouSure]) async {
  // very heavy calc & internet access
  if (put100IfYouSure != 100) {
    return;
  }
  assert(k % 2 == 0);
  assert(k >= 4);
  var eval = EventModelEvaluation();
  var mongo = Globals.db!;
  var db = mongo.db as Db;
  var collection = db.collection('Users');
  var usersEmail =
      await collection.find().map((user) => User.fromJson(user).email).toList();
  // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
  var allEvents = await MultiConsiderations.getAllEvents();
  Map<String, List<Event>> user_events_validate = {};
  Map<String, List<Event>> user_events_data = {};
  Map<String, List<Event>> user_rec = {};
  List<double> alluser_distance_tbl = [];
  for (var email in usersEmail) {
    var list = await MultiConsiderations.getMyEvents(email!,
        // filterOld = true since we want the test/validate will be on same zone,
        // it isn't just recommendation but also test
        // and since we filter old events from getAllEvents, we need to do it here too...
        // or else we miss old event because they aren't in the possibleEvents=getAllEvents
        // we want:
        // [possibleRecommendation ( validate            ]   data)
        // [ getAllEvents          ( list.sublist(0,k+1) ]   list=getMyEvents.shuffle )
        // we don't want empty intersection:
        // [possibleRecommendation]     (validate              data)
        // [ getAllEvents ]             ( list.sublist(0,k+1)  list=getMyEvents.shuffle )
        // and also the systems won't recommend old events
        filterOld: true);
    if (list.length < (2 * k)) {
      continue;
    }
    list.shuffle();
    user_events_validate[email] = list.sublist(0, k + 1);
    user_events_data[email] = list.sublist(k + 1);
    var data = {
      "compareToMe": Future.value(user_events_data[email]),
      "possibleEvents": Future.value(allEvents),
      "myMail": email,
      "clearCacheAfter": false,
      "saveLastRank": true,
    };
    var system = MultiRecommendationSystem<Event>(
        systems: [MultiConsiderations(), ByEventSuccess()],
        topAmount: k,
        weights: [(k / 2).round(), (k / 2).round()]);
    system.setData(data);
    var success = await system.calc();
    if (success) {
      user_rec[email] = system.getTop();
      // distance tbl
      var mcs = system.systems[0] as MultiConsiderations;
      var A = mcs.last_rank;
      var B = await mcs.calcTotalRank(A.keys.toList(), list);
      alluser_distance_tbl.addAll(eval.getDiff(A, B));
      //mcs.last_rank.clear(); because  "saveLastRank": true,
    }
  }
  //MultiConsiderations.clear_cache(); because "clearCacheAfter": false,
  List<List<List<Event>>> prediction_hits = [];
  for (var email in user_rec.keys) {
    prediction_hits.add([user_rec[email]!, user_events_validate[email]!]);
  }
  var ranges = ModelEvalution.calcRange(k);
  var pk_range = ranges[ModelEvalutionMethod.PrecisionK];
  var rk_range = ranges[ModelEvalutionMethod.RecallK];
  var mrr_range = ranges[ModelEvalutionMethod.MRR];
  var arhr_range = ranges[ModelEvalutionMethod.ARHR];
  var mae_range = ranges[ModelEvalutionMethod.MAE];
  var rmse_range = ranges[ModelEvalutionMethod.RMSE];
  int? fixedK = k;
  var pk = eval.precision_k(prediction_hits, fixedK);
  var rk = eval.recall_k(prediction_hits, fixedK);
  var mrr = eval.MRR(prediction_hits, fixedK);
  var arhr = eval.ARHR(prediction_hits, fixedK);
  var mae = eval.MAE(alluser_distance_tbl);
  var rmse = eval.RMSE(alluser_distance_tbl);
  print("k=$k");
  print("       pk=$pk       pk range=$pk_range");
  print("       rk=$rk       rk range=$rk_range");
  print("       mrr=$mrr     mrr range=$mrr_range");
  print("       arhr=$arhr   arhr range=$arhr_range");
  print(
      "       mae=$mae     mae range=$mae_range  [only for 'MultiConsiderations']");
  print(
      "       rmse=$rmse   rmse range=$rmse_range  [only for 'MultiConsiderations']");
}
