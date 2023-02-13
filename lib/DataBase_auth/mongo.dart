// ignore_for_file: non_constant_identifier_names

import 'dart:core';
import 'dart:convert';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:mongo_dart/mongo_dart.dart';
//import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Topic.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

String CONNECT_TO_DB =
    "mongodb+srv://admin:admin@havruta.c4xko.mongodb.net/Havruta?retryWrites=true&w=majority";

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
  late var db;

  // Connect to the DB.
  Future<void> connect() async {
    db = await Db.create(CONNECT_TO_DB);
    await db.open();
    print('Connected to database');
    Globals.isDbConnect = true;
  }

  Future<void> insertEvent(Event event) async {
    // MondoDB decrease to hour from the time, because he using UTC. here we fix it.
    for (DateTime date in event.dates as Iterable<DateTime>) {
      date.add(Duration(hours: 2));
    }
    var collection = db.collection('Events');
    var e = event.toJson();
    await collection.insertOne(e);
  }

  Future<User> getUser(String userMail) async {
    var coll = Globals.db!.db.collection('Users');
    var user_json = await coll.findOne(where.eq('email', '$userMail'));
    User user = User.fromJson(user_json);
    return user;
  }

  Future<User> getUserByID(String id) async {
    var coll = Globals.db!.db.collection('Users');
    String sub = id.substring(10, 34);
    ObjectId obj_id = ObjectId.fromHexString(sub);
    var user_json = await coll.findOne(where.eq('_id', obj_id));

    User user = User.fromJson(user_json);
    return user;
  }

  Future<List<Event>> getEventsByQuery(
      {required Future<dynamic> Function(dynamic events) query,
      required bool filterOldEvents}) async {
    List<Event> data = [];
    DateTime timeNow = filterOldEvents ? DateTime.now() : DateTime(1900);

    var collection = db.collection('Events');
    final events = await query(collection);
    for (var i in events) {
      Event e = new Event.fromJson(i);
      var len = e.dates!.length;
      for (int j = 0; j < len; j++) {
        if (timeNow.isAfter(e.dates![j])) {
          e.dates!.remove(e.dates![j]);
          len -= 1;
          j--;
        }
      }
      if (e.dates!.isNotEmpty) {
        data.add(e);
      }
    }
    return data;
  }

  Future<List<Event>> searchEvents(String s,
      {bool filterOldEvents = true,
      int maxEvents = 10,
      int startFrom = 0,
      String? withParticipant, //email
      String? createdBy, //email
      String? typeFilter}) async {
    var query = (collection) async {
      var prefix = where
          .match('book', s)
          .or(where.match('topic', s))
          .or(where.match('lecturer', s));
      if (typeFilter != null) {
        prefix = prefix.eq('type', typeFilter);
      }
      if (withParticipant != null) {
        prefix = prefix.eq("participants", withParticipant);
      } else if (createdBy != null) {
        prefix = prefix.eq("creatorUser", createdBy);
      }
      return await collection
          //.find(prefix.sortBy('_id').skip(startFrom).limit(maxEvents))
          .find(prefix.sortBy('_id').skip(startFrom).limit(maxEvents))
          .toList();
    };
    return getEventsByQuery(query: query, filterOldEvents: filterOldEvents);
  }

  Future<List<Event>> getSomeEvents(int len, String? typeFilter) async {
    var query = (collection) async {
      if (typeFilter == null) {
        return await collection
            .find(where.sortBy('_id').skip(len).limit(10))
            .toList();
      } else {
        return await collection
            .find(
                where.eq('type', typeFilter).sortBy('_id').skip(len).limit(10))
            .toList();
      }
    };
    return getEventsByQuery(query: query, filterOldEvents: true);
  }

  Future<List<Event>> getSomeEventsOnline(int len, String? typeFilter) async {
    assert(typeFilter == null); //for now online is for type = 'L'
    var query = (collection) async => await collection
        .find(where.eq('type', 'L').sortBy('_id').skip(len).limit(10))
        .toList();
    return getEventsByQuery(query: query, filterOldEvents: true);
  }

  // Query all events that currents user register for them.
  Future<List<Event>> getEvents(
      String? userMail, bool filterOldEvents, String? typeFilter) async {
    var query = (collection) async => await collection.find(
        {"participants": userMail ?? Globals.currentUser!.email}).toList();
    if (typeFilter != null) {
      query = (collection) async => await collection.find({
            "participants": userMail ?? Globals.currentUser!.email,
            "type": typeFilter
          }).toList();
    }
    return getEventsByQuery(query: query, filterOldEvents: filterOldEvents);
  }

  Future<List<NotificationUser>> getNotifications() async {
    List<NotificationUser> data = <NotificationUser>[];
    var collection = db.collection('Notifications');
    final notifications = await collection
        .find(where
            .eq('destinationUser', Globals.currentUser!.email)
            .sortBy('_id'))
        .toList();
    for (var i in notifications) {
      data.add(new NotificationUser.fromJson(i));
    }
    return data;
  }

  Future<List<Topic>> getTopics() async {
    List<Topic> data = [];
    var collection = db.collection('Topics ');
    final topics = await collection.find(where.sortBy('_id')).toList();
    for (var i in topics) {
      data.add(Topic.fromJson(i));
    }
    return data;
  }

  Future<void> addParticipant(String? mail, ObjectId? id) async {
    var collection = Globals.db!.db.collection('Events');
    // Get event by id and Add mail to participants array
    // ignore: unused_local_variable
    var res = await collection.updateOne(
        where.eq('_id', id), ModifierBuilder().push('participants', mail));
  }

  Future<void> insertNotification(NotificationUser notification) async {
    var collection = db.collection('Notifications');
    var e = notification.toJson();
    await collection.insertOne(e);
    var url = Uri.parse('http://yonatangat.pythonanywhere.com/mail');
    var x = {
      "subject": "פרוייקט חברותא",
      "body": notification.name! + "  " + notification.message!,
      "src": "havrutaproject@gmail.com",
      "src_pass": "havruta365",
      "dst": notification.destinationUser
    };
    // ignore: unused_local_variable
    var response = await http.post(url,
        body: json.encode(x), headers: {'Content-Type': 'application/json'});
  }

  Future<void> deleteNotification(NotificationUser notification) async {
    var collection = db.collection('Notifications');
    await collection.deleteOne({"_id": notification.id});
  }

  deleteFromEvent(ObjectId? id, String? email) async {
    var collection = Globals.db!.db.collection('Events');
    // Get event by id and Add mail to participants array
    // ignore: unused_local_variable
    var res = await collection.updateOne(
        where.eq('_id', id), ModifierBuilder().pull('participants', email));
  }

  // Check if user exist
  Future<bool> isUserExist(String mail) async {
    // Get the Users Collection
    var collection = db.collection('Users');
    // Check if the user exist
    var user = await collection.findOne(where.eq('email', mail));
    if (user == null) {
      return false;
    }
    return true;
  }

  Future<bool> isPassNull(String mail) async {
    var coll = Globals.db!.db.collection('Users');
    var user_json = await coll.findOne(where.eq('email', '$mail'));
    User user = User.fromJson(user_json);
    if (user.password == null || user.password == "") {
      return false;
    }
    return true;
  }

  // Check if the user is exist.
  // If not - throw error. O.W - return the user object.
  checkNewUser(String mail) async {
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
    // Check if the user exist
    var isExist = await collection.findOne(where.eq('email', user.email));
    if (isExist == null) {
      // insert a new User
      await collection.save(user.toJson());
    }
  }

  updateUser(User user) async {
    var collection = db.collection('Users');
    // Check if the user exist
    await collection.updateOne(
        where.eq('email', user.email), modify.set('yeshiva', user.yeshiva));
    await collection.updateOne(where.eq('email', user.email),
        modify.set('description', user.description));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('status', user.status));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('avatar', user.avatar));
  }

  changeDeatailsUser(User user) async {
    var collection = db.collection('Users');
    // Check if the user exist
    await collection.updateOne(
        where.eq('email', user.email), modify.set('name', user.name));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('address', user.address));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('status', user.status));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('yeshiva', user.yeshiva));
    await collection.updateOne(where.eq('email', user.email),
        modify.set('description', user.description));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('status', user.status));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('avatar', user.avatar));
    await collection.updateOne(
        where.eq('email', user.email), modify.set('birthDate', user.birthDate));
  }

  changePasswordUser(String email, String newPassword) async {
    var collection = db.collection('Users');
    // Check if the user exist
    var bytes = utf8.encode(newPassword);
    var digest = sha1.convert(bytes);
    await collection.updateOne(
        where.eq('email', email), modify.set('password', digest.toString()));
    return newPassword;
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
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

  Future<Event> getEventById(ObjectId? id) async {
    var collection = db.collection('Events');
    DateTime timeNow = DateTime.now();
    var event = await collection.findOne(where.eq("_id", id));
    var e = Event.fromJson(event);
    var len = e.dates!.length;
    for (int j = 0; j < len; j++) {
      if (timeNow.isAfter(e.dates![j])) {
        e.dates!.remove(e.dates![j]);
        len -= 1;
        j--;
      }
    }
    return e;
  }

  getEvent(String _id) async {
    var collection = db.collection('Events');
    var event = await collection.find(keyLimit: 10);
    return event;
  }

  // Save the id of the current user locally in the user phone.
  // for next session - automatic connect
  saveIdLocally() async {
    var coll = Globals.db!.db.collection('Users');
    // Find user document via email
    var user_json =
        await coll.findOne(where.eq('email', Globals.currentUser!.email));
    // This is ObjectID
    var id = user_json['_id'];
    final SharedPreferences prefs = await Globals.prefs;
    // Save to device
    await prefs.setString('id', id.toString());
  }

  // Get message and insert it to the DB
  Future<bool> sendMessage(ChatMessage message) async {
    var collection = Globals.db!.db.collection('Chats');
    var m = message.toJson();
    await collection.insertOne(m);
    return true;
  }

  Future<List<ChatMessage>> getAllMyMessages(String? dstMail) async {
    List<ChatMessage> listMessages = [];
    var collection = Globals.db!.db.collection('Chats');
    var messages =
        await collection.find(where.eq('dst_mail', dstMail)).toList();
    for (var i in messages) {
      listMessages.add(new ChatMessage.fromJson(i));
    }
    return listMessages;
  }

  deleteEvent(ObjectId? id) async {
    var collection = Globals.db!.db.collection('Events');
    WriteResult result = await collection.deleteOne(where.eq('_id', id));
    if (result.hasWriteErrors) {
      return false;
    }
    return true;
  }

  void disconnect() async {
    await db.close();
  }
}
