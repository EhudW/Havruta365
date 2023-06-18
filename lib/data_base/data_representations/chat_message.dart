//import 'package:havruta_project/globals.dart';
//import 'package:mongo_dart_query/mongo_dart_query.dart';

// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:havruta_project/globals.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mongo_dart/mongo_dart.dart';

class ChatMessage {
  static const List<types.Status> statuses = const [
    types.Status.sending,
    types.Status.sent,
    types.Status.seen,
    types.Status.error,
    types.Status.delivered
  ];
  static bool isOnMongo(types.Status? status) {
    return {1, 2, 4}
        .map((e) => statuses[e])
        .contains(status); // 0 sending, 3 error
  }

  bool isForum;
  int counter;
  // 11 fields [8, 1 id, 2 otherPerson] + _tag
  String? otherPersonAvatar; //only in program
  String? otherPersonName; //only in program
  types.Status status;
  int _tag = 0;
  set tag(int val) => _tag = val;
  int get tag => max(_tag, datetime?.millisecondsSinceEpoch ?? 0);
  void tagNow() => tag = DateTime.now().millisecondsSinceEpoch;

  int get statusAsInt => statuses.indexOf(status);
  String get otherPersonMail =>
      amITheSender || isForum ? this.dst_mail! : this.src_mail!;
  bool get amITheSender => Globals.currentUser!.email == this.src_mail;
  // 9 of 11 [8/8, 1/1 id, 0/2 otherPerson] without _tag
  ChatMessage(
      {this.name,
      this.isForum = false,
      this.status = types.Status.sending,
      this.avatar,
      this.src_mail,
      this.datetime, // no need _tag here
      this.message,
      this.dst_mail,
      this.id,
      this.counter = 0});
  dynamic id;
  // SrcUser details
  String? name;
  String? avatar;
  // Src of message - mail of user
  String? src_mail;
  // Date time of sending
  DateTime? datetime;
  // Body of message
  String? message;
  // Dst of message - mail of user
  String? dst_mail;
  // 8 of 11  [8/8, 0/1 id, 0/2 otherPerson] + _tag
  Map<String, dynamic> toJson() => {
        'avatar': avatar ?? "",
        'name': name ?? "",
        'src_mail': src_mail ?? "",
        'datetime': datetime ?? DateTime.now(),
        'tag': tag,
        'message': message ?? "",
        'dst_mail': dst_mail ?? "",
        'status': statusAsInt,
        'isForum': isForum,
        'counter': counter,
      };
  // 11 of 11  [8/8, 1/1 id, 2/2 otherPerson] + _tag
  ChatMessage.cloneWith(ChatMessage old, {types.Status? newStatus})
      : name = old.name,
        avatar = old.avatar,
        isForum = old.isForum,
        src_mail = old.src_mail,
        datetime = old.datetime,
        _tag = old.tag,
        message = old.message,
        dst_mail = old.dst_mail,
        status = newStatus ?? old.status,
        otherPersonAvatar = old.otherPersonAvatar,
        otherPersonName = old.otherPersonName,
        counter = old.counter,
        id = old.id;
  // 9 of 11  [8/8, 1/1 id, 0/2 otherPerson] + _tag
  ChatMessage.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isForum = json['isForum'] ?? false,
        avatar = json['avatar'],
        src_mail = json['src_mail'],
        datetime = json['datetime'],
        _tag = json['tag']?.toInt() ?? 0,
        message = json['message'],
        dst_mail = json['dst_mail'],
        status = statuses[json['status'] ?? 1],
        counter = json['counter'] ?? 0,
        id = json['_id'];
  // 11 of 11  [8/8, 1/1 id, 2/2 otherPerson] + _tag
  types.TextMessage toTypesTextMsg() {
    return types.TextMessage(
        author: types.User(id: src_mail!, firstName: name, imageUrl: avatar),
        createdAt: this.datetime!.millisecondsSinceEpoch,
        text: message!,
        /*text: message! + //debug
            "\n" +
            datetime!.toString() +
            "\n" +
            ((id as ObjectId?)?.$oid ?? "NULL"),*/
        status: status,
        id: (id as ObjectId?)?.$oid ?? "NULL",
        metadata: {
          "counter": counter,
          "tag": tag,
          "otherPersonAvatar": otherPersonAvatar,
          "otherPersonName": otherPersonName,
          "dst_mail": dst_mail,
          "isForum": isForum,
        });
  }

  // 9 of 11  [8/8, 1/1 id, 2/2 otherPerson] + _tag
  ChatMessage.fromTypesTextMsg(types.TextMessage m)
      : name = m.author.firstName,
        avatar = m.author.imageUrl,
        src_mail = m.author.id,
        isForum = m.metadata?["isForum"] ?? false,
        datetime = DateTime.fromMillisecondsSinceEpoch(m.createdAt!).toLocal(),
        message = m.text,
        counter = m.metadata?["counter"] ?? 0,
        status = m.status ?? statuses[0],
        dst_mail = m.metadata?["dst_mail"],
        _tag = m.metadata?["tag"] ?? 0,
        otherPersonAvatar = m.metadata?["otherPersonAvatar"],
        otherPersonName = m.metadata?["otherPersonName"],
        id = m.id != "NULL" ? ObjectId.fromHexString(m.id) : null;
}
