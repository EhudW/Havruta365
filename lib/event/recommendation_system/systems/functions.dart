import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/events_selector_builder.dart';
import 'package:havruta_project/event/screens/event_scroller_screen/events.dart';

// common functions for rec system for events (utility class)
class Functions {
  // auto filtered by EvenesSelectorBuildder.targetForMe();
  // rejected due to ensureNotRejected, leftQueue not filtered
  static Future<List<Event>> getAllEvents(String? ensureNotRejected,
          [int maxEvents = 100]) =>
      EventsSelectorBuilder.fetchFrom(
        startFrom: 0,
        maxEvents: maxEvents,
        filterOldEvents: true,
        filterOldDates: true,
        newestFirst: true,
        withRejectedLeftQueue: false, // useless since withParticipant == null
        ensureNotRejected: ensureNotRejected, // still will filter
      );
  //Globals.db!.getSomeEvents(0, null, limit: 100, newestFirst: true);
  // filter: EvenesSelectorBuildder.targetForMe(); leftQueue,rejectedQueue due withRejectedOrLeftQueue
  static Future<List<Event>> getMyEvents(
          String myMail, bool withRejectedOrLeftQueue,
          {bool filterOld = false}) =>
      EventsSelectorBuilder.fetchFrom(
        withParticipant: myMail,
        filterOldDates: filterOld,
        filterOldEvents: filterOld,
        maxEvents: null,
        startFrom: null,
        withWaitingQueue: true,
        withRejectedLeftQueue: withRejectedOrLeftQueue,
        ensureNotRejected: null,
      );
  // won't check EvenesSelectorBuildder.targetForMe()
  // will filter if myMail in any eventqueue
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

  // check if there is overlap between 2 times
  static bool rangesOverlap(List<double> rangeA, List<double> rangeB,
      [double? modulo]) {
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

  static bool rangeDateOverlap(List<double> rangeA, DateTime d, int duration) {
    double h = d.toLocal().hour + d.toLocal().minute / 60;
    return rangesOverlap(rangeA, [h.toDouble(), (h + duration / 60)], 24);
  }

  static List<PartOfDay> getPartsOfDayOf(DateTime d, int duration) {
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
}
