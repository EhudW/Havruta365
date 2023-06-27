// ignore_for_file: non_constant_identifier_names

import 'package:havruta_project/event/recommendation_system/systems/functions.dart';

import '../rec_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/globals.dart';

/// RecommendationSystem
///       class CriticMyEvents<O> [rank feature by recurrence amount]
///       class MultiConsiderations extends RecommendationSystem<Event> [system for ranking feature by recurrence]

// helper class for recommendation for Event
// due to my Events, test what option of many options[O] in ONE feature[F] I liked the most (exactly ==)
class CriticMyEvents<O> {
  int _total = 0;
  String? field;
  List<Event> myEvents;
  Map<O, double> rank = {};
  O Function(Event)? classify;
  List<O> Function(Event)? classifyList;
  num weight;
  num Function(Event) weightOfEvent;
  CriticMyEvents(
      {this.field, // not needed for calc only for debug
      required this.myEvents,
      required this.classify,
      required this.classifyList,
      this.weight = 1.0,
      required this.weightOfEvent}) {
    _calc();
    _norm(soft: 1);
  }

  void _calc() {
    myEvents.forEach((element) {
      num eventW = this.weightOfEvent(element);
      if (classifyList != null) {
        var indexes;
        try {
          indexes = classifyList!(element);
        } catch (e) {
          return;
        }
        for (var idx in indexes) {
          rank[idx] = (rank[idx] ?? 0) + eventW;
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
        rank[idx] = (rank[idx] ?? 0) + eventW;
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

class MultiConsiderations extends RecommendationSystemWithDistanceTbl<Event> {
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
  Map<Event, double> getLastRank() => last_rank;
  static void clear_cache() => _users_cache.clear();
  Future<Map<Event, double>> calcRank(
      List<Event> possible, Map<String, dynamic> config) {
    return calcTotalRank(possible, config['compareToMe']);
  }

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
    const USE_FILL_USERS_CACHE =
        false; //too much for every smartphone every recommendation compute

    var fillUsersCache = (List<Event> list) async {
      if (!USE_FILL_USERS_CACHE) return;
      for (Event e in list) {
        var users = e.participants ?? [];
        users += e.waitingQueue ?? [];
        for (String user in users) {
          User? replace;
          if (_users_cache[user] == null) {
            replace = await Globals.db!.getUser(user);
          }
          if (replace != null) {
            _users_cache[user] = replace;
          }
        }
      }
    };

    var otherUsersConsiderations = !USE_FILL_USERS_CACHE
        ? []
        : [
            //need await fillUsersCache()
            // by how age of others are similiar to my age
            {
              "classify": (Event e) {
                double total = 0.0;
                var thisYear = DateTime.now().year;
                var both = (e.participants ?? []) + (e.waitingQueue ?? []);
                if (both.length <= 1) {
                  // only me on calc, or empty on rank
                  return UniqueKey().toString();
                }
                for (String user in both) {
                  // the bias I(myMail) do isn't significant
                  total += thisYear - _users_cache[user]!.birthDate!.year;
                }
                double diff = total / both.length -
                    (thisYear - Globals.currentUser!.birthDate!.year);
                diff = diff > 0 ? diff : -diff;
                return diff > 10 ? ">10" : (diff > 5 ? "5-10" : "<5");
              },
              "weight": 1,
            },
            // by what is the status of the majority of others
            {
              "classify": (Event e) {
                Map<String, int> status_count = {};
                var both = (e.participants ?? []) + (e.waitingQueue ?? []);
                if (both.length <= 1) {
                  // only me on calc, or empty on rank
                  return UniqueKey().toString();
                }
                for (String user in both) {
                  // the bias I(myMail) do isn't significant
                  var s = _users_cache[user]!.status!;
                  status_count[s] = (status_count[s] ?? 0) + 1;
                }
                String? max = status_count.keys.fold(
                    null,
                    (previousValue, element) => previousValue != null
                        ? (status_count[previousValue]! >=
                                status_count[element]!
                            ? previousValue
                            : element)
                        : element);
                return max ?? UniqueKey().toString();
              },
              "weight": 1,
            }
          ];

    /// for rank for specific target group (people who preffer small/big lecture, etc..)
    var considerationsFactory = (events) => (otherUsersConsiderations +
            [
              // by part of day
              {
                "classifyList":
                    // (Event e) => getPartsOfDayOf(e.dates!.first, e.duration ?? 0),
                    (Event e) {
                  List rslt = [];
                  int duration = e.duration ?? 0;
                  e.dates!.forEach((time) =>
                      rslt.addAll(Functions.getPartsOfDayOf(time, duration)));
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
                "classify": (Event e) =>
                    e.maxParticipants! >= 10 ? ">=10" : "<10",
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
            ])
        .map((e) => CriticMyEvents(
            classify: e["classify"] as dynamic Function(Event)?,
            classifyList: e["classifyList"] as List<dynamic> Function(Event)?,
            weight: e["weight"] as num? ?? 1.0,
            myEvents: events,
            weightOfEvent: (Event e) =>
                e.rejectedQueue.contains(e) || e.leftQueue.contains(e)
                    ? -1
                    : 1))
        .toList();

    var getTotalRank =
        (List<Event> possibleEvents, List<Event> compareToMe) async {
      var considerations = considerationsFactory(compareToMe);
      // very heavy(100 events can have 2000 users),
      // if USE_FILL_USERS_CACHE == true
      await fillUsersCache(possibleEvents);
      await fillUsersCache(compareToMe);
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
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe(), but include also where I was rejected or left
    var possibleEvents =
        await ((this.data?['possibleEvents'] ?? Functions.getAllEvents(null))
            .catchError((error) {
      success = false;
      return [];
    }));
    if (!success) {
      return success;
    }
    var myMail = data!["myMail"] ?? Globals.currentUser!.email!;
    var compareToMe = await ((this.data?['compareToMe'] ??
            Functions.getMyEvents(myMail, true))
        .catchError((error) {
      success = false;
      return [];
    }));

    if (!success) {
      return success;
    }
    var timeNow = DateTime.now();
    // won't check isTargetedForMe, assuming given possibleEvents might filtered by it, if needed
    this.top = Functions.getSortedList(await calcTotalRank(possibleEvents,
            compareToMe)) // only EvenesSelectorBuildder.targetForMe() filter, but also rejected & left
        .where((Event e) => Functions.thisEventIsNewForMeAndAvailable(
            e, myMail, timeNow)) // only targeted & not rejected & not left
        .toList();
    return success;
  }
}
