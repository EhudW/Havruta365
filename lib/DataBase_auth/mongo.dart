import 'package:flutter/material.dart';
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

  // get mail and password and check if the user is exist.
// if exist - return the user object and go to the home page.
// if not - throw error
  Future<String> isCorrect(String mail, String password) async {
    print("Try to connect...");
    // Connect to the DB
    db = await Db.create(CONNECT_TO_DB);
    await db.open();
    var collection = db.collection('Users');
    // Check if the user exist
    var user = await collection.findOne(where.eq('email', mail));
    print(user);
    if (user == null) {
      return Future<String>(() => "User not exist!");
    }
    // Check the password
    if (user['password'] != password) {
      return Future<String>(() => "Password incorrect!");
    }
    print("Connection Successful");
    db.close();
  }

  // insert new user details
  Future<String> insertNewUser(User user) async {
    // Connect to the DB
    db = await Db.create(CONNECT_TO_DB);
    await db.open();
    var collection = db.collection('Users');
    // Check if the user exist
    int exist = await collection.findOne(where.eq('email', user.email));
    if (exist != null) {
      return Future<String>(() => "User is already exist!");
    }
    // insert a new User
    await collection.save(user.toJson());
    await db.close();
  }

  /*
  Remove user from the DB according to the mail.
   */
  void removeUser(mail) async {
    db = await Db.create(CONNECT_TO_DB);
    await db.open();
    var collection = db.collection('Users');
    collection.remove(where.eq('mail', mail));
    await db.close();
  }

  // update user details
  // insert new event
  // update new event

  void connect(name, age, mail, user, password) async {
    db = await Db.create(
        "mongodb+srv://yanivm93:kr2yptso@Cluster0.imwti.mongodb.net/test?tls=true&retryWrites=true&w=majority");
    await db.open();
    print('Connected to database');
    var coll = db.collection('test');
    await coll.insertAll([
      // info!!
      {
        'login': user,
        'name': name,
        'email': mail,
        'age': age,
        'password': password
      },
    ]);
  }

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

