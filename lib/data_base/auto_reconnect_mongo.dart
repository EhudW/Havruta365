// when writing this, this is the solution I found
// see https://github.com/mongo-dart/mongo_dart/issues/198#issuecomment-1063191511
// was open issue when I copy from ^ and adjust

// ignore_for_file: implementation_imports

import 'dart:async';
import '../mydebug.dart' as MyDebug;
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/distinct/distinct_result.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/distinct/distinct_options.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/count/count_result.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/count/count_options.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/list_collections_command/list_collections_options.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/drop_database_command/drop_database_options.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/drop_command/drop_options.dart';

class AutoReconnectMongo implements mongo.Db {
  static const int smallDelaySec = MyDebug.MyConsts.mongo2DelaySec;
  static const Duration smallDelay = const Duration(seconds: smallDelaySec);
  mongo.Db? __delegate;
  mongo.Db get _delegate => (__delegate != null
      ? __delegate!
      : throw new mongo.MongoDartError(
          'Instance not connected. Must call `open()` first'));

  final String? _debugInfo;
  final String _uriString;

  Completer<void> _whenReadyCompleter = new Completer<void>();
  Future<void> get whenReady => _whenReadyCompleter.future;
  bool get isReady =>
      _whenReadyCompleter.isCompleted && this.state == mongo.State.open;

  AutoReconnectMongo(String uriString, [String? debugInfo])
      : this._uriString = uriString,
        this._debugInfo = debugInfo;

  AutoReconnectMongo.pool(List<String> uriList, [String? debugInfo])
      : this(uriList.join(','), debugInfo);

  static Future<AutoReconnectMongo> create(String uriString,
      [String? _debugInfo]) async {
    if (true || uriString.startsWith('mongodb://')) {
      try {
        var x = AutoReconnectMongo(uriString, _debugInfo);
        MyDebug.myPrint("mongo2   create  success", MyDebug.MyPrintType.Mongo2);
        return x;
      } catch (e) {
        MyDebug.myPrint("mongo2   create  fail", MyDebug.MyPrintType.Mongo2);
        //MyDebug.myPrint("error:    $e",MyDebug.MyPrintType.Mongo2);
        //MyDebug.myPrint("error in MongoDbImpl connect() trying in 5 seconds...",MyDebug.MyPrintType.Mongo2);
        return Future.delayed(AutoReconnectMongo.smallDelay, () {
          return create(uriString, _debugInfo);
        });
      }
    } else if (uriString.startsWith('mongodb+srv://')) {
      try {
        var temp = await mongo.Db.create(uriString);
        return AutoReconnectMongo.pool(temp.uriList, _debugInfo);
      } catch (e) {
        MyDebug.myPrint("error:    $e", MyDebug.MyPrintType.Mongo2);
        MyDebug.myPrint("error in MongoDbImpl connect() trying in 5 seconds...",
            MyDebug.MyPrintType.Mongo2);
        return Future.delayed(AutoReconnectMongo.smallDelay, () {
          return create(uriString, _debugInfo);
        });
      }
    } else {
      throw mongo.MongoDartError(
          'The only valid schemas for Db are: "mongodb" and "mongodb+srv".');
    }
  }

