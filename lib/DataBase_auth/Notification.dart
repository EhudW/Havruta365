import 'package:mongo_dart/mongo_dart.dart';

class NotificationUser {
  NotificationUser(
      {this.creatorUser,
        this.name,
        this.destinationUser,
      this.creationDate,
        // type = {join = 'join', newEvent = 'new'}
      this.type,
      this.message,
      this.idEvent
      });

  // type = new_event, join_event
  String? creatorUser, destinationUser, name, type, message;
  ObjectId? id, idEvent;
  DateTime? creationDate;

  factory NotificationUser.fromServerMap(Map data) {
    return NotificationUser(
        creatorUser: data['creatorUser'],
        creationDate: data['creationDate'],
        destinationUser: data['destinationUser'],
        type: data['type'],
        message: data['message'],
        idEvent: data['idEvent']);
  }

  Map<String, dynamic> toJson() => {
        'creatorUser': creatorUser,
        'creationDate': creationDate,
        'destinationUser': destinationUser,
        'type': type,
        'message': message,
        'name': name,
        'idEvent': idEvent
      };

  NotificationUser.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        creatorUser = json['creatorUser'],
        creationDate = json['creationDate'],
        destinationUser = json['destinationUser'],
        message = json['message'],
        type = json['type'],
        idEvent = json['idEvent'],
  name = json['name'];
}
