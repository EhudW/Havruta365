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
  MyPrintType.TimerTick: true,
  MyPrintType.LoadProperty: true,
  MyPrintType.Mongo2: true,
  MyPrintType.Mongo2Test: true,
  MyPrintType.Rethrow: true,
  MyPrintType.Nnim: true,
};
myPrint(Object? obj, MyPrintType type) =>
    (myPrintTypes[type] ?? false) ? print(obj) : null;

class MyConsts {
  //////////////////////   MongoDbImpl (mongo2.dart):
  //////////////////////
  // should use MongoDbImpl (true) or Db (false) ?
  // this control if to use reconnecting model
  static const bool useDb2 = true;
  // if useDb2 == true, then,
  // in addition check connection each @testConnectionEveryXSec,
  // and force reconnection
  // on timeout @testConnectionTimeoutXSec
  // or on every @testConnectionFailsAttempts
  static const int testConnectionEveryXSec = 15;
  static const int testConnectionTimeoutXSec = 60;
  static const int testConnectionFailsAttempts = 3;

  //////////////////////   NewNotificationManager (main.dart):
  //////////////////////
  // how often check for new notifications
  static const int checkNewNotificationSec = 15;

  //////////////////////   MongoDbImpl, MongoCollections (mongo2.dart):
  //////////////////////
  // control delay on create() open() reconnect()
  static const int mongo2DelaySec = 5;
  // max requests that in the async loop until they get answer
  static const int mongoCollectionPoolLimit = 12;
}
