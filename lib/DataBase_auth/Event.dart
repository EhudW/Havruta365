// ------------------------------ Event CLASS ------------------------------

//import 'package:havruta_project/DataBase_auth/User.dart';
//import 'package:mongo_dart/mongo_dart.dart';

import 'User.dart';

class Event {
  late final String? firstInitType;
  late final List firstInitDates;
  late final String? firstInitTargetGender;
  bool shouldDuplicate = false; //only for program
  Event(
      {this.creatorUser,
      this.creatorName,
      this.creationDate,
      // type = {havruta = 'H', lesson = 'L'}
      this.type,
      this.topic,
      this.book,
      this.link,
      this.location = "",
      this.description,
      this.eventImage,
      this.lecturer,
      this.participants,
      this.waitingQueue,
      this.dates,
      this.duration,
      this.maxParticipants}) {
    this.firstInitTargetGender = targetGender;
    this.firstInitType = type;
    this.firstInitDates = List.of(dates ?? []);
  }

  bool isTargetedFor(User user) => user.isTargetedForMe(this);
  var _id;

  // ignore: unnecessary_getters_setters
  get id => _id;

  set id(value) {
    _id = value;
  }

  String? creatorUser,
      creatorName,
      type,
      topic,
      book,
      link,
      location,
      description,
      eventImage,
      targetGender,
      lecturer;
  int? maxParticipants, duration;
  DateTime? creationDate;
  List<dynamic>? participants;
  List<dynamic>? waitingQueue;
  List<dynamic>? dates;

  // Return JSON of the event
  Map<String, dynamic> toJson() => {
        'creatorUser': creatorUser ?? "לא ידוע",
        'creatorName': creatorName ?? "לא ידוע",
        'creationDate': creationDate ?? DateTime.now(),
        'topic': topic ?? "לא ידוע",
        'book': book ?? "לא ידוע",
        'type': type ?? "לא ידוע",
        'link': link ?? "",
        'location': location ?? "",
        'targetGender': targetGender ?? "לא ידוע",
        'description': description ?? "לא ידוע",
        'eventImage': eventImage,
        'lecturer': lecturer ?? "לא ידוע",
        'participants': participants ?? [],
        'waitingQueue': waitingQueue ?? [],
        'maxParticipants': maxParticipants ?? 15,
        'dates': dates ?? [],
        'duration': duration ?? 30
      };

  Event.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        creatorUser = json['creatorUser'] ?? "לא ידוע",
        creatorName = json['creatorName'] ?? "לא ידוע",
        creationDate = json['creationDate'],
        topic = json['topic'] ?? "לא ידוע",
        book = json['book'] ?? "לא ידוע",
        type = json['type'] ?? "לא ידוע",
        targetGender = json['targetGender'] ?? "לא ידוע",
        link = json['link'] ?? "",
        location = json['location'] ?? "",
        description = json['description'] ?? "לא ידוע",
        eventImage = json['eventImage'],
        lecturer = json['lecturer'] ?? "לא ידוע",
        waitingQueue = json['waitingQueue'] ?? [],
        participants = json['participants'] ?? [],
        maxParticipants = json['maxParticipants'] ?? 15,
        dates = json['dates'] ?? [],
        duration = json['duration'] ?? 30 {
    this.firstInitTargetGender = targetGender;
    this.firstInitType = type;
    this.firstInitDates = List.of(dates ?? []);
  }
}
