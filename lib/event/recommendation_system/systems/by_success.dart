import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/recommendation_system/systems/functions.dart';
import 'package:havruta_project/event/recommendation_system/rec_interface.dart';
import 'package:havruta_project/globals.dart';

/// RecommendationSystem
///       class ByEventSuccess extends RecommendationSystem<Event> [rank event by 'success'(participants)]
class ByEventSuccess extends RecommendationSystem<Event> {
  ByEventSuccess({
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
    this.top = Functions.getSortedList(rank)
        .where((Event e) =>
            Functions.thisEventIsNewForMeAndAvailable(e, myMail, timeNow))
        .toList();
    return success;
  }
}
