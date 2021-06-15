import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:mongo_dart/mongo_dart.dart';

class NotificationUser {
  NotificationUser(
      {this.creatorUser,
        this.name,
      this.creationDate,
      this.type,
      this.message,
      this.idEvent
      });

  // type = new_event, join_event
  String creatorUser, name, type, message, idEvent;
  ObjectId id;
  DateTime creationDate;

  factory NotificationUser.fromServerMap(Map data) {
    return NotificationUser(
        creatorUser: data['creatorUser'],
        creationDate: data['creationDate'],
        type: data['type'],
        message: data['message'],
        idEvent: data['idEvent']);
  }

  Map<String, dynamic> toJson() => {
        'creatorUser': creatorUser,
        'creationDate': creationDate,
        'type': type,
        'message': message,
        'name': name,
        'idEvent': idEvent
      };

  NotificationUser.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        creatorUser = json['creatorUser'],
        creationDate = json['creationDate'],
        message = json['message'],
        type = json['type'],
        idEvent = json['idEvent'],
  name = json['name'];
}
