import 'dart:async';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mongo_dart/mongo_dart.dart';

/// class to get chats(lessons) data as stream-like object
class ChatModel {
  late Stream<List<ChatMessage>> stream;
  bool _isLoading = false;
  List<ChatMessage> _data = [];
  late StreamController<List<ChatMessage>> _controller;
  String? otherPerson;
  String myMail;
  ChatModel({
    bool refreshNow = false,
    this.otherPerson,
    required this.myMail,
  }) {
    _controller = StreamController<List<ChatMessage>>.broadcast();
    stream = _controller.stream.map((List<ChatMessage> postsData) {
      var impList = postsData.where((m) => m.src_mail != myMail).toList();
      if (impList.isNotEmpty) Globals.lastMsgSeen = impList.last;
      return postsData;
    });
    if (refreshNow) {
      refresh();
    }
  }

  Future<List<ChatMessage>> _getExampleServerData() async {
    return Future.delayed(MyConsts.defaultDelay, () {
      return otherPerson == null
          ? Globals.db!
              .getAllMyLastMessageWithEachFriend(myMail, fetchDstUserData: true)
          : Globals.db!.getAllMyMessages(myMail, srcMail: otherPerson);
    });
  }

  // meant to avoid refresh without last msg,
  // but cause problem if refresh called from send()
  // which we wan't because we need the id that mongo db give us
  //ChatMessage? lastToBeSent;
  Future deleteAll() {
    if (otherPerson == null) throw Exception();
    _isLoading = true;
    List toDel = List.of(_data).map((e) => e.id).toList();
    return Globals.db!
        .deleteMsgs(
            toDel,
            ChatMessage(
                name: Globals.currentUser!.name,
                avatar: Globals.currentUser!.avatar,
                datetime: DateTime.now(),
                dst_mail: otherPerson,
                src_mail: myMail,
                message: "*__שיחה נמחקה__*"))
        .whenComplete(() {
      _data = [];
      _controller.add(_data);
      _wasFetched = true;
      _isLoading = false;
      refresh();
    });
  }

  Future deleteOne(types.Message msg) {
    if (otherPerson == null) throw Exception();
    _isLoading = true;
    //return Globals.db!.deleteMsgs([msg.id], null).whenComplete(() {
    return Globals.db!.editMsg(msg.id, "*__הודעה נמחקה__*").whenComplete(() {
      _data = _data.where((element) => element.id != msg.id).toList();
      _controller.add(_data);
      _wasFetched = true;
      _isLoading = false;
      refresh();
    });
  }

  Future send(ChatMessage msg) {
    if (otherPerson == null) throw Exception();
    _isLoading = true;
    //ChatMessage? prevLastToBeSent = lastToBeSent;
    //lastToBeSent = msg;
    return Globals.db!.sendMessage(msg).then((v) {
      if (v == false) {
        //lastToBeSent = prevLastToBeSent;
        return v;
      }
      // prefer to wait till we will get msg with id!=null from mongoDB
      //_data.add(msg);
      //_controller.add(_data); _wasFetched = true;
      return v;
    }).whenComplete(() {
      _isLoading = false;
      refresh();
    });
  }

  bool _wasFetched = false;
  // no fetch from server but data re-send to _controller
  void simulateRefresh() => _wasFetched ? _controller.add(_data) : null;
  Future<void> refresh() {
    return _loadMore(clearCachedData: true);
  }

  Future<void> _loadMore({bool clearCachedData = false}) {
    if (!clearCachedData) throw Exception();
    if (_isLoading) {
      return Future.value();
    }
    _isLoading = true;
    return _getExampleServerData().then((postsData) {
      /* meant to avoid refresh without last msg, but cause problem if refresh called from send()
      if (lastToBeSent != null) {
        Set<DateTime?> msgs = postsData.map((e) => e.datetime).toSet();
        msgs.addAll(_data.map((e) => e.datetime));
        if (!msgs.contains(lastToBeSent)) {
          return;
        }
      }*/
      if (clearCachedData) {
        _data = List.of(postsData);
      } else {
        _data.addAll(postsData);
      }
      _controller.add(_data);
      _wasFetched = true;
    }).whenComplete(() {
      _isLoading = false;
    });
  }
}
