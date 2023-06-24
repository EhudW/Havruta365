// assume we have instance of CLASS named x
// x.toJson(x) probably != CLASS.fromJson(x.toJson(x))
// x.toJson(x) might be\behave different from CLASS.fromJson(x.toJson(x))
// since there may be some data we don't want to be in the output json
// however, if we ignore them, then
// json1 = x.toJson(x)
// copy1 = CLASS.fromJson(json1)
// json2 = x.toJson(x)
// copy2 = CLASS.fromJson(json2)
// even if the == operator show    copy2 != copy1
// even if the == operator show    json2 != json1
// still deep compare should give json2 == json1

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:havruta_project/data_base/data_representations/chat_message.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/data_representations/notification.dart';
import 'package:havruta_project/data_base/data_representations/topic.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';

import 'main_test.dart';

// custom encode/decode to handle DateTime
const String prefix = "MYENCODER123";
Object? myEncode(Object? x) {
  String val = "";
  String type = "";
  switch (x.runtimeType) {
    case DateTime:
      val = (x as DateTime).millisecondsSinceEpoch.toString();
      type = 'DateTime';
      break;
    case ObjectId:
      val = (x as ObjectId).$oid;
      type = 'ObjectId';
      break;
    default:
      throw UnsupportedError(
          'not supported json decode/encode for ${x.runtimeType}');
  }
  return '$prefix $type $val';
}

Object? myDecode(Object? key, Object? x) {
  if (x.runtimeType == String && (x as String).startsWith(prefix)) {
    switch (x.split(' ')[1]) {
      case 'DateTime':
        return DateTime.fromMillisecondsSinceEpoch(int.parse(x.split(' ')[2]));
      case 'ObjectId':
        return ObjectId.fromHexString(x.split(' ')[2]);
      default:
        throw Exception('unknown type');
    }
  }
  return x;
}

// change one field a little (0->1  "a"-"hello")
// affet the given value (the list/map itself will cahnge)
dynamic changeByType(dynamic value) {
  switch (value.runtimeType.toString().split("<")[0]) {
    case '_Map':
    case 'Map':
      if (value.isEmpty) return value;
      value.remove(value.keys.first);
      break;
    case 'List':
      if (value.isEmpty) return value;
      value.removeAt(0);
      break;
    default:
      break;
  }
  switch (value.runtimeType) {
    case ObjectId:
      value = ObjectId();
      break;
    case double:
      value = value == 0 ? 1 : 0;
      break;
    case int:
      value = value == 0 ? 1 : 0;
      break;
    case bool:
      value = !value;
      break;
    case String:
      value += 'hello';
      break;
    case DateTime:
      value = (value as DateTime).add(Duration(days: 1));
      break;
    default:
      break;
  }
  return value;
}

// change each field of the json, a little
// affect the given json itself, and may also change it child
// example:
// List x=[1,2]
// Map y={'a':x,'b':1}
// changeLittle(y)
// y is now {'a':x,'b':0}
// x is now [2]
void changeLittle(dynamic json) {
  for (var key in json.keys) {
    json[key] = changeByType(json[key]);
  }
}

// be aware of using json as it is var in dart:convert
// test some instance @testSubjectNotJson, for example Event()
// fromJsonCaller is for example (json)=>Event.fromJson(json)
// ignoreKeys if there are error on field even if it is okay (false positive),
// then give it here
void testJson(
    dynamic testSubjectNotJson, dynamic Function(dynamic json) fromJsonCaller,
    {Set<String> ignoreKeys = const {}}) {
  ignoreKeys = Set.from(ignoreKeys);
  test('Test fromJson toJson [${testSubjectNotJson.runtimeType}]', () {
    // get json
    var json1 = testSubjectNotJson.toJson();
    // remove untested fields
    json1.removeWhere((key, value) => ignoreKeys.contains(key));
    // change the field a little to check changes are okay and affecting the jsons
    changeLittle(json1);
    // recreate instance = copy1 and get its json = json2
    String json1Str = jsonEncode(json1, toEncodable: myEncode);
    var copy1 = fromJsonCaller(jsonDecode(json1Str, reviver: myDecode));
    var json2 = copy1.toJson();
    // ignore untested fields
    json2.removeWhere((key, value) => ignoreKeys.contains(key));

    // json1 we changed with changeLittle, we assume toJson() twice should give same jsons
    // (even if toJson['list']!=toJson['list'] because of the instance id)
    var original = testSubjectNotJson.toJson();

    // check if something lost in the way
    String? keyErr;
    for (var key1 in json1.keys) {
      // deep compare between 2 json on same key1 field
      var get = (j) => jsonEncode(j[key1], toEncodable: myEncode);
      if (get(json1) != get(json2)) {
        keyErr = key1;
        break;
      }
    }
    expect(keyErr, isNull,
        reason:
            "error in key '$keyErr' in [${testSubjectNotJson.runtimeType}]\n" +
                "toJson:\n    ${original[keyErr]}\n" +
                "little change:\n    ${json1[keyErr]}\n" +
                "fromJsonCaller,\ntoJson:\n    ${json2[keyErr]}");
  });
}

