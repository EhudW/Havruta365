// ignore_for_file: non_constant_identifier_names

import 'dart:core';
import 'dart:convert';
//import 'dart:js_util';
import 'package:havruta_project/DataBase_auth/Notification.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../mydebug.dart' as MyDebug;
import './mongo2.dart' as Db2;
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
  // useDb2 to try auto reconnect when connection lost, see mongo2.dart
  Future<void> connect({bool useDb2 = false}) async {
    if (useDb2) {
      this.db = await Db2.MongoDbImpl.create(CONNECT_TO_DB);
    } else {
      this.db = await Db.create(CONNECT_TO_DB);
    }
    await this.db.open();
    MyDebug.myPrint('Connected to database', MyDebug.MyPrintType.None);
    Globals.isDbConnect = true;
  }

  Future<void> insertEvent(Event event) async {
    /* MondoDB decrease to hour from the time, because he using UTC. here we fix it.
    for (DateTime date in event.dates as Iterable<DateTime>) {
      // TODO: check if to utc function prefered
      date.add(Duration(hours: 2));
    }*/
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

  Future<void> addToWaitingQueue(String? mail, ObjectId? id) async {
    var collection = Globals.db!.db.collection('Events');
    // Get event by id and Add mail to waitingQueue array
    // ignore: unused_local_variable
    var res = await collection.updateOne(
        where.eq('_id', id), ModifierBuilder().push('waitingQueue', mail));
  }

  Future<void> insertNotification(NotificationUser notification) async {
    var collection = db.collection('Notifications');
    var e = notification.toJson();
    await collection.insertOne(e);
    var url = Uri.parse('http://yonatangat.pythonanywhere.com/mail');
    var x = {
      "subject": "פרוייקט חברותא+",
      "body": notification.name! + "  " + notification.message!,
      "src": "havrutaproject@gmail.com",
      "src_pass": "havruta365",
      "dst": notification.destinationUser
    };
    // ignore: unused_local_variable
    /*var response = await http.post(url,
        body: json.encode(x), headers: {'Content-Type': 'application/json'});*/
  }

  Future<void> deleteNotification(NotificationUser notification) async {
    var collection = db.collection('Notifications');
    await collection.deleteOne({"_id": notification.id});
    MyDebug.myPrint(
        "${notification.message}  DELETED", MyDebug.MyPrintType.Nnim);
  }

  Future<void> deleteAllNotifications(List<NotificationUser> noti) async {
    List ids = List.of(noti).map((e) => e.id).where((e) => e != null).toList();
    if (ids.isEmpty) return;
    var collection = db.collection('Notifications');
    await collection.deleteMany(where.oneFrom("_id", ids));
    MyDebug.myPrint(
        "${ids.length} notifications  DELETED", MyDebug.MyPrintType.Nnim);
  }

  deleteFromEvent(ObjectId? id, String? email) async {
    var collection = Globals.db!.db.collection('Events');
    // Get event by id and Add mail to participants array
    // ignore: unused_local_variable
    var res = await collection.updateOne(
        where.eq('_id', id), ModifierBuilder().pull('participants', email));
  }

  deleteFromEventWaitingQueue(ObjectId? id, String? email) async {
    var collection = Globals.db!.db.collection('Events');
    // ignore: unused_local_variable
    var res = await collection.updateOne(
        where.eq('_id', id), ModifierBuilder().pull('waitingQueue', email));
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

  updateEvent(Event event) async {
    // error if event.id == null or cant find the event in the db
    var collection = db.collection('Events');
    await collection.replaceOne(where.eq("_id", event.id), event.toJson());
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

  Future<Event?> getEventById(ObjectId? id) async {
    var collection = db.collection('Events');
    DateTime timeNow = DateTime.now();
    var event = await collection.findOne(where.eq("_id", id));
    if (event == null) {
      return null;
    }
    var e = Event.fromJson(event);
    var len = e.dates!.length;
    for (int j = 0; j < len; j++) {
      if (timeNow
          .subtract(Duration(minutes: e.duration ?? 0))
          .isAfter(e.dates![j])) {
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

  Future __fetchDstUserData(List<ChatMessage> rslt, String myMail) async {
    Map<String, User> cache = {};
    for (int i = 0; i < rslt.length; i++) {
      ChatMessage curr = rslt[i];
      if (curr.src_mail != myMail || curr.src_mail == curr.dst_mail) {
        curr.otherPersonName = curr.name!;
        curr.otherPersonAvatar = curr.avatar!;
        continue;
      }
      String currDstMail = curr.dst_mail!;
      cache[currDstMail] = cache[currDstMail] ?? await getUser(currDstMail);
      User u = cache[currDstMail]!;
      curr.otherPersonAvatar = u.avatar!;
      curr.otherPersonName = u.name!;
    }
  }

  Future<List<ChatMessage>> getAllMyMessages(String dstMail,
      {String? srcMail,
      bool biDirectional = true,
      bool fetchDstUserData = false}) async {
    List<ChatMessage> listMessages = [];
    var collection = Globals.db!.db.collection('Chats');
    var selector = where.eq('dst_mail', dstMail);
    if (dstMail == srcMail) {
      selector = selector.eq('src_mail', srcMail);
    } else {
      selector =
          biDirectional ? selector.or(where.eq("src_mail", dstMail)) : selector;
      if (srcMail != null) {
        var extra = where.eq("src_mail", srcMail);
        extra = biDirectional ? extra.or(where.eq("dst_mail", srcMail)) : extra;
        selector = selector.and(extra);
      }
    }

    var messages = await collection.find(selector).toList();
    for (var i in messages) {
      listMessages.add(new ChatMessage.fromJson(i));
    }
    listMessages.sort((a, b) => a.datetime!.compareTo(b.datetime!));
    !fetchDstUserData ? null : await __fetchDstUserData(listMessages, dstMail);
    return listMessages;
  }

  Future<List<ChatMessage>> getAllMyLastMessageWithEachFriend(String dstMail,
      {bool biDirectional = true, bool fetchDstUserData = false}) async {
    List<ChatMessage> listMessages = await getAllMyMessages(dstMail,
        biDirectional: biDirectional, fetchDstUserData: false);
    List<ChatMessage> rslt = [];
    Set<String> withFriend = {};
    var sameRepr = (a, b) {
      var x = [a, b];
      x.sort();
      return x.toString();
    };
    listMessages.reversed.forEach((element) {
      var r = sameRepr(element.src_mail!, element.dst_mail!);
      if (!withFriend.contains(r)) {
        rslt.add(element);
        withFriend.add(r);
      }
    });
    !fetchDstUserData ? null : await __fetchDstUserData(rslt, dstMail);
    return rslt;
  }

  deleteEvent(ObjectId? id) async {
    var collection = Globals.db!.db.collection('Events');
    WriteResult result = await collection.deleteOne(where.eq('_id', id));
    if (result.hasWriteErrors) {
      return false;
    }
    return true;
  }

  Future<dynamic> __getLastMsgSentForMe() async {
    var collection = Globals.db!.db.collection('Chats');
    var result = await (collection as DbCollection).findOne(where
        .eq("dst_mail", Globals.currentUser!.email)
        .and(where.ne("src_mail", Globals.currentUser!.email))
        //.eq("src_mail", Globals.currentUser!.email)
        //.or(where.eq("dst_mail", Globals.currentUser!.email))
        .sortBy("_id", descending: true));
    return result;
  }

  Future<bool> hasNewMsg(ChatMessage? last) async {
    var newest = await __getLastMsgSentForMe();
    if (newest == null) return false;
    if (last == null) return true;
    // instead of using id which might be wrong if the last was deleted and the newest is very old
    return ChatMessage.fromJson(newest).datetime!.isAfter(last.datetime!);
    //return newest?['_id'] != last?.id;
  }

  Future deleteMsgs(List msgs, ChatMessage? insertAlert) async {
    if (msgs.isEmpty) return;
    msgs =
        msgs.map((e) => e is ObjectId ? e : ObjectId.fromHexString(e)).toList();
    var collection = Globals.db!.db.collection('Chats');
    WriteResult result = msgs.length == 1
        ? await collection.deleteOne(where.eq('_id', msgs[0]))
        : await collection.deleteMany(where.oneFrom('_id', msgs));
    if (result.hasWriteErrors) {
      return false;
    }
    if (insertAlert != null) {
      await sendMessage(insertAlert);
    }
    return true;
  }

  void disconnect() async {
    await db.close();
  }
}
