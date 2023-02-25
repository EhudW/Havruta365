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
    // should the first call function.then.onerror ...   will be right now?
    if (beforeDuration) {
      return _callback(start: true); // will auto setTimer
    } else {
      _setTimer(start: true); // will call _callback AFTER duration
      return true;
    }
  }

  void cancel() {
    _stop = true;
    timer?.cancel();
    timer = null;
  }

  Future<bool> _callback({bool start = false}) async {
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
    _setTimer(start: start);
    return (wasSuccess && !wasTimeout);
  }

  void _setTimer({bool start = false}) {
    if ((timer == null && !start) || _stop) {
      return;
    }
    timer?.cancel();
    // set run
    timer = Timer(Duration(seconds: duration), _callback);
  }
}

abstract class ILoadProperty<T> {
  Future<T?> waitData(); // sometime a result will return
  void start();
  void pause();
  void cancel(T? instead); // shutdown
  void restart(T? instead) {
    cancel(instead);
    start();
  }
}

class LoadProperty<T> extends ILoadProperty<T> {
  static Map<String, LoadProperty> avoidRepeatPropertyTimer = {};
  T? _data;
  MyTimer? _timer;
  bool _dataWasLoaded = false;
  bool _timerHadStart = false;
  int? duration;
  bool waitAutoStart;
  bool _disposeNow = false;
  bool _useInstead = false;
  bool oneLoadOnly;
  T? _instead;
// @load return true on success;false on error; before return true needs to valuesetter(value)
// duration == null => wait until waitData() is called [load() will probably run once but maybe twice]
  LoadProperty(
    Future<bool> Function(ValueSetter<T>) load, {
    this.duration,
    this.waitAutoStart = false,
    required this.oneLoadOnly,
    String? cancelPrev,
    dynamic cancelPrevWith,
  }) {
    if (cancelPrev != null) {
      var prev = LoadProperty.avoidRepeatPropertyTimer[cancelPrev];
      LoadProperty.avoidRepeatPropertyTimer[cancelPrev] = this;
      if (prev != null) {
        prev.cancel(cancelPrevWith);
        prev._disposeNow = true;
      }
    }
    var dataSetter = (T value) {
      if (!_useInstead) {
        _data = value;
        _dataWasLoaded = true;
      }
    };
    _timer = MyTimer(
        duration: duration ?? 0,
        function: () async => await load(dataSetter).then((success) {
              if (success && oneLoadOnly) {
                _timer!.cancel();
              }
              return success;
            }));
  }
  @override
  void start() {
    if (_disposeNow) {
      return;
    }
    if (!_timerHadStart || _useInstead) {
      _dataWasLoaded = false;
      _useInstead = false;
      _timerHadStart = true;
      _timer!.start(
          false); // it's ok beforeStart=false since duration==null => duration == 0
    }
  }

  @override
  Future<T?> waitData() async {
    while (!_dataWasLoaded && !_useInstead && !_disposeNow) {
      if (waitAutoStart) {
        start();
      }
      await Future.delayed(Duration(seconds: 1));
    }
    return (_useInstead || _disposeNow) ? _instead : _data;
  }

  @override
  void cancel(T? instead) {
    _useInstead = true;
    _instead = instead;
    _timer?.cancel();
  }

  @override
  void pause() {
    _timer?.cancel();
    _timerHadStart = false;
    _dataWasLoaded = false;
  }
}
