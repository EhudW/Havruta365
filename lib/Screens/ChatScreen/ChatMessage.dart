import 'package:havruta_project/Globals.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';

class ChatMessage {

  ChatMessage({this.name, this.avatar, this.src_mail, this.datetime, this.message, this.dst_mail});

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


  Map<String, dynamic> toJson() =>
      {
        'avatar': avatar ?? "",
        'name': name ?? "",
        'src_mail': src_mail ?? "",
        'datetime': DateTime.now(),
        'message': message ?? "",
        'dst_mail': dst_mail ?? ""
      };

  ChatMessage.fromJson(Map<String, dynamic> json)
    :
        name = json['name'],
        avatar = json['avatar'],
        src_mail = json['src_mail'],
        datetime = json['datetime'],
        message = json['message'],
        dst_mail = json['dst_mail'];
}

