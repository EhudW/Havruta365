import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'DataBase_auth/User.dart';

class Globals {

  static var db = new Mongo();
  static bool isDbConnect = false;
  static User currentUser;
  static BuildContext context;
}