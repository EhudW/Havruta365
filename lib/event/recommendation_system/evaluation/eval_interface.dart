/// Evalution
///       enum ModelEvalutionMethod [for  ModelEvalution.calcRange(k)]
///       abstract class ModelEvalution<T> [interface]

enum ModelEvalutionMethod { PrecisionK, RecallK, MRR, ARHR, MAE, RMSE }

abstract class ModelEvalution<T> {
  static final double inf = 1.0 / 0.0;
  static Map<ModelEvalutionMethod, List<double>> calcRange(int k) {
    var sum = 0.0;
    for (int i = 1; i <= k; i++) {
      sum += 1 / i;
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