  @override
  Future<void> open(
      {mongo.WriteConcern writeConcern = mongo.WriteConcern.acknowledged,
      bool secure = false,
      bool tlsAllowInvalidCertificates = false,
      String? tlsCAFile,
      String? tlsCertificateKeyFile,
      String? tlsCertificateKeyFilePassword,
      bool acquire = true}) async {
    try {
      //this.__delegate ??= await mongo.Db.create(_uriString, _debugInfo);
      this.__delegate = await mongo.Db.create(_uriString, _debugInfo);
      MyDebug.myPrint(
          "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] open[a]  success",
          MyDebug.MyPrintType.Mongo2);
    } catch (e) {
      MyDebug.myPrint(
          "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] open[a]  fail",
          MyDebug.MyPrintType.Mongo2);
      //MyDebug.myPrint("error:    $e",MyDebug.MyPrintType.Mongo2);
      //MyDebug.myPrint("error in MongoDbImpl  open() trying in 5 seconds...",MyDebug.MyPrintType.Mongo2);
      return Future.delayed(AutoReconnectMongo.smallDelay, () {
        if (acquire) {
          //_m.acquire();
        }
        return open(
            secure: secure,
            tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
            tlsCAFile: tlsCAFile,
            tlsCertificateKeyFile: tlsCertificateKeyFile,
            tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword,
            writeConcern: writeConcern);
      });
    }
    /*unawaited(_delegate
            .open(
      writeConcern: writeConcern,
      secure: secure,
      tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
      tlsCAFile: tlsCAFile,
      tlsCertificateKeyFile: tlsCertificateKeyFile,
      tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword,
    )
            .catchError((e) {
      var retryDelay = MongoDbImpl.smallDelay;
      MyDebug.myPrint("error:    $e",MyDebug.MyPrintType.Mongo2);
      MyDebug.myPrint(
          'MongoDb not ready,  MongoDbImpl open() retrying in $retryDelay ...',MyDebug.MyPrintType.Mongo2);
      return Future.delayed(
          retryDelay,
          () => this.open(
                writeConcern: writeConcern,
                secure: secure,
                tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
                tlsCAFile: tlsCAFile,
                tlsCertificateKeyFile: tlsCertificateKeyFile,
                tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword,
              ));
    }).then((x) => (!_whenReadyCompleter.isCompleted
                ? _whenReadyCompleter.complete(x)
                : x)) // TODO: why is this sometimes already completed / tries to complete twice?
        );

    return whenReady;*/
    return _delegate
        .open(
      writeConcern: writeConcern,
      secure: secure,
      tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
      tlsCAFile: tlsCAFile,
      tlsCertificateKeyFile: tlsCertificateKeyFile,
      tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword,
    )
        .catchError((e) {
      var retryDelay = AutoReconnectMongo.smallDelay;
      MyDebug.myPrint(
          "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] open[b]  fail",
          MyDebug.MyPrintType.Mongo2);
      //MyDebug.myPrint("error:    $e",MyDebug.MyPrintType.Mongo2);
      //MyDebug.myPrint(
      //    'MongoDb not ready,  MongoDbImpl open() retrying in $retryDelay ...',MyDebug.MyPrintType.Mongo2);
      return Future.delayed(retryDelay, () {
        close(); //not awaited
        return this.open(
          writeConcern: writeConcern,
          secure: secure,
          tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
          tlsCAFile: tlsCAFile,
          tlsCertificateKeyFile: tlsCertificateKeyFile,
          tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword,
        );
      });
    }).then((x) {
      MyDebug.myPrint(
          "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] open[b]  success",
          MyDebug.MyPrintType.Mongo2);
      return x;
    });
  }

  Future<void> reconnect123() async => _reconnect();
  DateTime _lastReconnect = DateTime.now();
  bool nextReconnect = true;
  Future<void> _reconnect() async {
    if (!nextReconnect ||
        DateTime.now().difference(_lastReconnect).inSeconds <
            AutoReconnectMongo.smallDelaySec) {
      return Future.delayed(AutoReconnectMongo.smallDelay);
    }
    nextReconnect = false;
    MyDebug.myPrint(
        "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] reconnect  ...",
        MyDebug.MyPrintType.Mongo2);
    //MyDebug.myPrint(
    //    'Lost connection to MongoDB MongoDbImpl _reconnect() - reconnecting...',MyDebug.MyPrintType.Mongo2);
    await close();
    //await open().then((_) => MyDebug.myPrint('Reconnected to MongoDB',MyDebug.MyPrintType.Mongo2));
    //return whenReady;
    return open().then((_) {
      MyDebug.myPrint(
          "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] reconnect  finished",
          MyDebug.MyPrintType.Mongo2);
      //MyDebug.myPrint('Reconnected to MongoDB',MyDebug.MyPrintType.Mongo2);
    }).onError((error, stackTrace) {
      MyDebug.myPrint(
          "mongo2  [of ${this.hashCode}/${__delegate?.hashCode}] reconnect  failed",
          MyDebug.MyPrintType.Mongo2);
    }).whenComplete(() {
      _lastReconnect = DateTime.now();
      nextReconnect = true;
    });
  }

  // -- passthrus

  @override
  mongo.Db? get authSourceDb => _delegate.authSourceDb;
  @override
  set authSourceDb(mongo.Db? _authSourceDb) =>
      _delegate.authSourceDb = _authSourceDb;

  //... etc, etc, etc for 36 other getters/setters/methods ...

  @override
  mongo.DbCollection collection(String collectionName) =>
      MongoCollection(this, collectionName);

