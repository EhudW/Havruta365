// ------------------------------ Event CLASS ------------------------------

import 'package:havruta_project/DataBase_auth/User.dart';

class Event {
  String _email,
      _type,
      _topic,
      _book,
      _frequency,
      _date,
      _link,
      _description;
  String eventImage;
  int starRating;
  final List<User> _participants;

  String get topic => _topic;
  String get book => _book;

  Event( this._email, this._type, this._topic, this._book, this._date,
      this._participants, this._link, this._description);

  // Return JSON of the event
  Map<String, dynamic> toJson() => {
    'email': _email,
    'type': _type,
    'topic': _topic,
    'book': _book,
    'frequency': _frequency,
    'date': _date,
    'participants': _participants,
    'link': _link,
    'description': _description
  };

  Event.fromJson(Map<String, dynamic> json)
      :
        _email = json['email'],
        _type = json['type'],
        _topic = json['topic'],
        _book = json['book'],
        _frequency = json['frequency'],
        _date = json['date'],
        _participants = json['participants'],
        _description = json['description'];
}
