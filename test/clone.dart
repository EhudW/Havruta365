// test .clone(), using .toJson()

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:havruta_project/data_base/data_representations/chat_message.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'json.dart';

String firstMismatch(String json1Str, String json2Str) {
  dynamic json1 = jsonDecode(json1Str, reviver: myDecode);
  dynamic json2 = jsonDecode(json2Str, reviver: myDecode);
  for (var json in [json1, json2])
    for (var key in json.keys) {
      String one = jsonEncode(json1[key], toEncodable: myEncode);
      String two = jsonEncode(json2[key], toEncodable: myEncode);
      if (one != two)
        return 'key=$key\n$one\n$two'; // ignore {'a':1, 'x':null} <-> {'a':1}
    }
  return '- NO diffrence was found -';
}

Future<dynamic> getOneOf(String collectionName, MongoCommands db) => db.db
    .collection(collectionName)
    .findOne(where.sortBy('_id', descending: true));

void _testClones<T>(
  String testTitle,
  T original,
  T Function(T original) cloneMe,
  dynamic Function(T obj) _toJson, [
  Set<String> ignoreJsonFields = const {"_id"},
]) {
  String asFixedString(dynamic json) => jsonEncode(json, toEncodable: myEncode);
  dynamic toJson(T obj) {
    dynamic json = _toJson(obj);
    json.removeWhere((key, value) => ignoreJsonFields.contains(key));
    return json;
  }

  test(testTitle, () {
    original = cloneMe(original); // remove meta-data if exists
    // maybe changing json will affect original, but shouldn't affect clone

    // clone and do changes to original json:
    T clone = cloneMe(original);
    dynamic originalJson = toJson(original);
    String originalAsStrInit = asFixedString(originalJson);
    changeLittle(originalJson);

    // see if the clone was changed and now == original json AFTER changes
    String originalAsStrAfterChange = asFixedString(originalJson);
    dynamic cloneAsStr = asFixedString(toJson(clone));
    bool cloneSameAsOriginalAfterChange =
        cloneAsStr == originalAsStrAfterChange;

    // if changes was done to the original json (from its init state),
    bool someChangesDone = originalAsStrAfterChange != originalAsStrInit;
    if (someChangesDone) {
      // it should not affect the clone
      expect(cloneSameAsOriginalAfterChange, isFalse,
          reason: "changes done with 'changeLittle()' to original,\n" +
              "shouldn\'t reflected in clone\n" +
              "from:\n" +
              "$originalAsStrInit\n" +
              "to:\n" +
              "$originalAsStrAfterChange\n" +
              "first diffrence:\n" +
              firstMismatch(originalAsStrInit, originalAsStrAfterChange));
    }

    // the clone had to be like the original init state
    //bool cloneSameAsOriginalInit = cloneAsStr == originalAsStrInit;
    expect(cloneAsStr, equals(originalAsStrInit),
        reason:
            "original and clone (before any changes) should give same jsons\n" +
                "first diffrence:\n" +
                firstMismatch(originalAsStrInit, cloneAsStr));
  });
}

Future<void> testEventClone(MongoCommands db) async {
  Event event = Event.fromJson(await getOneOf('Events', db));
  _testClones<Event>(
    'Event().deepClone() test',
    event,
    (Event event) => event.deepClone(),
    (Event event) => event.toJson(),
  );
}

Future<void> testChatMessageClone1(MongoCommands db) async {
  ChatMessage msg = ChatMessage.fromJson(await getOneOf('Chats', db));
  _testClones<ChatMessage>(
    'ChatMessaage.fromTypesTextMsg() ChatMessage().toTypesTextMsg() test',
    msg,
    (msg) => ChatMessage.fromTypesTextMsg(msg.toTypesTextMsg()),
    (msg) => msg.toJson(),
    {'_id', 'tag'},
  );
}

Future<void> testChatMessageClone2(MongoCommands db) async {
  ChatMessage msg = ChatMessage.fromJson(await getOneOf('Chats', db));
  _testClones<ChatMessage>(
    'ChatMessage.cloneWith(ChatMessage()) test',
    msg,
    (msg) => ChatMessage.cloneWith(msg),
    (msg) => msg.toJson(),
    {'_id', 'tag'},
  );
}

Future<void> testClones(MongoCommands db) => Future.wait([
      testChatMessageClone1(db),
      testChatMessageClone2(db),
      testEventClone(db),
    ]);