Future testAllJsons(
    {required MongoCommands db,
    List<String> ignoreCollections = const []}) async {
  // test data_base representation to/from json
  // jsonForTest.keys should contain all collection names from mongodb,
  // unless ignoreCollections.contains,
  // but can test also other fromJson toJson classes,
  // and should give then 'someNameButNotCollectionName':
  //                      {'json':..., 'constructor':... ,'ignoreFields':Set}
  // 'json' for collection in mongodb will be overriden
  var jsonsForTest = {
    'Events': {
      'constructor': (j) => Event.fromJson(j),
      'ignoreFields': Set<String>()
    },
    'Users': {
      'constructor': (j) => User.fromJson(j),
      // User is auto sub(subs_topics.add) to the user's email itself
      // but the tester change the email, so it will affect subs_topics,
      // and since subs_topics is Map, the affect will be different
      // the behaviour is ok
      'ignoreFields': {'subs_topics'}
    },
    'Topics ': {
      'constructor': (j) => Topic.fromJson(j),
      'ignoreFields': Set<String>()
    },
    'Chats': {
      'constructor': (j) => ChatMessage.fromJson(j),
      // will be max(j['datetime'],_tag)
      // so it will auto correct tag=0 => tag=datetime.milliSecondesSinceEpoch,
      // and the tester isnt reset DateTime, but add 1 day to them
      // 'tag' behavior is okay
      'ignoreFields': {'tag'}
    },
    'Notifications': {
      'constructor': (j) => NotificationUser.fromJson(j),
      'ignoreFields': Set<String>()
    },
  };

  var allCollectionsNames = await (db.db as Db).getCollectionNames();
  dynamic problem1 = allCollectionsNames
      .where((element) => element != null)
      .toSet()
      .difference(jsonsForTest.keys.toSet())
      .difference(ignoreCollections.toSet());
  test('assert testAllJson() is updated with mongodb collections', () {
    alert(problem1, isEmpty,
        reason:
            'found collections in mongo db\n$problem1\nthat aren\'t given to testAllJson(ignoreCollections)\nand not handled in testAllJson()');
  });
  var toBeFetched =
      jsonsForTest.keys.toSet().intersection(allCollectionsNames.toSet());
  var problem2 =
      toBeFetched.where((e) => jsonsForTest[e]!['json'] != null).toSet();
  test(
      'check testAllJsons().jsonsForTest is configured well',
      () => alert(problem2, isEmpty,
          reason:
              'given \'json\' field for\n$problem2\nbut it will override with record from mongodb'));
  // instead of making fake instances, use the last from mongodb
  await Future.wait<Map?>(toBeFetched.map((name) async =>
      jsonsForTest[name]!['json'] = await db.db
          .collection(name)
          .findOne(where.sortBy('_id', descending: true))));

  for (var name_info in jsonsForTest.entries) {
    var name = name_info.key;
    var info = name_info.value;
    var con = info['constructor'] as dynamic Function(dynamic);
    var json = info['json'];
    var ignore = info['ignoreFields'] as Set<String>;
    if (json == null) {
      test(
          'get one record of $name collection',
          () => alert(json, isNotNull,
              reason:
                  'failed,\nor it isn\'t collection and lack of \'json\' in the testAllJsons().jsonsForTest[\'$name\']'));
    } else {
      testJson(con(json), con, ignoreKeys: ignore);
    }
  }
}
