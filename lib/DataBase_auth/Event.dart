// ------------------------------ Event CLASS ------------------------------

import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Event {
  Event(
      {
      this.creatorUser,
        this.creatorName,
      this.creationDate,
        // type = {havruta = 'H', lesson = 'L'}
      this.type,
      this.topic,
      this.book,
      this.link,
      this.description,
      this.eventImage,
      this.lecturer,
      this.participants,
      this.dates,
      this.maxParticipants});

  var _id;

  get id => _id;

  set id(value) {
    _id = value;
  }

  String creatorUser,
      creatorName,
      type,
      topic,
      book,
      link,
      description,
      eventImage,
      targetGender,
      lecturer;
  int maxParticipants;
  DateTime creationDate;
  List<dynamic> participants;
  List<dynamic> dates;

  // factory Event.fromServerMap(Map data) {
  //   return Event(
  //       id: data['_id'],
  //       creatorUser: data['creatorUser'],
  //       type: data['type'],
  //       creationDate: data['creationDate'],
  //       topic: data['topic'],
  //       book: data['book'],
  //       link: data['link'],
  //       description: data['description'],
  //       eventImage: data['eventImage'],
  //       lecturer: data['lecturer'],
  //       participants: data['participants'],
  //       maxParticipants: data['maxParticipants']);
  // }

  // Return JSON of the event
  Map<String, dynamic> toJson() => {
        'creatorUser': creatorUser,
    'creatorName': creatorName,
        'creationDate': creationDate,
        'topic': topic,
        'book': book,
        'type': type,
        'link': link,
        'targetGender' : targetGender,
        'description': description,
        'eventImage': eventImage,
        'lecturer': lecturer,
        'participants': participants,
        'maxParticipants': maxParticipants,
        'dates': dates
      };

  Event.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        creatorUser = json['creatorUser'],
        creatorName = json['creatorName'],
      creationDate = json['creationDate'],
        topic = json['topic'],
        book = json['book'],
        type = json['type'],
        targetGender = json['targetGender'],
        link = json['link'],
        description = json['description'],
        eventImage = json['eventImage'],
        lecturer = json['lecturer'],
        participants = json['participants'],
        maxParticipants = json['maxParticipants'],
        dates = json['dates'];
}
