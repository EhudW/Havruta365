import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
// see also Globals.dart

enum MyPrintType {
  // none type prints
  None,
  // MyTimer (mytimer.dart)
  TimerTick,
  // LoadProperty (mytimer.dart)
  LoadProperty,
  // MongoDbImpl, MongoCollection (mongo2.dart)
  Mongo2,
  // MongoTest (mongo2.dart)
  Mongo2Test,
  // MongoCollection._tryWithReconnectStream() (mongo2.dart)
  // MongoCollection._tryWithReconnectFuture() (mongo2.dart)
  Rethrow,
  // Mongo.deleteNotification() (mongo.dart),
  // NewNotificationManager.updateNotification() (main.dart)
  Nnim,
}

Map<MyPrintType, bool> myPrintTypes = {
  MyPrintType.None: true,
  MyPrintType.TimerTick: false,
  MyPrintType.LoadProperty: false,
  MyPrintType.Mongo2: false,
  MyPrintType.Mongo2Test: false,
  MyPrintType.Rethrow: false,
  MyPrintType.Nnim: false,
};
// print formatted log:
// example:
// myPrint:  connectionTest() success == true                          <Mongo2Test  22:01:04>
// myPrint:  ---         obj.toString()   ---  ---     padding    ---  <MyPrintType    now  >
myPrint(Object? obj, MyPrintType type) {
  if (!kDebugMode) return;
  if (myPrintTypes[type] ?? false) {
    String prefix = "myPrint:  $obj";
    String suffix = " <${type.toString().split(".").last}";
    suffix += "  ${DateFormat('HH:mm:ss').format(DateTime.now().toLocal())}>";
    int suffixPadding = 90 - prefix.length;
    print("$prefix${suffix.padLeft(suffixPadding)}");
  }
}

class MyConsts {
  //////////////////////  delay between loop/infinite of async attempts,
  //////////////////////  (mytimer.dart modelsHomePages.dart notificationModel.dart)
  //////////////////////  see below for specific cases
  //////////////////////
  static const Duration defaultDelay = const Duration(seconds: 1);

  //////////////////////   MongoDbImpl (mongo2.dart):
  //////////////////////
  // should use MongoDbImpl (true) or Db (false) ?
  // this control if to use reconnecting model
  static const bool useDb2 = true;
  // if useDb2 == true, && testConnection == true then,
  // in addition check connection each @testConnectionEveryXSec,
  // which will TRY to active reconnect on MongoCollection & MongoDbImpl
  // enable reconnection by active requests (_reconnect at MongoDbImpl) if @testConnectionForceReconnectNow
  // and force reconnection if @testConnectionForceReconnectNow
  // on timeout @testConnectionTimeoutXSec
  // or on every @testConnectionFailsAttempts
  static const bool testConnection = false;
  static const int testConnectionEveryXSec = 15;
  static const int testConnectionFailsAttempts = 3;
  static const int testConnectionTimeoutXSec = 45; // 3 * 15
  static const bool testConnectionForceReconnectNow = false;

  //////////////////////   NewNotificationManager (main.dart):
  //////////////////////
  // how often check for new notifications
  static const int checkNewNotificationSec = 15;
  static const int checkNewNotificationTimeoutSec = 60;

  //////////////////////   ChatRefresh (chatStreamModel.dart):
  //////////////////////
  // how often check for new msgs
  static const int checkNewMessageInChatSec = 7;
  static const int checkNewMessageOutsideChatSec = checkNewNotificationSec;

  //////////////////////  Globals.rec (Globals.dart):
  //////////////////////
  // how often check for fetch load property [this is no setting a timeout]
  static const int loadPropertyDelaySec = 2;

  //////////////////////   MongoDbImpl, MongoCollections (mongo2.dart):
  //////////////////////
  // control delay on create() open() reconnect()
  static const int mongo2DelaySec = 5;
  // for inner __delegate Db close() in MongoDbImpl, not awaited by outer MongoDbImpl
  static const int mongo2CloseNoAwaitDelaySec = 30;
  // max requests that in the async loop until they get answer
  static const int mongoCollectionPoolLimit = 12;
}