  @override
  String? get databaseName => _delegate.databaseName;
  @override
  set databaseName(String? x) => _delegate.databaseName = x;

  @override
  mongo.ReadPreference get readPreference => _delegate.readPreference;
  @override
  set readPreference(mongo.ReadPreference x) => _delegate.readPreference = x;

  @override
  mongo.State get state => _delegate.state;
  @override
  set state(mongo.State x) => _delegate.state = x;

  @override
  Stream<Map<String, dynamic>> aggregate(List<Map<String, Object>> pipeline,
          {bool? explain,
          Map<String, Object>? cursor,
          String? hint,
          Map<String, Object>? hintDocument,
          mongo.AggregateOptions? aggregateOptions,
          Map<String, Object>? rawOptions}) =>
      throw UnimplementedError();

  @override
  Future<bool> authenticate(String userName, String password,
      {mongo.Connection? connection}) {
    // TODO: implement authenticate
    throw UnimplementedError();
  }

  @override
  Future close() {
    _closeLaterButWithoutAwait();
    return Future.value();
  }

  void _closeLaterButWithoutAwait() {
    // TODO: implement close
    //throw UnimplementedError();
    /*return Future.value(() async {
      __delegate = null;
      _delegate.close();
    });
    return _delegate.close().then((value) {
      __delegate = null;
    });*/

    //__delegate = null;
    //return Future.value(tmp?.close().catchError((_) {}));
    ///
    ///
    ///
    // don't close right now, maybe requests waiting to response
    var tmp = __delegate;
    var print = (s) => MyDebug.myPrint(
        "mongo2  inner [of ${this.hashCode}/${__delegate?.hashCode}] finally closed? $s",
        MyDebug.MyPrintType.Mongo2);
    if (tmp != null) {
      // not awaited!
      Future.delayed(
          Duration(seconds: MyDebug.MyConsts.mongo2CloseNoAwaitDelaySec), () {
        if (tmp.state != mongo.State.closed &&
            tmp.state != mongo.State.closing) {
          tmp
              .close()
              .then((_) => print("success"))
              .catchError((_) => print("failed"));
        }
      });
    }
  }

