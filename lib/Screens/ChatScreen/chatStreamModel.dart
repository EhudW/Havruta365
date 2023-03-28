import 'dart:async';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/ChatMessage.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mongo_dart/mongo_dart.dart';

/// class to get chats(lessons) data as stream-like object
class ChatModel {
  late Stream<List<MapEntry<ChatMessage, int>>> stream;
  late Stream<List<ChatMessage>> streamAsEntryKey;

  Set<String> _shouldNotSendSeen = {};
  bool _isLoading = false;
  List<MapEntry<ChatMessage, int>> _data = [];
  late StreamController<List<MapEntry<ChatMessage, int>>> _controller;
  String? otherPerson;
  String myMail;
  bool isForum;
  ChatModel({
    bool refreshNow = false,
    this.otherPerson,
    required this.myMail,
    bool forum = false,
  }) : isForum = forum {
    _controller =
        StreamController<List<MapEntry<ChatMessage, int>>>.broadcast();
    stream =
        _controller.stream.map((List<MapEntry<ChatMessage, int>> postsData) {
      return postsData;
    });
    streamAsEntryKey = stream.map((List<MapEntry<ChatMessage, int>> postsData) {
      return postsData.map((e) => e.key).toList();
    });
    if (refreshNow) {
      refresh();
    }
  }
  void msgWasSeen(types.TextMessage msg) {
    if (otherPerson == null) throw Exception();
    if (isForum) return;
    if (_shouldNotSendSeen.contains(msg.id)) return;
    _shouldNotSendSeen.add(msg.id);
    ChatMessage m = ChatMessage.fromTypesTextMsg(msg);
    if (m.dst_mail != myMail || m.status == types.Status.seen) return;
    Globals.db!.setMsgsStatus([m.id], 2);
  }

  Future<List<MapEntry<ChatMessage, int>>> _getExampleServerData() async {
    return Future.delayed(MyConsts.defaultDelay, () async {
      return otherPerson == null
          ? (await Globals.db!.getAllMyLastMessageWithEachFriend(myMail,
              fetchDstUserData: true))
          : (isForum
                  ? (await Globals.db!
                      .getAllMyMessages(otherPerson!, isForum: true))
                  : (await Globals.db!.getAllMyMessages(myMail,
                      srcMail: otherPerson, isForum: false)))
              .map((e) => MapEntry(e, -1))
              .toList();
    });
  }

  // meant to avoid refresh without last msg,
  // but cause problem if refresh called from send()
  // which we wan't because we need the id that mongo db give us
  //ChatMessage? lastToBeSent;
  Future deleteAll() {
    if (otherPerson == null || isForum) throw Exception();
    _isLoading = true;
    List toDel = List.of(_data).map((e) => e.key.id).toList();
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
      //lastToBeSent = null;
      _data = [];
      _wasFetched = true;
      simulateRefresh();
      _isLoading = false;
      refresh();
    });
  }

  Future deleteOne(types.Message msg) {
    if (otherPerson == null) throw Exception();
    _isLoading = true;
    String delmsg = "*__הודעה נמחקה__*";
    var tmp = _data.firstWhere(
      (e) => e.key.toTypesTextMsg().id == msg.id,
      orElse: () => MapEntry(ChatMessage(), -1),
    );
    if (tmp.key.id == null) return Future.value();
    tmp.key.status = ChatMessage.statuses[0];
    tmp.key.tagNow();
    tmp.key.message = delmsg;
    simulateRefresh(tmp);
    //return Globals.db!.deleteMsgs([msg.id], null).whenComplete(() {
    return Globals.db!.editMsg(msg.id, delmsg).then((success) {
      tmp.key.status = success ? types.Status.sent : types.Status.error;
      tmp.key.tagNow();
      simulateRefresh(tmp);
      _wasFetched = true;
      _isLoading = false;
    });
  }

  Future send(ChatMessage msg) {
    if (otherPerson == null) throw Exception();
    msg.status = types.Status.sending;
    _isLoading = true;
    //ChatMessage? prevLastToBeSent = lastToBeSent;
    //lastToBeSent = msg;
    var msgEntry = MapEntry(msg, -1);
    _data.add(msgEntry);
    simulateRefresh();
    return Globals.db!.sendMessage(msg).then((success) {
      msgEntry.key.status = success ? types.Status.sent : types.Status.error;
      msgEntry.key.tagNow();
      simulateRefresh(msgEntry);
      // if (success == false) {
      //  lastToBeSent = prevLastToBeSent;
      // }
      _wasFetched = true;
      return success;
    }).whenComplete(() {
      _isLoading = false;
      refresh();
    });
  }

  bool _wasFetched = false;
  // no fetch from server but data re-send to _controller
  void simulateRefresh([MapEntry<ChatMessage, int>? editMsg]) {
    if (!_wasFetched) {
      return;
    }
    if (editMsg != null) {
      _data = _data
          .map((e) =>
              editMsg == e || (e.key.id != null && e.key.id == editMsg.key.id)
                  ? editMsg
                  : e)
          .toList();
    }
    _controller.add(_data);
  }

  Future<void> refresh([Future<List<MapEntry<ChatMessage, int>>>? preCompute]) {
    if (_isLoading) {
      return Future.value();
    }
    _isLoading = true;
    preCompute = preCompute ?? _getExampleServerData();
    return preCompute.then((postsData) {
      // meant to avoid refresh without last msg, but cause problem if refresh called from send()
      /*if (lastToBeSent != null) {
        Set<DateTime?> msgs = postsData.map((e) => e.datetime).toSet();
        msgs.addAll(_data.map((e) => e.datetime));
        if (!msgs.contains(lastToBeSent)) {
          return;
        }
      }
      if (clearCachedData) {
        _data = List.of(postsData);
      } else {
        _data.addAll(postsData);
      }
      */
      if (otherPerson != null) {
        var data = List.of(_data);
        Map<dynamic, MapEntry<ChatMessage, int>> m1 = Map.fromIterable(
          postsData,
          key: (element) => element.key.id,
        );
        Map<dynamic, MapEntry<ChatMessage, int>> m2 = Map.fromIterable(
          data,
          key: (element) => element.key.id,
        );
        Set totalIds = m1.keys.toSet().union(m2.keys.toSet());
        List<DateTime> times = [];
        totalIds.remove(null);
        List<MapEntry<ChatMessage, int>> combined = [];
        for (var id in totalIds) {
          var m1x = m1[id];
          var m2x = m2[id];
          var last = (m1x?.key.tag ?? 0) > (m2x?.key.tag ?? 0) ? m1x : m2x;
          combined.add(last!);
          times.add(last.key.datetime!);
        }
        var func = (e) {
          if (e.key.id == null &&
              !times.any((y) => ((y.millisecondsSinceEpoch -
                          (e.key.datetime.millisecondsSinceEpoch))
                      .abs() <
                  500))) {
            combined.add(e);
          }
        };
        data.forEach(func);
        postsData.forEach(func);
        combined.sort(((a, b) => a.key.datetime!.compareTo(b.key.datetime!)));
        //[a b C]
        //  [b C d]
        _data = combined;
      } else {
        _data = postsData;
      }
      _wasFetched = true;
      simulateRefresh();
    }).whenComplete(() {
      _isLoading = false;
    });
  }
}
