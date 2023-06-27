import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/recommendation_system/systems/functions.dart';
import 'package:havruta_project/event/recommendation_system/rec_interface.dart';
import 'package:havruta_project/globals.dart';

/// RecommendationSystem
///       class ByRandom extends RecommendationSystem<Event> [rank event by random]
class ByRandom extends RecommendationSystem<Event> {
  ByRandom({
    Future<List<Event>>? possibleEvents,
    String? myMail,
  }) {
    setData({"possibleEvents": possibleEvents, "myMail": myMail});
  }
  Future<bool> calc([int? topAmount]) async {
    bool success = true;
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
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
    var timeNow = DateTime.now();
    // won't check isTargetedForMe, assuming given possibleEvents might filtered by it, if needed
    this.top = possibleEvents
        .where((Event e) =>
            Functions.thisEventIsNewForMeAndAvailable(e, myMail, timeNow))
        .toList();
    this.top.shuffle(); //this is done only once at calc()!
    return success;
  }
}

// decorator for fake bad system, not deal will specific additions, like distance tbl
class OppositeRecommendationSystem<T> implements RecommendationSystem<T> {
  RecommendationSystem<T> inner;
  OppositeRecommendationSystem(this.inner);
  @override
  Future<bool> calc([int? topAmount]) => inner.calc(topAmount).then((value) {
        inner.top = inner.top.reversed.toList();
        return value;
      });

  Map<String, dynamic>? get data => inner.data;
  set data(Map<String, dynamic>? val) => inner.data = val;

  List<T> get top => inner.top;
  set top(List<T> val) => inner.top = val;

  @override
  List<T> getTop([int amount = 10]) => inner.getTop(amount);

  @override
  void setData(Map<String, dynamic> data) => inner.setData(data);
}
