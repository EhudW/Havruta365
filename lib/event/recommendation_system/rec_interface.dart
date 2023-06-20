import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// RecommendationSystem
///       abstract class RecommendationSystem<T> [interface]
///       class MultiRecommendationSystem<T> extends RecommendationSystem<T> [combine systems]
///       function combinedTops [combine lists to 1 list]

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

  // MUST give amount=topAmount! [it's optional only because the interface]
  // use getTops for more flexible function
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

// maxTop is null => maxTop = max {eventsLists[i].length}
List<Event> combinedTops(List<List<Event>> eventsLists, [int? maxTop]) {
  // from list of some recommendations (matrix)  [[..] [..]]
  Set<ObjectId> eventsSet = Set();
  List<Event> events = [];
  int maxLen = eventsLists.fold(
      0,
      (previousValue, oneList) =>
          previousValue > oneList.length ? previousValue : oneList.length);
  maxTop = maxTop ?? maxLen;
  // add to events (flattened array), max maxTop events
  // for each cell in tbl of columns of j-top rows of i-system
  for (int n = 0;
      n < maxLen * eventsLists.length && events.length < maxTop;
      n++) {
    // i-system is alter every change of n, to give chance to each system to reccomend
    // i from 0 to eventsLists.length
    int i = n % eventsLists.length;
    var list = eventsLists[i];
    // j-top is alter only after all system had chanch to reccommend for their j-top
    // j from 0 to maxLen
    int j = (n / eventsLists.length).floor();
    //each event must be unique
    if (list.length > j && !eventsSet.contains(list[j].id)) {
      events.add(list[j]);
      eventsSet.add(list[j].id);
    }
  }
  // return flattened array of unique events , combined [ [1,2] [a,b,c] ] -> [1,a,2,b,c] ,
  return events;
}
