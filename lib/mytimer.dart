import 'dart:async';
import '../mydebug.dart' as MyDebug;
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
  String? myDebugLabel;
  AsyncValueGetter<bool> function; // true on success; false on error;
  MyTimer({
    required this.duration,
    required this.function,
    this.timeout = 9999999999999,
    this.onTimeout,
    this.failAttempts,
    this.onFail,
    this.myDebugLabel,
  }) {
    myDebugLabel = myDebugLabel ?? this.hashCode.toString();
  }
  Future<bool> start(bool beforeDuration) async {
    MyDebug.myPrint(
        "MyTimer start() [$myDebugLabel]", MyDebug.MyPrintType.TimerTick);
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
    MyDebug.myPrint(
        "MyTimer cancel() [$myDebugLabel]", MyDebug.MyPrintType.TimerTick);
    _stop = true;
    timer?.cancel();
    timer = null;
  }

  Future<bool> _callback({bool start = false}) async {
    MyDebug.myPrint("MyTimer tick _callback() [$myDebugLabel]",
        MyDebug.MyPrintType.TimerTick);
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
      fails = 0;
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
  String? myDebugLabel;
// @load return true on success;false on error; before return true needs to valuesetter(value)
// duration == null => wait until waitData() is called [load() will probably run once but maybe twice]
  LoadProperty(
    Future<bool> Function(ValueSetter<T>) load, {
    this.duration,
    this.waitAutoStart = false,
    required this.oneLoadOnly,
    String? cancelPrev,
    dynamic cancelPrevWith,
    this.myDebugLabel,
  }) {
    myDebugLabel = myDebugLabel ?? this.hashCode.toString();

    if (cancelPrev != null) {
      var prev = LoadProperty.avoidRepeatPropertyTimer[cancelPrev];
      LoadProperty.avoidRepeatPropertyTimer[cancelPrev] = this;
      if (prev != null) {
        MyDebug.myPrint(
            "LoadProperty \"[$cancelPrev]\" -> constructor ->\n" +
                "    new: [$myDebugLabel] cancel: [${prev.myDebugLabel}]",
            MyDebug.MyPrintType.LoadProperty);
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
      MyDebug.myPrint("LoadProperty  start() [$myDebugLabel]",
          MyDebug.MyPrintType.LoadProperty);
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
        MyDebug.myPrint(
            "LoadProperty waitData() -> auto start() [$myDebugLabel]",
            MyDebug.MyPrintType.LoadProperty);
        start();
      }
      await Future.delayed(Duration(seconds: 1));
    }
    return (_useInstead || _disposeNow) ? _instead : _data;
  }

  @override
  void cancel(T? instead) {
    MyDebug.myPrint("LoadProperty  cancel() [$myDebugLabel]",
        MyDebug.MyPrintType.LoadProperty);
    _useInstead = true;
    _instead = instead;
    _timer?.cancel();
  }

  @override
  void pause() {
    MyDebug.myPrint("LoadProperty  pause() [$myDebugLabel]",
        MyDebug.MyPrintType.LoadProperty);
    _timer?.cancel();
    _timerHadStart = false;
    _dataWasLoaded = false;
  }
}
