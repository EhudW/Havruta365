// ------------------------------ Event CLASS ------------------------------

//import 'package:havruta_project/DataBase_auth/User.dart';
//import 'package:mongo_dart/mongo_dart.dart';

import 'package:havruta_project/Globals.dart';

import 'User.dart';

class Event {
  static List<String> statusOps = <String>[
    "סטטוס משפחתי",
    "רווק/ה",
    'נשוי/אה',
    'גרוש/ה',
    'אלמן/נה',
    'לא ידוע',
  ];
  static List<List<dynamic>> onlyForStatus_Options = [
    ["מיועד לכולם", statusOps],
    [
      "רק לרווקים",
      [statusOps[1]]
    ],
    [
      "רק לנשואים",
      [statusOps[2]]
    ],
    [
      "רק לגרושים",
      [statusOps[3]]
    ],
    [
      "רק לאלמנים",
      [statusOps[4]]
    ],
    [
      "לא נשואים",
      [statusOps[1], statusOps[3], statusOps[4]]
    ],
    [
      "גרושים/נשואים/אלמנים",
      [statusOps[2], statusOps[3], statusOps[4]]
    ]
  ];
  static List statusesICanJoin() {
    String myStatus = Globals.currentUser!.status!;
    var rslt = onlyForStatus_Options
        .where((pair) => pair[1].contains(myStatus))
        .map((e) => e[0])
        .toList();
    return rslt.isNotEmpty ? rslt : [onlyForStatus_Options[0][0]];
  }

  Event deepClone() {
    var rslt = Event(
      book: book,
      creationDate: creationDate,
      creatorName: creatorName,
      creatorUser: creatorUser,
      dates: dates == null ? null : List.of(dates!),
      participants: participants == null ? null : List.of(participants!),
      waitingQueue: waitingQueue == null ? null : List.of(waitingQueue!),
      description: description,
      duration: duration,
      eventImage: eventImage,
      lecturer: lecturer,
      link: link,
      location: location,
      maxAge: maxAge,
      maxParticipants: maxParticipants,
      minAge: minAge,
      onlyForStatus: onlyForStatus,
      topic: topic,
      type: type,
    );
    rslt.id = id;
    rslt.targetGender = targetGender;
    rslt.shouldDuplicate = shouldDuplicate;
    return rslt;
  }

  static bool isStatusOk(Event e, String? status) {
    if (e.onlyForStatus == null ||
        e.onlyForStatus == onlyForStatus_Options[0][0]) return true;
    for (var pair in onlyForStatus_Options) {
      if (pair[0] == e.onlyForStatus) {
        return pair[1].contains(status);
      }
    }
    return false;
  }

  static Set statusesCanJoin(String option) {
    for (var pair in onlyForStatus_Options) {
      if (pair[0] == option) {
        return pair[1].toSet();
      }
    }
    return Set();
  }

  late final String? firstInitType;
  late final int firstInitMinAge;
  late final int firstInitMaxAge;
  late final String? firstInitOnlyForStatus;
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
      this.maxAge = 120,
      this.minAge = 0,
      this.onlyForStatus,
      this.duration,
      this.maxParticipants}) {
    this.onlyForStatus = onlyForStatus ?? onlyForStatus_Options[0][0];
    this.firstInitTargetGender = targetGender;
    this.firstInitType = type;
    this.firstInitDates = List.of(dates ?? []);
    this.firstInitMaxAge = maxAge;
    this.firstInitMinAge = minAge;
    this.firstInitOnlyForStatus = onlyForStatus;
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
  int minAge, maxAge;
  String? onlyForStatus;
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
        'maxAge': maxAge,
        'minAge': minAge,
        'onlyForStatus': onlyForStatus ?? onlyForStatus_Options[0][0],
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
        maxAge = json['maxAge'] ?? 120,
        minAge = json['minAge'] ?? 0,
        onlyForStatus = json['onlyForStatus'] ?? onlyForStatus_Options[0][0],
        dates = json['dates'] ?? [],
        duration = json['duration'] ?? 30 {
    this.firstInitTargetGender = targetGender;
    this.firstInitMaxAge = maxAge;
    this.firstInitMinAge = minAge;
    this.firstInitOnlyForStatus = onlyForStatus;
    this.firstInitType = type;
    this.firstInitDates = List.of(dates ?? []);
  }
}