  @override
  Stream<Map<String, dynamic>> collectionsInfoCursor([String? collectionName]) {
    // TODO: implement collectionsInfoCursor
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> createCollection(String name,
      {mongo.CreateCollectionOptions? createCollectionOptions,
      Map<String, Object>? rawOptions}) {
    // TODO: implement createCollection
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createIndex(String collectionName,
      {String? key,
      Map<String, dynamic>? keys,
      bool? unique,
      bool? sparse,
      bool? background,
      bool? dropDups,
      Map<String, dynamic>? partialFilterExpression,
      String? name}) {
    // TODO: implement createIndex
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> createView(
      String view, String source, List pipeline,
      {mongo.CreateViewOptions? createViewOptions,
      Map<String, Object>? rawOptions}) {
    // TODO: implement createView
    throw UnimplementedError();
  }

  @override
  bool documentIsNotAnError(firstRepliedDocument) {
    // TODO: implement documentIsNotAnError
    throw UnimplementedError();
  }

  @override
  Future drop() {
    // TODO: implement drop
    throw UnimplementedError();
  }

  @override
  Future<bool> dropCollection(String collectionName) {
    // TODO: implement dropCollection
    throw UnimplementedError();
  }

  @override
  Future ensureIndex(String collectionName,
      {String? key,
      Map<String, dynamic>? keys,
      bool? unique,
      bool? sparse,
      bool? background,
      bool? dropDups,
      Map<String, dynamic>? partialFilterExpression,
      String? name}) {
    // TODO: implement ensureIndex
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> executeDbCommand(mongo.MongoMessage message,
      {mongo.Connection? connection}) {
    // TODO: implement executeDbCommand
    throw UnimplementedError();
  }

  @override
  void executeMessage(
      mongo.MongoMessage message, mongo.WriteConcern? writeConcern,
      {mongo.Connection? connection}) {
    // TODO: implement executeMessage
  }

  @override
  Future<Map<String, Object?>> executeModernMessage(MongoModernMessage message,
      {mongo.Connection? connection, bool skipStateCheck = false}) {
    // TODO: implement executeModernMessage
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getBuildInfo({mongo.Connection? connection}) {
    // TODO: implement getBuildInfo
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getCollectionInfos(
      [Map<String, dynamic> filter = const {}]) {
    // TODO: implement getCollectionInfos
    throw UnimplementedError();
  }

  @override
  Future<List<String?>> getCollectionNames(
      [Map<String, dynamic> filter = const {}]) {
    // TODO: implement getCollectionNames
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getLastError(
      [mongo.WriteConcern? writeConcern]) {
    // TODO: implement getLastError
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getNonce({mongo.Connection? connection}) {
    // TODO: implement getNonce
    throw UnimplementedError();
  }

  @override
  Future<List> indexInformation([String? collectionName]) {
    // TODO: implement indexInformation
    throw UnimplementedError();
  }

  @override
  // TODO: implement isConnected
  bool get isConnected => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> isMaster({mongo.Connection? connection}) {
    // TODO: implement isMaster
    throw UnimplementedError();
  }

  @override
  Future<List<String?>> listCollections() {
    // TODO: implement listCollections
    throw UnimplementedError();
  }

  @override
  Future<List> listDatabases() {
    // TODO: implement listDatabases
    throw UnimplementedError();
  }

  @override
  // TODO: implement masterConnection
  mongo.Connection get masterConnection => throw UnimplementedError();

  @override
  // TODO: implement masterConnectionAnyState
  mongo.Connection get masterConnectionAnyState => throw UnimplementedError();

  @override
  Future<Map<String, Object?>> modernDrop(String collectionNAme,
      {DropOptions? dropOptions, Map<String, Object>? rawOptions}) {
    // TODO: implement modernDrop
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> modernDropDatabase(
      {DropDatabaseOptions? dropOptions, Map<String, Object>? rawOptions}) {
    // TODO: implement modernDropDatabase
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> modernListCollections(
      {mongo.SelectorBuilder? selector,
      Map<String, Object?>? filter,
      ListCollectionsOptions? findOptions,
      Map<String, Object>? rawOptions}) {
    // TODO: implement modernListCollections
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> pingCommand() {
    // TODO: implement pingCommand
    throw UnimplementedError();
  }

  @override
  Future<mongo.MongoReplyMessage> queryMessage(mongo.MongoMessage queryMessage,
      {mongo.Connection? connection}) {
    // TODO: implement queryMessage
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> removeFromCollection(String collectionName,
      [Map<String, dynamic> selector = const {},
      mongo.WriteConcern? writeConcern]) {
    // TODO: implement removeFromCollection
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> runCommand(Map<String, Object>? command) {
    // TODO: implement runCommand
    throw UnimplementedError();
  }

  @override
  void selectAuthenticationMechanism(String authenticationSchemeName) {
    // TODO: implement selectAuthenticationMechanism
  }

  @override
  Future<Map<String, Object?>> serverStatus({Map<String, Object>? options}) {
    // TODO: implement serverStatus
    throw UnimplementedError();
  }

  @override
  // TODO: implement uriList
  List<String> get uriList => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> wait() {
    // TODO: implement wait
    throw UnimplementedError();
  }

  @override
  // TODO: implement writeConcern
  mongo.WriteConcern? get writeConcern => throw UnimplementedError();
}

class MongoCollection implements mongo.DbCollection {
  final AutoReconnectMongo _db;
  mongo.DbCollection _delegate;
  final String _initCN;
  MongoCollection(this._db, String collectionName)
      : _delegate = _db._delegate.collection(collectionName),
        _initCN = collectionName;

  Future<void> get whenReady => _db.whenReady;

  static int limit = MyDebug.MyConsts.mongoCollectionPoolLimit;
  static int balance = 0;
  Future<void> _reconnect() {
    //return _db._reconnect(); //.then((_) => this.whenReady);
    MyDebug.myPrint(
        "mongocollection [of ${this.hashCode}/${_delegate.hashCode}:${_delegate.db.hashCode}] reconnect ... [$balance/$limit]",
        MyDebug.MyPrintType.Mongo2);
    return _db._reconnect().then((value) {
      _delegate = _db._delegate.collection(_initCN);
      //MyDebug.myPrint("mongocollection  reconnect  ; [$balance/$limit]",MyDebug.MyPrintType.Mongo2);
    }).onError((error, stackTrace) {
      MyDebug.myPrint(
          "mongocollection [of ${this.hashCode}/${_delegate.hashCode}:${_delegate.db.hashCode}] err $error",
          MyDebug.MyPrintType.Mongo2);
    }); //.then((_) => this.whenReady);
  }

  Stream<T> _tryWithReconnectStream<T>(
      Stream<T> Function() computation) async* {
    try {
      balance++;
      var x = computation();
      balance--;
      yield* x;
    } catch (e) {
      /*} on mongo.MongoDartError catch (e) {
      // ignore: avoid_catching_errors
      if (e.message == 'No master connection') {*/
      if (balance > limit) {
        MyDebug.myPrint(
            "_tryWithReconnectStream rethrow [of ${this.hashCode}/${_delegate.hashCode}:${_delegate.db.hashCode}]",
            MyDebug.MyPrintType.Rethrow);
        rethrow;
      }
      await _reconnect();
      balance--;
      yield* _tryWithReconnectStream(computation);
      /*  } else {
        rethrow;
      }*/
    } finally {}
  }

  Future<T> _tryWithReconnectFuture<T>(Future<T> Function() computation) async {
    try {
      balance++;
      var rslt = await computation();
      return Future.value(rslt);
    } catch (e) {
      /*} on mongo.MongoDartError catch (e) {
      // ignore: avoid_catching_errors
      if (e.message == 'No master connection' ){*/
      if (balance > limit) {
        MyDebug.myPrint(
            "_tryWithReconnectFuture rethrow [of ${this.hashCode}/${_delegate.hashCode}:${_delegate.db.hashCode}]",
            MyDebug.MyPrintType.Rethrow);
        rethrow;
      }
      await _reconnect();
      return _tryWithReconnectFuture(computation);
      /*} else {
        rethrow;
      }*/
    } finally {
      balance--;
    }
  }

  // -- passthrus

  @override
  Future<Map<String, dynamic>?> findOne([dynamic selector]) =>
      _tryWithReconnectFuture(() => _delegate.findOne(selector));

  @override
  Stream<Map<String, dynamic>> legacyFind([dynamic selector]) =>
      _tryWithReconnectStream(() => _delegate.legacyFind(selector));

  @override
  String get collectionName => _delegate.collectionName;
  @override
  set collectionName(String x) => _delegate.collectionName = x;

  @override
  mongo.Db get db => _delegate.db;
  @override
  set db(mongo.Db x) => _delegate.db = x;

  @override
  mongo.ReadPreference get readPreference => _delegate.readPreference;
  @override
  set readPreference(mongo.ReadPreference x) => _delegate.readPreference = x;

  @override
  Future<Map<String, dynamic>> aggregate(List pipeline,
          {bool allowDiskUse = false, Map<String, Object>? cursor}) =>
      _tryWithReconnectFuture(() => _delegate.aggregate(pipeline,
          allowDiskUse: allowDiskUse, cursor: cursor));

  @override
  Stream<Map<String, dynamic>> aggregateToStream(
          List<Map<String, Object>> pipeline,
          {Map<String, Object> cursorOptions = const <String, Object>{},
          bool allowDiskUse = false}) =>
      _tryWithReconnectStream(() => _delegate.aggregateToStream(pipeline,
          allowDiskUse: allowDiskUse, cursorOptions: cursorOptions));

  @override
  Future<mongo.BulkWriteResult> bulkWrite(List<Map<String, Object>> documents,
          {bool ordered = true, mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(() => _delegate.bulkWrite(documents,
          ordered: ordered, writeConcern: writeConcern));

  @override
  Future<int> count([selector]) =>
      _tryWithReconnectFuture(() => _delegate.count(selector));

  @override
  mongo.Cursor createCursor([selector]) => _delegate.createCursor(selector);

  @override
  Future<Map<String, dynamic>> createIndex(
          {String? key,
          Map<String, dynamic>? keys,
          bool? unique,
          bool? sparse,
          bool? background,
          bool? dropDups,
          Map<String, dynamic>? partialFilterExpression,
          String? name,
          bool? modernReply}) =>
      _tryWithReconnectFuture(() => _delegate.createIndex(
          key: key,
          background: background,
          dropDups: dropDups,
          keys: keys,
          modernReply: modernReply,
          name: name,
          partialFilterExpression: partialFilterExpression,
          sparse: sparse,
          unique: unique));

  @override
  Future<mongo.WriteResult> deleteMany(selector,
          {mongo.WriteConcern? writeConcern,
          mongo.CollationOptions? collation,
          String? hint,
          Map<String, Object>? hintDocument}) =>
      _tryWithReconnectFuture(() => _delegate.deleteMany(selector,
          collation: collation,
          hint: hint,
          hintDocument: hintDocument,
          writeConcern: writeConcern));

  @override
  Future<mongo.WriteResult> deleteOne(selector,
          {mongo.WriteConcern? writeConcern,
          mongo.CollationOptions? collation,
          String? hint,
          Map<String, Object>? hintDocument}) =>
      _tryWithReconnectFuture(() => _delegate.deleteOne(selector,
          collation: collation,
          hint: hint,
          hintDocument: hintDocument,
          writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> distinct(String field, [selector]) =>
      _tryWithReconnectFuture(() => _delegate.distinct(field, selector));

  @override
  Future<bool> drop() => _tryWithReconnectFuture(() => _delegate.drop());

  @override
  Future<Map<String, dynamic>> dropIndexes(Object index,
          {mongo.WriteConcern? writeConcern,
          String? comment,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectFuture(() => _delegate.dropIndexes(index,
          comment: comment,
          rawOptions: rawOptions,
          writeConcern: writeConcern));

  @override
  Stream<Map<String, dynamic>> find([selector]) =>
      _tryWithReconnectStream(() => _delegate.find(selector));

  @override
  Future<Map<String, dynamic>?> findAndModify(
          {query,
          sort,
          bool? remove,
          update,
          bool? returnNew,
          fields,
          bool? upsert}) =>
      _tryWithReconnectFuture(() => _delegate.findAndModify(
          fields: fields,
          query: query,
          remove: remove,
          returnNew: returnNew,
          sort: sort,
          update: update,
          upsert: upsert));

  @override
  String fullName() => _delegate.fullName();

  @override
  Future<List<Map<String, dynamic>>> getIndexes() =>
      _tryWithReconnectFuture(() => _delegate.getIndexes());

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> document,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(
          () => _delegate.insert(document, writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> insertAll(List<Map<String, dynamic>> documents,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(
          () => _delegate.insertAll(documents, writeConcern: writeConcern));

  @override
  Future<mongo.BulkWriteResult> insertMany(List<Map<String, dynamic>> documents,
          {mongo.WriteConcern? writeConcern,
          bool? ordered,
          bool? bypassDocumentValidation}) =>
      _tryWithReconnectFuture(() => _delegate.insertMany(documents,
          bypassDocumentValidation: bypassDocumentValidation,
          ordered: ordered,
          writeConcern: writeConcern));

  @override
  Future<mongo.WriteResult> insertOne(Map<String, dynamic> document,
          {mongo.WriteConcern? writeConcern, bool? bypassDocumentValidation}) =>
      _tryWithReconnectFuture(() => _delegate.insertOne(document,
          bypassDocumentValidation: bypassDocumentValidation,
          writeConcern: writeConcern));

  @override
  Stream<Map<String, dynamic>> legacyAggregateToStream(List pipeline,
          {Map<String, dynamic> cursorOptions = const {},
          bool allowDiskUse = false}) =>
      _tryWithReconnectStream(() => _delegate.legacyAggregateToStream(pipeline,
          allowDiskUse: allowDiskUse, cursorOptions: cursorOptions));

  @override
  Future<int> legacyCount([selector]) =>
      _tryWithReconnectFuture(() => _delegate.legacyCount(selector));

  @override
  Future<Map<String, dynamic>> legacyDistinct(String field, [selector]) =>
      _tryWithReconnectFuture(() => _delegate.legacyDistinct(field, selector));

  @override
  Future<Map<String, dynamic>?> legacyFindAndModify(
          {query,
          sort,
          bool? remove,
          update,
          bool? returnNew,
          fields,
          bool? upsert}) =>
      _tryWithReconnectFuture(() => _delegate.legacyFindAndModify(
          fields: fields,
          query: query,
          remove: remove,
          returnNew: returnNew,
          sort: sort,
          update: update,
          upsert: upsert));

  @override
  Future<Map<String, dynamic>?> legacyFindOne([selector]) =>
      _tryWithReconnectFuture(() => _delegate.legacyFindOne(selector));

  @override
  Future<Map<String, dynamic>> legacyInsert(Map<String, dynamic> document,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(
          () => _delegate.legacyInsert(document, writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> legacyInsertAll(
          List<Map<String, dynamic>> documents,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(() =>
          _delegate.legacyInsertAll(documents, writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> legacyRemove(selector,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(
          () => _delegate.legacyRemove(selector, writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> legacyUpdate(selector, document,
          {bool upsert = false,
          bool multiUpdate = false,
          mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(() => _delegate.legacyUpdate(selector, document,
          multiUpdate: multiUpdate,
          upsert: upsert,
          writeConcern: writeConcern));

  @override
  Stream<Map<String, dynamic>> listIndexes(
          {int? batchSize, String? comment, Map<String, Object>? rawOptions}) =>
      _tryWithReconnectStream(() => _delegate.listIndexes(
          batchSize: batchSize, comment: comment, rawOptions: rawOptions));

  @override
  Stream<Map<String, dynamic>> modernAggregate(pipeline,
          {bool? explain,
          Map<String, Object>? cursor,
          String? hint,
          Map<String, Object>? hintDocument,
          mongo.AggregateOptions? aggregateOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectStream(() => _delegate.modernAggregate(pipeline,
          aggregateOptions: aggregateOptions,
          cursor: cursor,
          explain: explain,
          hint: hint,
          hintDocument: hintDocument,
          rawOptions: rawOptions));

  @override
  ModernCursor modernAggregateCursor(pipeline,
          {bool? explain,
          Map<String, Object>? cursor,
          String? hint,
          Map<String, Object>? hintDocument,
          mongo.AggregateOptions? aggregateOptions,
          Map<String, Object>? rawOptions}) =>
      _delegate.modernAggregateCursor(pipeline,
          aggregateOptions: aggregateOptions,
          cursor: cursor,
          explain: explain,
          hint: hint,
          hintDocument: hintDocument,
          rawOptions: rawOptions);

  @override
  Future<CountResult> modernCount(
          {mongo.SelectorBuilder? selector,
          Map<String, Object?>? filter,
          int? limit,
          int? skip,
          mongo.CollationOptions? collation,
          String? hint,
          Map<String, Object>? hintDocument,
          CountOptions? countOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectFuture(() => _delegate.modernCount(
          collation: collation,
          countOptions: countOptions,
          filter: filter,
          hint: hint,
          hintDocument: hintDocument,
          limit: limit,
          rawOptions: rawOptions,
          selector: selector,
          skip: skip));

  @override
  Future<DistinctResult> modernDistinct(String field,
          {query,
          DistinctOptions? distinctOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectFuture(() => _delegate.modernDistinct(field,
          distinctOptions: distinctOptions,
          query: query,
          rawOptions: rawOptions));

  @override
  Future<Map<String, Object?>> modernDistinctMap(String field,
          {query,
          DistinctOptions? distinctOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectFuture(() => _delegate.modernDistinctMap(field,
          distinctOptions: distinctOptions,
          query: query,
          rawOptions: rawOptions));

  @override
  Stream<Map<String, dynamic>> modernFind(
          {mongo.SelectorBuilder? selector,
          Map<String, Object?>? filter,
          Map<String, Object>? sort,
          Map<String, Object>? projection,
          String? hint,
          Map<String, Object>? hintDocument,
          int? skip,
          int? limit,
          mongo.FindOptions? findOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectStream(() => _delegate.modernFind(
          filter: filter,
          findOptions: findOptions,
          hint: hint,
          hintDocument: hintDocument,
          limit: limit,
          projection: projection,
          rawOptions: rawOptions,
          selector: selector,
          skip: skip,
          sort: sort));

  @override
  Future<mongo.FindAndModifyResult> modernFindAndModify(
          {query,
          sort,
          bool? remove,
          update,
          bool? returnNew,
          fields,
          bool? upsert,
          List? arrayFilters,
          String? hint,
          Map<String, Object>? hintDocument,
          mongo.FindAndModifyOptions? findAndModifyOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectFuture(() => _delegate.modernFindAndModify(
          arrayFilters: arrayFilters,
          fields: fields,
          findAndModifyOptions: findAndModifyOptions,
          hint: hint,
          hintDocument: hintDocument,
          query: query,
          rawOptions: rawOptions,
          remove: remove,
          returnNew: returnNew,
          sort: sort,
          update: update,
          upsert: upsert));

  @override
  Future<Map<String, dynamic>?> modernFindOne(
          {mongo.SelectorBuilder? selector,
          Map<String, Object?>? filter,
          Map<String, Object>? sort,
          Map<String, Object>? projection,
          String? hint,
          Map<String, Object>? hintDocument,
          int? skip,
          mongo.FindOptions? findOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectFuture(() => _delegate.modernFindOne(
          filter: filter,
          findOptions: findOptions,
          hint: hint,
          hintDocument: hintDocument,
          projection: projection,
          rawOptions: rawOptions,
          selector: selector,
          skip: skip,
          sort: sort));

  @override
  Future<Map<String, dynamic>> modernUpdate(selector, update,
          {bool? upsert,
          bool? multi,
          mongo.WriteConcern? writeConcern,
          mongo.CollationOptions? collation,
          List? arrayFilters,
          String? hint,
          Map<String, Object>? hintDocument}) =>
      _tryWithReconnectFuture(() => _delegate.modernUpdate(selector, update,
          arrayFilters: arrayFilters,
          collation: collation,
          hint: hint,
          hintDocument: hintDocument,
          multi: multi,
          upsert: upsert,
          writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> remove(selector,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(
          () => _delegate.remove(selector, writeConcern: writeConcern));

  @override
  Future<mongo.WriteResult> replaceOne(selector, Map<String, dynamic> update,
          {bool? upsert,
          mongo.WriteConcern? writeConcern,
          mongo.CollationOptions? collation,
          String? hint,
          Map<String, Object>? hintDocument}) =>
      _tryWithReconnectFuture(() => _delegate.replaceOne(selector, update,
          collation: collation,
          hint: hint,
          hintDocument: hintDocument,
          upsert: upsert,
          writeConcern: writeConcern));

  @deprecated
  @override
  Future<Map<String, dynamic>> save(Map<String, dynamic> document,
          {mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(
          () => _delegate.save(document, writeConcern: writeConcern));

  @override
  Future<Map<String, dynamic>> update(selector, document,
          {bool upsert = false,
          bool multiUpdate = false,
          mongo.WriteConcern? writeConcern}) =>
      _tryWithReconnectFuture(() => _delegate.update(selector, document,
          multiUpdate: multiUpdate,
          upsert: upsert,
          writeConcern: writeConcern));

  @override
  Future<mongo.WriteResult> updateMany(selector, update,
          {bool? upsert,
          mongo.WriteConcern? writeConcern,
          mongo.CollationOptions? collation,
          List? arrayFilters,
          String? hint,
          Map<String, Object>? hintDocument}) =>
      _tryWithReconnectFuture(() => _delegate.updateMany(selector, update,
          arrayFilters: arrayFilters,
          collation: collation,
          hint: hint,
          hintDocument: hintDocument,
          upsert: upsert,
          writeConcern: writeConcern));

  @override
  Future<mongo.WriteResult> updateOne(selector, update,
          {bool? upsert,
          mongo.WriteConcern? writeConcern,
          mongo.CollationOptions? collation,
          List? arrayFilters,
          String? hint,
          Map<String, Object>? hintDocument}) =>
      _tryWithReconnectFuture(() => _delegate.updateOne(selector, update,
          arrayFilters: arrayFilters,
          collation: collation,
          hint: hint,
          hintDocument: hintDocument,
          upsert: upsert,
          writeConcern: writeConcern));

  @override
  Stream watch(Object pipeline,
          {int? batchSize,
          String? hint,
          Map<String, Object>? hintDocument,
          mongo.ChangeStreamOptions? changeStreamOptions,
          Map<String, Object>? rawOptions}) =>
      _tryWithReconnectStream(() => _delegate.watch(pipeline,
          batchSize: batchSize,
          changeStreamOptions: changeStreamOptions,
          hint: hint,
          hintDocument: hintDocument,
          rawOptions: rawOptions));

  @override
  ModernCursor watchCursor(Object pipeline,
          {int? batchSize,
          String? hint,
          Map<String, Object>? hintDocument,
          mongo.ChangeStreamOptions? changeStreamOptions,
          Map<String, Object>? rawOptions}) =>
      _delegate.watchCursor(pipeline,
          batchSize: batchSize,
          changeStreamOptions: changeStreamOptions,
          hint: hint,
          hintDocument: hintDocument,
          rawOptions: rawOptions);

  ////////
}

class MongoTest {
  static Future<bool> connectionTest(Db d) async {
    var success = (await d.collection("Events").findOne())?["_id"] != null;
    MyDebug.myPrint(
        "connectionTest() success == $success", MyDebug.MyPrintType.Mongo2Test);
    return success;
  }
}
