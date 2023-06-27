import 'dart:math';
import 'package:havruta_project/event/recommendation_system/evaluation/eval_interface.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Evalution
///       class EventModelEvaluation extends ModelEvalution<Event> [implentation for evaluate Event rec system]

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
