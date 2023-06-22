import 'dart:math';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/event/recommendation_system/systems/by_success.dart';
import 'package:havruta_project/event/recommendation_system/evaluation/eval_interface.dart';
import 'package:havruta_project/event/recommendation_system/evaluation/evaluation.dart';
import 'package:havruta_project/event/recommendation_system/rec_interface.dart';
import 'package:havruta_project/event/recommendation_system/systems/functions.dart';
import 'package:havruta_project/event/recommendation_system/systems/multi_considerations.dart';
import 'package:havruta_project/globals.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// RecommendationSystem
///       class ExampleRecommendationSystem [basic use of recommendations systems in folder systems]
/// Evalution
///       void testEventsRecommendation() ["heavy" method to test p@k & mrr over all users in mongodb]

// RecommendationSystem<T> r = ExampleRecommendationSystem.create();
// bool success = await r.calc();
// if (success) {
//  var top10events = r.getTop(); // or combinedTops((r as MultiRecommendationSystem<Event>).getTops())
// } else ...
//
// or just:
// var top10events = await ExampleRecommendationSystem.calcAndGetTop10();

class ExampleRecommendationSystem {
  // control what the system contains
  static MultiRecommendationSystem<Event> _createSystem(int k) {
    var rslt = MultiRecommendationSystem<Event>(
        systems: [MultiConsiderations(), ByEventSuccess()],
        topAmount: 2 * k,
        weights: [k, k]);
    assert(rslt.systems[0]
        is MultiConsiderations); // rmse mae is done only for MultiConsiderations in test()
    return rslt;
  }

  // control here how the calc is done
  // null on error
  static Future<List<Event>?> _calcAndGetTopEventsFrom(
      MultiRecommendationSystem<Event> system) async {
    var success = await system.calc();
    if (success == false) return null;
    return combinedTops(system.getTops());
  }

  static MultiRecommendationSystem<Event> create(String myMail,
      {int k = 10, List<Event>? fakeAllEvents, List<Event>? fakeMyEvents}) {
    var myEvents = fakeMyEvents != null
        ? Future.value(fakeMyEvents)
        : Functions.getMyEvents(myMail, true);
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
    var allEvents = fakeAllEvents != null
        ? Future.value(fakeAllEvents)
        : Functions.getAllEvents(null);
    var data = {
      "compareToMe": myEvents,
      "possibleEvents": allEvents,
      "myMail": myMail,
      "clearCacheAfter": true,
      "saveLastRank": false,
    };
    var rslt = _createSystem(k);
    rslt.setData(data);
    return rslt;
  }

  static Future<List<Event>> calcAndGetTop10(String myMail,
      {bool suppressException = true,
      List<Event>? fakeAllEvents,
      List<Event>? fakeMyEvents}) async {
    MultiRecommendationSystem<Event> r = ExampleRecommendationSystem.create(
        myMail,
        k: 10,
        fakeAllEvents: fakeAllEvents,
        fakeMyEvents: fakeMyEvents);
    var rec = await _calcAndGetTopEventsFrom(r);

    if (rec == null && !suppressException) {
      throw Exception("ExampleRecommendationSystem failed");
    }
    //(max 10, but probably so, because in create() we asked each system for 10)
    return rec ?? [];
  }

