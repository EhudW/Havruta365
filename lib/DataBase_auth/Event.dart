// ------------------------------ Event CLASS ------------------------------

//import 'package:havruta_project/DataBase_auth/User.dart';
//import 'package:mongo_dart/mongo_dart.dart';

import 'package:havruta_project/Globals.dart';

import 'User.dart';

enum EventQueues { Participants, Waiting, Rejected, Left }

class Event {
  String get shortStr {
    String _topic = this.topic?.trim() ?? "";
    String _book = this.book?.trim() ?? "";
    String _type = this.type == "H" ? "חברותא" : "שיעור";
    String t_book = _book != "" ? " ב" + _book : "";
    String t_topic = _topic != "" ? " ב" + _topic : "";
    return _type + t_topic + t_book;
  }

  String longStr([User? __creatorUser]) {
    if (__creatorUser != null && creatorUser != __creatorUser.email)
      throw Exception("mismatch __creatorUser.email");
    String __lecturer = lecturer?.trim() ?? "";
    String __creatorName = creatorName?.trim() ?? "";
    if (__lecturer != "") return shortStr + " מפי הרב/נית " + __lecturer;
    if (__creatorName == "") return shortStr;
    String rabbi = "הרב";
    if (__creatorUser == null) rabbi += "/";
    if (__creatorUser?.gender != 'M') rabbi += "נית";
    return shortStr +
        (type == 'L' ? " ביוזמת " : " עם ") +
        rabbi +
        " " +
        __creatorName;
  }

  // minutes to next date. 0 online, -1 pass,
  int get startIn {
    if (dates == null || dates!.isEmpty) return -1;
    var next = dates!.first as DateTime;
    next = next.toLocal();
    var now = DateTime.now().toLocal();
    var diff = next.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    diff = diff ~/ (1000 * 60);
    if (diff >= 0) return diff;
    if (diff < -1 * duration!) return -1;
    return 0;
  }

  String get typeAsStr => type == "H" ? "חברותא" : "שיעור";

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
  static List<String> NEWlbl_onlyForStatus_Options = [
    "מיועד לכולם",
    "רק לרווקים/ות",
    "רק לנשואים/ות",
    "רק לגרושים/ות",
    "רק לאלמנים/ות",
    "לא נשואים/ות",
    "גרושים/ות, נשואים/ות, אלמנים/ות",
  ];
  static String getNewLbl(String old) {
    for (int i = 0; i < onlyForStatus_Options.length; i++)
      if (onlyForStatus_Options[i][0] == old)
        return NEWlbl_onlyForStatus_Options[i];
    return NEWlbl_onlyForStatus_Options[0];
  }

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
      rejectedQueue: List.of(rejectedQueue),
      leftQueue: List.of(leftQueue),
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

  List<dynamic> of(EventQueues q) {
    switch (q) {
      case EventQueues.Left:
        return this.leftQueue;
      case EventQueues.Participants:
        return this.participants!;
      case EventQueues.Rejected:
        return this.rejectedQueue;
      case EventQueues.Waiting:
        return this.waitingQueue!;
    }
  }

  static String toMongoField(EventQueues q) {
    var name = q.name.toLowerCase();
    if (q == EventQueues.Participants) return name;
    return name + "Queue";
  }

  // only for this event / in mongodb,  not sending here notification, no subs update
  Future<bool> leave(String email) => moveToQueue(email, EventQueues.Left);
  Future<bool> accept(String email) =>
      moveToQueue(email, EventQueues.Participants);
  bool acceptLocal(String email) => moveToQueueLocal(email,
      EventQueues.Participants); // for sync prog; return if done something
  Future<bool> reject(String email) => moveToQueue(email, EventQueues.Rejected);
  bool rejectLocal(String email) => moveToQueueLocal(
      email, EventQueues.Rejected); //for sync prog; return if done something
  Future<bool> join(String email) =>
      moveToQueue(email, EventQueues.Participants);
  Future<bool> joinWaiting(String email) =>
      moveToQueue(email, EventQueues.Waiting);
  Future<bool> removeFromAllQueues(String email) => moveToQueue(email, null);
  bool moveToQueueLocal(String email, EventQueues? queue) {
    bool didSomething = false;
    for (var option in EventQueues.values) {
      List<dynamic> l = of(option);
      if (queue == option && !l.contains(email)) {
        l.add(email);
        didSomething = true;
      }
      if (queue != option && l.contains(email)) {
        l.remove(email);
        didSomething = true;
      }
    }
    return didSomething;
  }

  Future<bool> moveToQueue(String email, EventQueues? queue,
      {bool serverUpdate = true,
      bool thisUpdate = true,
      bool skipIfCan = false}) async {
    // dont use skip if can && moveToQueueLocal
    if (skipIfCan && queue != null && of(queue).contains(email)) return true;
    if (skipIfCan &&
        queue == null &&
        EventQueues.values.every((e) => !of(e).contains(email))) return true;
    var rslt = !serverUpdate ||
        (await Globals.db!.moveToEventQueue(this.id, email, queue));
    if (rslt == false) return false;
    if (thisUpdate) moveToQueueLocal(email, queue);
    return true;
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
      List<dynamic>? rejectedQueue,
      List<dynamic>? leftQueue,
      this.waitingQueue,
      this.dates,
      this.maxAge = 120,
      this.minAge = 0,
      this.onlyForStatus,
      this.duration,
      this.maxParticipants})
      : rejectedQueue = rejectedQueue ?? [],
        leftQueue = leftQueue ?? [] {
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
  List<dynamic> rejectedQueue;
  List<dynamic> leftQueue;
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
        'rejectedQueue': rejectedQueue,
        'leftQueue': leftQueue,
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
        rejectedQueue = json['rejectedQueue'] ?? [],
        leftQueue = json['leftQueue'] ?? [],
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
