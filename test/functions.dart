import 'package:flutter_test/flutter_test.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// functions for general test env, or shortcut for fetch data from mongodb

// make warning if rslt not match m
// it won't stop the test, only alert, to stop use expect instead
//     the idea is to avoid calling 'except',
//     which when 'reason' != null => x not match m => stop test
//     'skip' is String / true => will skip even if x match m
// the third param in this function HERE called 'reason'
//     so it easy to change between alert and except
//
// has to be within test() / testWidget()
void alert(dynamic x, Matcher m, {required dynamic reason}) =>
    m.matches(x, {}) ? null : expect(x, m, skip: reason);

Future<void> withMongoCommands(
  Future<void> Function(MongoCommands db) func, {
  Map<MyPrintType, bool> setMyPrintTypes = const {},
  bool verbose = false,
}) async {
  var db = MongoCommands();
  myPrintTypes = Map.from(setMyPrintTypes);
  if (verbose) print('connecting to mongodb...');
  await db.connect();
  if (verbose) print('connected to mongodb.');
  await func(db);
  if (verbose) print('disconnecting from mongodb...');
  await db.disconnect();
  if (verbose) print('disconnected from mongodb.');
}

Future<dynamic> getOneDocumentOf(String collectionName, MongoCommands db) =>
    db.db
        .collection(collectionName)
        .findOne(where.sortBy('_id', descending: true));
