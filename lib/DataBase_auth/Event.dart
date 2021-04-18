// ------------------------------ Event CLASS ------------------------------

import 'package:havruta_project/DataBase_auth/User.dart';

class Event {

  Event({
    this.eventImage,
    this.creatorUser,
    this.type,
    this.topic,
    this.book,
    this.lecturer,
    this.starRating,
    this.date,
    this.frequency,
    this.participants,
    this.link,
    this.description
  });

  User creatorUser;
  String type,
      topic,
      book,
      frequency,
      date,
      link,
      description;
  String eventImage;
  String lecturer;
  int starRating;
  List<User> participants;


  // Return JSON of the event
  Map<String, dynamic> toJson() =>
      {
        'creatorUser': creatorUser,
        'type': type,
        'topic': topic,
        'book': book,
        'frequency': frequency,
        'date': date,
        'participants': participants,
        'link': link,
        'description': description,
        'eventImage': eventImage,
        'lecturer': lecturer,
        'starRating': starRating
      };

  Event.fromJson(Map<String, dynamic> json)
      :
        creatorUser = json['creatorUser'],
        type = json['type'],
        topic = json['topic'],
        book = json['book'],
        frequency = json['frequency'],
        date = json['date'],
        participants = json['participants'],
        description = json['description'],
        link = json['link'],
        eventImage = json['eventImage'],
        lecturer = json['lecturer'],
        starRating = json['starRating'];
}
