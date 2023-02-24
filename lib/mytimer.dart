import 'dart:async';

import 'package:flutter/foundation.dart';

class MyTimer {
  bool _stop = false;
  Timer? timer;
  int duration;
  int timeout;
  int fails = 0;
  int? failAttempts;
  AsyncCallback? onFail;
  AsyncCallback? onTimeout;
  AsyncValueGetter<bool> function; // true on success; false on error;
  MyTimer({
    required this.duration,
    required this.function,
    this.timeout = 9999999999999,
    this.onTimeout,
    this.failAttempts,
    this.onFail,
  });
  Future<bool> start(bool beforeDuration) async {
    _stop = false;
    _setTimer(start: true);
    if (beforeDuration) {
      return function();
    }
    return true;
  }

  void cancel() {
    _stop = true;
    timer?.cancel();
    timer = null;
  }

  void _setTimer({bool start = false}) {
    if ((timer == null && !start) || _stop) {
      return;
    }
    timer?.cancel();
    // set run
    timer = Timer(Duration(seconds: duration), () async {
      // wait to first: result / timeout
      var wasTimeout = false;
      var wasSuccess =
          await function().timeout(Duration(seconds: duration), onTimeout: () {
        wasTimeout = true;
        return true;
      }).catchError((err) => false);
      // on timeout
      if (wasTimeout && onTimeout != null) {
        await onTimeout!();
      }
      // on fail
      fails += wasSuccess ? 0 : 1;
      if (failAttempts != null && fails > failAttempts! && onFail != null) {
        await onFail!();
        fails = 0;
      }
      _setTimer(start: false);
    });
  }
}

class OneLoadProperty<T> {
  late T? _data;
  late MyTimer? _timer;
  bool _dataWasLoaded = false;
  bool _timerHadStart = false;
// @load return true on success;false on error; before return true needs to valuesetter(value)
// duration == null => wait until waitData() is called [load() will probably run once but maybe twice]
  OneLoadProperty(Future<bool> Function(ValueSetter<T?>) load, int? duration) {
    var dataSetter = (T? value) {
      _data = value;
      _dataWasLoaded = true;
    };
    _timer = MyTimer(
        duration: duration ?? 0,
        function: () async => await load(dataSetter).then((success) {
              if (success) {
                _timer!.cancel();
              }
              return success;
            }));
    if (duration == null) {
      _timerHadStart = false;
    } else {
      _timerHadStart = true;
      _timer!.start(false);
    }
  }

  T? getDataNoWait() {
    return _data;
  }

  Future<T?> waitData() async {
    if (!_timerHadStart) {
      _timerHadStart = true;
      _timer!.start(
          false); // it's ok beforeStart=false since duration==null => duration == 0
    }
    while (!_dataWasLoaded) {
      await Future.delayed(Duration(seconds: 1));
    }
    return _data;
  }
}
