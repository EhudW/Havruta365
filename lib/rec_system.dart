// ignore_for_file: non_constant_identifier_names

import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
  CriticMyEvents(
      {this.field, // not needed for calc
      required this.myEvents,
      required this.classify,
      required this.classifyList}) {
    _calc();
    _norm();
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

  void _norm() {
    if (_total == 0) {
      return;
    }
    for (var option in List.of(rank.keys)) {
      rank[option] = rank[option]! / _total;
    }
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

class MultiConsiderations extends RecommendationSystem<Event> {
  static Future<List<Event>> getAllEvents() =>
      Globals.db!.getSomeEvents(0, null, limit: 100, newestFirst: true);
  static Future<List<Event>> getMyEvents(String myMail) =>
      Globals.db!.getEvents(myMail, false, null);
  static bool thisEventIsNewForMeAndAvailable(
      Event e, String myMail, DateTime timeNow) {
    if ((e.participants ?? []).length + (e.waitingQueue ?? []).length >=
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
  }) {
    setData({
      "compareToMe": compareToMe,
      "possibleEvents": possibleEvents,
      "myMail": myMail
    });
  }
  @override
  Future<bool> calc([int? topAmount]) async {
    ///
    var whoTeacher = (Event e) => e.lecturer?.trim() != ""
        ? e.lecturer!.trim().toLowerCase()
        : e.creatorUser!.trim().toLowerCase();

    /// for rank for specific target group (people who preffer small/big lecture, etc..)
    var considerationsFactory = (events) => [
          [
            whoTeacher,
            null,
          ],
          [
            (Event e) => e.topic!.toUpperCase(),
            null,
          ],
          [
            (Event e) => e.type!.toUpperCase(),
            null,
          ],
          [
            null,
            (Event e) =>
                e.dates?.map((d) => d.toLocal().weekday).toList() ?? [],
          ],
          [
            (Event e) => e.duration! > 60
                ? "61+"
                : (e.duration! > 30 ? "31-60" : "0-30"),
            null,
          ],
          [
            (Event e) => e.maxParticipants! >= 10 ? ">=10" : "<10",
            null,
          ],
          [
            (Event e) => e.targetGender!.toUpperCase() == 'M'
                ? 'M'
                : (e.targetGender!.toUpperCase() == 'F' ? 'F' : 'BOTH'),
            null,
          ],
          [
            (Event e) => (e.link?.trim() ?? "") != "" ? true : false,
            null,
          ],
        ]
            .map((e) => CriticMyEvents(
                classify: e[0] as dynamic Function(Event)?,
                classifyList: e[1] as List<dynamic> Function(Event)?,
                myEvents: events))
            .toList();

    var getTotalRank = (List<Event> possibleEvents, List<Event> compareToMe) {
      var considerations = considerationsFactory(compareToMe);
      Map<Event, double> totalRank = {};
      for (CriticMyEvents partOfRank in considerations) {
        var part = partOfRank.rankOtherEvents(possibleEvents);
        for (Event event in part.keys) {
          totalRank[event] = (totalRank[event] ?? 0.0) + part[event]!;
        }
      }
      return totalRank;
    };

    bool success = true;

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

    this.top = getSortedList(getTotalRank(possibleEvents, compareToMe))
        .where((Event e) => thisEventIsNewForMeAndAvailable(e, myMail, timeNow))
        .toList();
    return success;
  }
}

class ByEventSuccess extends RecommendationSystem<Event> {
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
      int amount =
          (event.participants?.length ?? 0) + (event.waitingQueue?.length ?? 0);
      rank[event] = rank[event]! +
          amount /
              ((event.maxParticipants ?? 0) > 0 ? event.maxParticipants! : 100);
    }

    var myMail = data!["myMail"] ?? Globals.currentUser!.email!;
    var timeNow = DateTime.now();

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
    var allEvents = MultiConsiderations.getAllEvents();
    var data = {
      "compareToMe": myEvents,
      "possibleEvents": allEvents,
      "myMail": myMail
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
  double MAE(distanceTable) {
    return double.nan;
  }

  @override
  double RMSE(distanceTable) {
    return double.nan;
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
  var mongo = Globals.db!;
  var db = mongo.db as Db;
  var collection = db.collection('Users');
  var usersEmail =
      await collection.find().map((user) => User.fromJson(user).email).toList();
  var allEvents = await MultiConsiderations.getAllEvents();
  Map<String, List<Event>> user_events_validate = {};
  Map<String, List<Event>> user_events_data = {};
  Map<String, List<Event>> user_rec = {};
  for (var email in usersEmail) {
    var list = await mongo.getAllEventsAndCreated(email, false, null);
    if (list.length < (2 * k)) {
      continue;
    }
    list.shuffle();
    user_events_validate[email!] = list.sublist(0, 2 * k + 1);
    user_events_data[email] = list.sublist(2 * k + 1);
    var data = {
      "compareToMe": user_events_data[email],
      "possibleEvents": allEvents,
      "myMail": email,
    };
    var system = MultiRecommendationSystem<Event>(
        systems: [MultiConsiderations(), ByEventSuccess()],
        topAmount: k,
        weights: [(k / 2).round(), (k / 2).round()]);
    system.setData(data);
    var success = await system.calc();
    if (success) {
      user_rec[email] = system.getTop();
    }
  }
  List<List<List<Event>>> prediction_hits = [];
  for (var email in user_rec.keys) {
    prediction_hits.add([user_rec[email]!, user_events_validate[email]!]);
  }
  var eval = EventModelEvaluation();
  var ranges = ModelEvalution.calcRange(k);
  var pk_range = ranges[ModelEvalutionMethod.PrecisionK];
  var mrr_range = ranges[ModelEvalutionMethod.MRR];
  var pk = eval.precision_k(prediction_hits, null);
  var mrr = eval.MRR(prediction_hits, null);
  print("k=$k   pk=$pk   pk range=$pk_range");
  print("k=$k   mrr=$mrr   mrr range=$mrr_range");
}
