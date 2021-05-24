import 'dart:convert';

import 'package:havruta_project/Globals.dart';

class Interest {
  String topic, book;
}

class User {
  User();

  String _name,
      _email,
      _password,
      _userName,
      _avatar,
      _birthDate,
      _address,
      _yeshiva,
      _description,
      _gender,
      _status;

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  List<Interest> _interestList;

  // Constructor
  User.fromUser(String name, String email, String gender) {
    this._name = name;
    this._email = email;
    this._gender = gender;
    if (gender == 'male')
      this._avatar = Globals.maleAvatar;
    else if (gender == 'female') this._avatar = Globals.femaleAvatar;
  }

  // Add interest to the list
  void addInterest(Interest interest) {
    _interestList.add(interest);
  }

  // Return JSON of the user
  Map<String, dynamic> toJson() => {
        'name': _name,
        'email': _email,
        'password': _password,
        'userName': _userName,
        'birthDate': _birthDate,
        'address': _address,
        'yeshiva': _yeshiva,
        'description': _description,
        'gender': _gender,
        'status': _status,
        'interest': _interestList,
      };

  User.fromJson(Map<String, dynamic> json)
      : _name = json['name'],
        _email = json['email'],
        _password = json['password'],
        _userName = json['userName'],
        _birthDate = json['birthDate'],
        _address = json['address'],
        _yeshiva = json['yeshiva'],
        _description = json['description'],
        _gender = json['gender'],
        _status = json['status'],
        _interestList = json['interest'];

  get email => _email;

  set email(value) {
    _email = value;
  }

  get password => _password;

  set password(value) {
    _password = value;
  }

  get userName => _userName;

  set userName(value) {
    _userName = value;
  }

  get avatar => _avatar;

  set avatar(value) {
    _avatar = value;
  }

  get birthDate => _birthDate;

  set birthDate(value) {
    _birthDate = value;
  }

  get address => _address;

  set address(value) {
    _address = value;
  }

  get yeshiva => _yeshiva;

  set yeshiva(value) {
    _yeshiva = value;
  }

  get description => _description;

  set description(value) {
    _description = value;
  }

  get gender => _gender;

  set gender(value) {
    _gender = value;
  }

  get status => _status;

  set status(value) {
    _status = value;
  }

  List<Interest> get interestList => _interestList;

  set interestList(List<Interest> value) {
    _interestList = value;
  }
}
