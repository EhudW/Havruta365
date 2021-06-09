class NotificationUser {
  NotificationUser(
      {this.id,
        this.creatorUser,
        this.creationDate,
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

  String id,
      creatorUser,
      type,
      topic,
      book,
      link,
      description,
      eventImage,
      lecturer;
  int maxParticipants;
  DateTime creationDate;
  List<dynamic> participants;
  List<dynamic> dates;

  factory NotificationUser.fromServerMap(Map data) {
    return NotificationUser(
        id: data['id'],
        creatorUser: data['creatorUser'],
        creationDate: data['creationDate'],
        topic: data['topic'],
        book: data['book'],
        link: data['link'],
        description: data['description'],
        eventImage: data['eventImage'],
        lecturer: data['lecturer'],
        participants: data['participants'],
        maxParticipants: data['maxParticipants']);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'creatorUser': creatorUser,
    'creationDate': creationDate,
    'topic': topic,
    'book': book,
    'link': link,
    'description': description,
    'eventImage': eventImage,
    'lecturer': lecturer,
    'participants': participants,
    'maxParticipants': maxParticipants,
    'dates' : dates
  };

  NotificationUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        creatorUser = json['creatorUser'],
        creationDate = json['creationDate'],
        topic = json['topic'],
        book = json['book'],
        link = json['link'],
        description = json['description'],
        eventImage = json['eventImage'],
        lecturer = json['lecturer'],
        participants = json['participants'],
        maxParticipants = json['maxParticipants'],
        dates = json['dates'];
}
