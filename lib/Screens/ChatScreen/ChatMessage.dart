//import 'package:havruta_project/Globals.dart';
//import 'package:mongo_dart_query/mongo_dart_query.dart';

// ignore_for_file: non_constant_identifier_names

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:havruta_project/Globals.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mongo_dart/mongo_dart.dart';

class ChatMessage {
  String? otherPersonAvatar; //only in program
  String? otherPersonName; //only in program
  String get otherPersonMail => amITheSender ? this.dst_mail! : this.src_mail!;
  bool get amITheSender => Globals.currentUser!.email == this.src_mail;
  ChatMessage(
      {this.name,
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

  Map<String, dynamic> toJson() => {
        'avatar': avatar ?? "",
        'name': name ?? "",
        'src_mail': src_mail ?? "",
        'datetime': datetime ?? DateTime.now(),
        'message': message ?? "",
        'dst_mail': dst_mail ?? ""
      };

  ChatMessage.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        avatar = json['avatar'],
        src_mail = json['src_mail'],
        datetime = json['datetime'],
        message = json['message'],
        dst_mail = json['dst_mail'],
        id = json['_id'];

  types.TextMessage toTypesTextMsg() {
    return types.TextMessage(
        author: types.User(id: src_mail!, firstName: name, imageUrl: avatar),
        createdAt: this.datetime!.millisecondsSinceEpoch,
        text: message!,
        id: (id as ObjectId).$oid,
        metadata: {
          "otherPersonAvatar": otherPersonAvatar,
          "otherPersonName": otherPersonName,
          "dst_mail": dst_mail
        });
  }

  ChatMessage.fromTypesTextMsg(types.TextMessage m)
      : name = m.author.firstName,
        avatar = m.author.imageUrl,
        src_mail = m.author.id,
        datetime = DateTime.fromMillisecondsSinceEpoch(m.createdAt!).toLocal(),
        message = m.text,
        dst_mail = m.metadata?["dst_mail"],
        otherPersonAvatar = m.metadata?["otherPersonAvatar"],
        otherPersonName = m.metadata?["otherPersonName"],
        id = ObjectId.fromHexString(m.id);
}
