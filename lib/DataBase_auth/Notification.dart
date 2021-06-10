import 'package:havruta_project/DataBase_auth/Event.dart';


class NotificationUser {
  NotificationUser(
      {
        this.creatorUser,
        this.creationDate,
        this.type,
        this.message,
        this.idEvent,
        this.description});

  String
      creatorUser,
      type,
      message,
      idEvent,
      description;
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
    'message': message,
    'description': description,
    'idEvent': idEvent
  };

  NotificationUser.fromJson(Map<String, dynamic> json)
      :
        creatorUser = json['creatorUser'],
        creationDate = json['creationDate'],
        message = json['message'],
        type = json['type'],
        idEvent = json['idEvent'];
}
