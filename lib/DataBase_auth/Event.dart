// ------------------------------ Event CLASS ------------------------------




class Event {
  String _user, _type, _topic, _book, _times, _hour, _date, _participants, _link,
      _descripton;

  String get topic => _topic;
  String get book => _book;

  Event( this._user, this._type, this._topic, this._book, this._times, this._hour,
      this._date, this._participants, this._link, this._descripton);

  // Return JSON of the event
  Map<String, dynamic> toJson() => {
    'user': _user,
    'type': _type,
    'topic': _topic,
    'book': _book,
    'times': _times,
    'hour': _hour,
    'date': _date,
    'participants': _participants,
    'link': _link,
    'descripton': _descripton
  };

  Event.fromJson(Map<String, dynamic> json)

      :
        _user = json['user'],
        _type = json['type'],
        _topic = json['topic'],
        _book = json['book'],
        _times = json['times'],
        _hour = json['hour'],
        _date = json['date'],
        _participants = json['participants'],
        _descripton = json['descripton'];

}