  // it's not test excatly the same way it recommends, since there are some issues that prevent this
  static Future<Map<ModelEvalutionMethod, double>?> test(
      {int k = 10,
      int? put100IfYouSure,
      int? maxUsersForEventsFetch,
      List<Event>? fakeAllEvents,
      Map<String, List<Event>>? fakeMyEvents,
      List<String>? fakeUsersMails,
      List? outParamRec,
      RecommendationSystem<Event> Function(int k)? useMeInstead,
      bool printOutput = true}) async {
    // very heavy calc & internet access
    if (put100IfYouSure != 100) {
      return null;
    }
    assert(k % 2 == 0);
    assert(k >= 4);
    var eval = EventModelEvaluation();
    var usersEmail = fakeUsersMails;
    if (usersEmail == null) {
      var mongo = Globals.db!;
      var db = mongo.db as Db;
      var collection = db.collection('Users');
      usersEmail = await collection
          .find()
          .map((user) => User.fromJson(user).email!)
          .toList();
    }
    if (maxUsersForEventsFetch != null &&
        maxUsersForEventsFetch < usersEmail.length) {
      usersEmail.shuffle();
      usersEmail = usersEmail.sublist(0, maxUsersForEventsFetch);
    }
    // getAllEvents() is auto filtered by EvenesSelectorBuildder.targetForMe()
    var __allEvents = fakeAllEvents ?? await Functions.getAllEvents(null);
    Map<String, List<Event>> user_events_validate = {};
    Map<String, List<Event>> user_events_data = {};
    Map<String, List<Event>> user_rec = {};
    Map<RecommendationSystemWithDistanceTbl<Event>, List<double>>
        alluser_distance_tbl_allsys = {};
    final DateTime now = DateTime.now();
    int? sysLen;
    for (var email in usersEmail) {
      var allEvents = List.of(__allEvents
          .where((e) =>
              !e.rejectedQueue.contains(email) && !e.leftQueue.contains(email))
          // to allow the option to recommend on something in the valid set=I in queue, need to let me out of any queue
          .map((e) => e.deepClone()..moveToQueueLocal(email, null)));
      var list = fakeMyEvents?[email]
              ?.where((e) =>
                  !e.rejectedQueue.contains(email) &&
                  !e.leftQueue.contains(email))
              .map((event) {
                var rslt = event.deepClone();
                rslt.dates =
                    rslt.dates!.where((time) => time.isAfter(now)).toList();
                return rslt;
              })
              .where((event) => event.dates!.isNotEmpty)
              .toList() ??
          await Functions.getMyEvents(
              email,
              // see below why using here rejected\left queue = without
              false,
              // filterOld = true since we want the test/validate will be on same zone,
              // it isn't just recommendation but also test
              // and since we filter old events from getAllEvents, we need to do it here too...
              // or else we miss old event because they aren't in the possibleEvents=getAllEvents
              // we want:
              // [possibleRecommendation ( validate            ]   data)
              // [ getAllEvents          ( list.sublist(0,p+1) ]   list=getMyEvents.shuffle )
              // we don't want empty intersection:
              // [possibleRecommendation]     (validate              data)
              // [ getAllEvents ]             ( list.sublist(0,p+1)  list=getMyEvents.shuffle )
              // and also the systems won't recommend old events
              // p=pivot index
              filterOld: true);
      if (list.length < (2 * k)) {
        continue;
      }
      list.shuffle();
      // valid can have more[change also next line]
      int pivot = max(k, list.length ~/ 5);
      //pivot >=k, ideal 20%=valid 80%=train(data)
      user_events_validate[email] = list.sublist(0, pivot + 1);
      user_events_data[email] = list.sublist(pivot + 1);
      var data = {
        "compareToMe": Future.value(user_events_data[email]),
        "possibleEvents": Future.value(allEvents),
        "myMail": email,
        "clearCacheAfter": false,
        "saveLastRank": true,
      };
      RecommendationSystem<Event> system =
          useMeInstead != null ? useMeInstead(k) : _createSystem(k);
      MultiRecommendationSystem<Event>? sysAsMultiSystem =
          system is MultiRecommendationSystem<Event> ? system : null;
      // we don't know how to handle with the multi-system,
      // maybe only the index[0] will return rec in getTop(k) below
      // so we will treat it as regular sys
      sysAsMultiSystem = useMeInstead != null ? null : sysAsMultiSystem;
      // and here we will treat it like 1 complicated sys
      sysLen = sysAsMultiSystem?.systems.length ?? 1;
      system.setData(data);
      // will auto filter thisEventIsNewForMeAndAvailable() ,
      // so no events where  EvenesSelectorBuildder.targetForMe()==false (already filtered in above)
      // OR email in any event queue(flitered in one of the step of the next line)
      List<Event>? rec;
      if (useMeInstead == null) {
        rec = await _calcAndGetTopEventsFrom(sysAsMultiSystem!);
      } else {
        if (await system.calc(k)) rec = system.getTop(k);
      }
      bool success = rec != null;
      if (!success) continue;
      user_rec[email] = rec;
      var iterOver =
          sysAsMultiSystem == null ? [system] : sysAsMultiSystem.systems;
      for (var i in iterOver) {
        var currSys =
            i is RecommendationSystemWithDistanceTbl<Event> ? i : null;
        if (currSys == null) continue; // and go to next i in iterOver
        // distance tbl
        var A = currSys.getLastRank();
        if (A == null) continue; // and go to next i in iterOver
        // get the same tbl cells, but with value when we give compareToMe = list
        // = check the diff with more data to the model
        var B = await currSys.calcRank(A.keys.toList(), {"compareToMe": list});
        // only on first time init with empty list
        alluser_distance_tbl_allsys[currSys] =
            alluser_distance_tbl_allsys[currSys] ?? [];
        // keep diff list to each sys, but each list contain ALL user-event ranks
        alluser_distance_tbl_allsys[currSys]!.addAll(eval.getDiff(A, B));
        //mcs.last_rank.clear(); because  "saveLastRank": true,
      }
    }
    //MultiConsiderations.clear_cache(); because "clearCacheAfter": false,
    List<List<List<Event>>> prediction_hits = [];
    for (var email in user_rec.keys) {
      prediction_hits.add([user_rec[email]!, user_events_validate[email]!]);
    }
    outParamRec?.add(user_rec);
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
    var maeSum = alluser_distance_tbl_allsys.values
        .fold(0.0, (double pre, tbl) => pre + eval.MAE(tbl));
    var rmseSum = alluser_distance_tbl_allsys.values
        .fold(0.0, (double pre, tbl) => pre + eval.RMSE(tbl));
    int n = alluser_distance_tbl_allsys.length;
    double maeAvg = maeSum / n;
    double rmseAvg = rmseSum / n;
    if (printOutput) {
      var f = (x) => x is double
          ? x.toStringAsFixed(3)
          : [x[0].toStringAsFixed(3), x[1].toStringAsFixed(3)];
      print(
          "k=$k   #rec_sys= $sysLen        #users=      ${usersEmail.length}");
      print("       pk=       ${f(pk)}    pk range=   ${f(pk_range)}");
      print("       rk=       ${f(rk)}    rk range=   ${f(rk_range)}");
      print("       mrr=      ${f(mrr)}    mrr range=  ${f(mrr_range)}");
      print("       arhr=     ${f(arhr)}    arhr range= ${f(arhr_range)}");
      if (!maeAvg.isNaN)
        print(
            "       avg mae=  ${f(maeAvg)}    mae range=  ${f(mae_range)}  [only for 'MultiConsiderations']");
      else
        print("       no mae");
      if (!rmseAvg.isNaN)
        print(
            "       avg rmse= ${f(rmseAvg)}    rmse range= ${f(rmse_range)}  [only for 'MultiConsiderations']");
      else
        print("       no rmse");
    }
    return {
      ModelEvalutionMethod.PrecisionK: pk,
      ModelEvalutionMethod.RecallK: rk,
      ModelEvalutionMethod.MRR: mrr,
      ModelEvalutionMethod.ARHR: arhr,
      ModelEvalutionMethod.MAE: maeAvg,
      ModelEvalutionMethod.RMSE: rmseAvg
    };
  }
}
