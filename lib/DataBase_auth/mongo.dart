import 'package:flutter/material.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/main.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'User.dart';

String CONNECT_TO_DB = "mongodb+srv://admin:admin@havruta.c4xko.mongodb.net/Havruta?retryWrites=true&w=majority";

/*
  Class Mongo
  Tips:
   - search for specific document
     coll.find(where.eq('field', 'value')).toList();
     where.match - check if the field *contain* the value
     where.gt - greater then...
     where.lt - little then...
     where.jsQuery - write queries using js.
        for example: return this.name("tani") && this.age > 25;
 */
class Mongo {


  var db;

  // Connect to the DB.
  void connect() async{
    db = await Db.create(CONNECT_TO_DB);
    await db.open();
    print('Connected to database');
    Globals.isDbConnect = true;
  }

  // Check if user exist
  Future<bool> isUserExist(String mail) async{
    // Get the Users Collection
    var collection = await db.collection('Users');
    // Check if the user exist
    var user = await collection.findOne(where.eq('email', '$mail'));
    if (user == null) {
      return false;
    }
    return true;
  }

  // Update exist User
  updateUser(String mail, Map<String, dynamic> details) async{
    var coll = await db.collection('Users');
    details.forEach((key, value) {
      coll.update(where.eq('mail', '$mail'), modify.set(key, value));
    });
  }

  // Check if the user is exist.
  // If not - throw error. O.W - return the user object.
  checkNewUser(String mail) async{
    // Get the Users Collection
    var collection = await db.collection('Users');
    // Check if the user exist
    var user = await collection.findOne(where.eq('email', '$mail'));
    if (user == null) {
      return "User not exist!";
    }
    // OK
    return User.fromJson(user);
  }

  // insert new user details
  insertNewUser(User user) async {
    var collection = db.collection('Users');
    // insert a new User
    await collection.save(user.toJson());
  }

  /*
  Remove user from the DB according to the mail.
   */
  void removeUser(mail) async {
    var collection = db.collection('Users');
    collection.remove(where.eq('mail', mail));
    await db.close();
  }

  //
  void connectGoogle(name, email) async {
    db = await Db.create(
        "mongodb+srv://admin:admin@havruta.c4xko.mongodb.net/test?retryWrites=true&w=majority");
    await db.open();
    print('Connected to database');
    var coll = db.collection('users');
    await coll.insertAll([
      // info!!
      {'name': name, 'email': email},
    ]);
  }

  void send_info(info) async {

  }


  void disconnect() async {
    await db.close();
  }
}

