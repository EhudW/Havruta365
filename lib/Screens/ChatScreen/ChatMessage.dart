//import 'package:havruta_project/Globals.dart';
//import 'package:mongo_dart_query/mongo_dart_query.dart';

// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:havruta_project/Globals.dart';

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
  bool isForum;
  // 11 fields [8, 1 id, 2 otherPerson]
  String? otherPersonAvatar; //only in program
  String? otherPersonName; //only in program
  types.Status status;
  int _tag = 0;
  set tag(int val) => _tag = val;
  int get tag => max(_tag, datetime?.millisecondsSinceEpoch ?? 0);
  void tagNow() => tag = DateTime.now().millisecondsSinceEpoch;

  int get statusAsInt => statuses.indexOf(status);
  String get otherPersonMail => amITheSender ? this.dst_mail! : this.src_mail!;
  bool get amITheSender => Globals.currentUser!.email == this.src_mail;
  // 9 of 11 [8/8, 1/1 id, 0/2 otherPerson]
  ChatMessage(
      {this.name,
      this.isForum = false,
      this.status = types.Status.sending,
      this.avatar,
      this.src_mail,
      this.datetime,
      this.message,
      this.dst_mail,
      this.id});
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
  // 8 of 11  [8/8, 0/1 id, 0/2 otherPerson]
  Map<String, dynamic> toJson() => {
        'avatar': avatar ?? "",
        'name': name ?? "",
        'src_mail': src_mail ?? "",
        'datetime': datetime ?? DateTime.now(),
        'message': message ?? "",
        'dst_mail': dst_mail ?? "",
        'status': statusAsInt,
        'isForum': isForum,
      };
  // 11 of 11  [8/8, 1/1 id, 2/2 otherPerson]
  ChatMessage.cloneWith(ChatMessage old, {types.Status? newStatus})
      : name = old.name,
        avatar = old.avatar,
        isForum = old.isForum,
        src_mail = old.src_mail,
        datetime = old.datetime,
        message = old.message,
        dst_mail = old.dst_mail,
        status = newStatus ?? old.status,
        otherPersonAvatar = old.otherPersonAvatar,
        otherPersonName = old.otherPersonName,
        id = old.id;
  // 9 of 11  [8/8, 1/1 id, 0/2 otherPerson]
  ChatMessage.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isForum = json['isForum'] ?? false,
        avatar = json['avatar'],
        src_mail = json['src_mail'],
        datetime = json['datetime'],
        message = json['message'],
        dst_mail = json['dst_mail'],
        status = statuses[json['status'] ?? 1],
        id = json['_id'];
  // 11 of 11  [8/8, 1/1 id, 2/2 otherPerson]
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
          "otherPersonAvatar": otherPersonAvatar,
          "otherPersonName": otherPersonName,
          "dst_mail": dst_mail,
          "isForum": isForum,
        });
  }

  // 9 of 11  [8/8, 1/1 id, 2/2 otherPerson]
  ChatMessage.fromTypesTextMsg(types.TextMessage m)
      : name = m.author.firstName,
        avatar = m.author.imageUrl,
        src_mail = m.author.id,
        isForum = m.metadata?["isForum"] ?? false,
        datetime = DateTime.fromMillisecondsSinceEpoch(m.createdAt!).toLocal(),
        message = m.text,
        status = m.status ?? statuses[0],
        dst_mail = m.metadata?["dst_mail"],
        otherPersonAvatar = m.metadata?["otherPersonAvatar"],
        otherPersonName = m.metadata?["otherPersonName"],
        id = m.id != "NULL" ? ObjectId.fromHexString(m.id) : null;
}
