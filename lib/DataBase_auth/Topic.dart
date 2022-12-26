import 'package:mongo_dart/mongo_dart.dart';

class Topic {
  Topic({
    this.title,
    this.tags,
  });

  // type = new_event, join_event
  String? title;
  List<dynamic>? tags;
  ObjectId? id;

  factory Topic.fromServerMap(Map data) {
    return Topic(title: data['Title'], tags: data['tags']);
  }

  Map<String, dynamic> toJson() => {
        'Title': title,
        'tags': tags,
      };

  Topic.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        title = json['Title'],
        tags = json['tags'];
}
