// ------------------------------ USER CLASS ------------------------------
//import 'dart:convert';

import 'package:havruta_project/DataBase/DataRepresentations/Event.dart';
import 'package:havruta_project/Globals.dart';

class User {
  User(
      {this.name,
      this.heightcm,
      this.email,
      this.password,
      this.phone,
      this.avatar,
      this.birthDate,
      this.address,
      this.yeshiva,
      this.description,
      this.gender,
      this.status})
      : subs_topics = (email == null
            ? {}
            : {
                email: {},
                "allUsers": {"seen": 0}
              });

  String? name,
      email,
      password,
      phone,
      avatar,
      address,
      yeshiva,
      description,
      gender,
      status;
  int? heightcm;
  DateTime? birthDate;
  List<dynamic>? interestList;
  Map subs_topics; // {topic:{"seen":0}}
  // Constructor
  User.fromUser(String name, String email, String gender)
      : subs_topics = {
          email: {},
          "allUsers": {"seen": 0}
        } {
    this.name = name;
    this.email = email;
    this.gender = gender;
    if (gender == 'male')
      this.avatar = Globals.maleAvatar;
    else if (gender == 'female') this.avatar = Globals.femaleAvatar;
  }
  // both User.isForMe && EventsSelectorBuilder.targetForMe should have same logic
  // not consider rejectedQueue
  bool isTargetedForMe(Event e, [bool okWhenCreator = true]) =>
      whyIsNotTargetedForMe(e, okWhenCreator) == null;
  String? whyIsNotTargetedForMe(Event e, [bool okWhenCreator = true]) {
    if (okWhenCreator && e.creatorUser == this.email) return null;
    String? avoid = {"גברים": "F", "נשים": "M"}[e.targetGender];
    if (avoid != null && avoid == this.gender) return "מגדר";
    if (!Event.isStatusOk(e, status)) return "סטטוס משפחתי";
    if (e.minAge > age || age > e.maxAge) return "טווח גילאים";
    return null;
  }

  int get age {
    var now = DateTime.now();
    var _age =
        (birthDate!.isAfter(now) ? 0 : now.difference(birthDate!).inDays) ~/
            365;
    return _age;
  }

  // Add interest to the list
  void addInterest(List<String> interest) {
    interestList!.add(interest);
  }

  // Return JSON of the user
  Map<String, dynamic> toJson() => {
        'name': name ?? "",
        'email': email ?? "",
        'password': password ?? "",
        'birthDate': birthDate ?? "",
        'address': address ?? "",
        'yeshiva': yeshiva ?? "",
        'description': description ?? "",
        'gender': gender ?? "",
        'status': status ?? "",
        'avatar': avatar ?? "",
        'interest': interestList ?? [],
        'phone': phone ?? "",
        'subs_topics': subs_topics,
        'heightcm': heightcm,
      };

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        heightcm = json['heightcm'],
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
        subs_topics = {
          json['email']: {},
          "allUsers": {"seen": 0}
        },
        phone = json['phone'] {
    var x = (json['subs_topics'] ?? {});
    for (String s in x.keys) {
      subs_topics[s] = x[s];
    }
  }
}
