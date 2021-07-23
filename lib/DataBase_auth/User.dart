// ------------------------------ USER CLASS ------------------------------
import 'dart:convert';

import 'package:havruta_project/Globals.dart';

class User {
  User(
      {this.name,
      this.email,
      this.password,
      this.phone,
      this.avatar,
      this.birthDate,
      this.address,
      this.yeshiva,
      this.description,
      this.gender,
      this.status});

  String name,
      email,
      password,
      phone,
      avatar,
      address,
      yeshiva,
      description,
      gender,
      status;
  DateTime birthDate;
  List<dynamic> interestList;

  // Constructor
  User.fromUser(String name, String email, String gender) {
    this.name = name;
    this.email = email;
    this.gender = gender;
    if (gender == 'male')
      this.avatar = Globals.maleAvatar;
    else if (gender == 'female') this.avatar = Globals.femaleAvatar;
  }

  // Add interest to the list
  void addInterest(List<String> interest) {
    interestList.add(interest);
  }

  // Return JSON of the user
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'birthDate': birthDate,
        'address': address,
        'yeshiva': yeshiva,
        'description': description,
        'gender': gender,
        'status': status,
        'avatar': avatar,
        'interest': interestList,
        'phone': phone,
      };

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        password = json['password'],
        birthDate = json['birthDate'],
        address = json['address'],
        yeshiva = json['yeshiva'],
        description = json['description'],
        gender = json['gender'],
        status = json['status'],
        avatar = json['avatar'],
        interestList = json['interest'],
        phone = json['phone'];
}
