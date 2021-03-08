// ------------------------------ USER CLASS ------------------------------
import 'dart:convert';

enum Gender { male, female }

enum Status { single, married, divorcee }

class Interest {
  String scope, book;
}

class User {
  String _name, _email, _password, _userName, _birthDate, _address, _yeshiva,
      _descripton;

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  Gender _gender;
  Status _status;
  List<Interest> _interestList;



  // Find the best practice to save an image!

  // Constructor
  User() {
    // Create list for the interests of the user
    _interestList = [];
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

  Gender get gender => _gender;

  set gender(Gender value) {
    _gender = value;
  }

  Status get status => _status;

  set status(Status value) {
    _status = value;
  }

  List<Interest> get interestList => _interestList;

  set interestList(List<Interest> value) {
    _interestList = value;
  }
}
