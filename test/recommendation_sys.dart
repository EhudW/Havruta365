import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/recommendation_system/evaluation/eval_interface.dart';
import 'package:havruta_project/event/recommendation_system/example_rec_eval_usage.dart';
import 'package:havruta_project/event/recommendation_system/rec_interface.dart';
import 'package:havruta_project/event/recommendation_system/systems/random_sys.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'widget_test.dart';

const int K = 10;
const int USERS_AMOUNT = 100;
const int USERS_GROUPS = 4; // all users are going together, 4 'group'
const int FREQUENCY = 7; // for making dates in 'frequency' - a day a week
// test one time = eval & check that the recommendation include event that need to be there
Future<MapEntry<Map<ModelEvalutionMethod, double>, int>> _testOneTimeRecSys(
    {RecommendationSystem<Event> Function(int k)? useSysInstead}) async {
  List<String> emails = [];
  Map<String, List<Event>> userEventMap = {};
  List<Event> allEvents = [];
  var ourUser = 'aaa@mail.com';
  // generate fake users
  for (int i = 0; i < USERS_AMOUNT; i++) {
    emails.add("mail$i@mail.com");
  }
  for (int groupNumber = 0; groupNumber < USERS_GROUPS; groupNumber++) {
    // short unique string for events that people in that group go to
    String s = "option$groupNumber";
    // fake dates
    var past = () => DateTime.now().subtract(Duration(
        days: groupNumber,
        hours: groupNumber * 4)); // for variety - sub also 4 hrs
    var future = (int x) => DateTime.now().add(Duration(
        days: x,
        minutes:
            20)); // add 20 min so that  some of dates of the event will be in future
    // wont check is target for me
    var dates = () => [
          future(groupNumber).subtract(Duration(days: FREQUENCY)),
          future(groupNumber),
          future(groupNumber + FREQUENCY)
        ];
    // decide which group go to part
    var emailsGroup =
        (int part) => emails.sublist(25 * (part % 4), 25 * ((part % 4) + 1));
    // our user is register
    const int durationSteps = 30;
    const int ageSteps = 20;
    const int maxParticipantsStep = 7;
    Event e = Event(
      book: 'book$s',
      creationDate: past(),
      dates: dates(),
      creatorName: 'name$s',
      creatorUser: '$s@mail.com',
      description: 'dscrp$s',
      eventImage: 'img$s',
      duration: durationSteps * (1 + groupNumber),
      lecturer: 'lect$s',
      link: 'link$s',
      location: 'location$s',
      maxAge: ageSteps * (groupNumber + 1),
      // enough place for ourUser, group, and keep variety
      maxParticipants: (USERS_AMOUNT / USERS_GROUPS).ceil() +
          1 +
          maxParticipantsStep * groupNumber,
      minAge: ageSteps * groupNumber,
      onlyForStatus: Event.onlyForStatus_Options[groupNumber].first, // no limit
      participants: emailsGroup(groupNumber + 0),
      waitingQueue: emailsGroup(groupNumber + 1),
      rejectedQueue: emailsGroup(groupNumber + 2),
      leftQueue: emailsGroup(groupNumber + 3),
      targetGender: ['גברים', 'נשים'][groupNumber % 2],
      topic: 'topic$s',
      type: ['H', 'L'][groupNumber % 2],
    );
    var json = e.toJson();
    var problems = ["dates", "creationDate"]; // error when trying to jsonEncode
    Map<String, dynamic> tmp =
        Map.fromIterable(problems, value: (e) => json.remove(e));
    String jsonStr = jsonEncode(json);
    // we want number event = number of user
    // so USERS_AMOUNT ~/ USERS_GROUPS x USER_GROUP = USERS_AMOUNT = EVENTS_AMOUNT
    for (int i = 0; i < USERS_AMOUNT ~/ USERS_GROUPS; i++) {
      Map<String, dynamic> currJson = jsonDecode(jsonStr);
      currJson.addAll(tmp);
      var event = Event.fromJson(currJson);
      event.creationDate = past();
      event.dates = dates();
      event.id = ObjectId();
      allEvents.add(event);
      // we track on ourUser
      // he will join groups 0,1 for the half of the events
      if (i.isEven || groupNumber > 1) {
        event.moveToQueueLocal(
          ourUser,
          null,
        ); // omit result from half events, so it's 'unknown'
      } else {
        // join him to one of the following participants / waiting list
        event.moveToQueueLocal(ourUser,
            [EventQueues.Participants, EventQueues.Waiting][groupNumber]);
        userEventMap[ourUser] = userEventMap[ourUser] ?? [];
        userEventMap[ourUser]!.add(event);
      }
    }
  }
  emails.forEach((email) => userEventMap[email] = List.of(allEvents));
  // no need to make user according to ourUser, beacuse the test is over all emails, not only currentUser,
  // Globals.currentUser = User()  xxx
  // Indeed, that mean that every test, don't take in acount isTargetForMe(),
  // it can be done, but not for now.
  List out = []; // will be out param of Map email->rec Events
  // await here before we can use out param
  var rslt = await ExampleRecommendationSystem.test(
      k: K,
      printOutput: false,
      useMeInstead: useSysInstead,
      put100IfYouSure: 100,
      fakeUsersMails: emails + [ourUser],
      fakeAllEvents: allEvents,
      fakeMyEvents: userEventMap,
      outParamRec: out);
  // book str is not unique, but we know that we assign ourUser to Participant in the first group=0
  // so allEvent[0] is in the first event group with the first users group
  int ourUserSuccess = out[0][ourUser]
      .map((e) => e.book)
      .where((book) => book == allEvents[0].book)
      .length;
  return MapEntry<Map<ModelEvalutionMethod, double>, int>(
      rslt ?? {}, ourUserSuccess);
}

var formattedMapStr = (m) => Map.of(m.map((key, value) => MapEntry(
    key.toString().split('.').last,
    value is double
        ? value.toStringAsFixed(3)
        : value.map((x) => x.toStringAsFixed(3)).toList()))).toString();

// Verify many times the the small test succeed (not only on random run)
void testRecSys(
    {int timesToCheck = 10,
    RecommendationSystem<Event> Function(int k)? testThisSystem}) {
  var realRecSysRslt;
  String sysName = testThisSystem == null
      ? "default"
      : testThisSystem(K).runtimeType.toString();
  group('Test rec system [$sysName]', () {
    test('p@k & quality hits, $timesToCheck times', () async {
      var rslt = await Future.wait(List.generate(timesToCheck,
          (index) => _testOneTimeRecSys(useSysInstead: testThisSystem)));
      realRecSysRslt = rslt;
      var avg = {};
      var ourUserTotalSuccess = 0;
      rslt.forEach((element) {
        element.key.forEach(
            (key, value) => avg[key] = (avg[key] ?? 0) + value / rslt.length);
        ourUserTotalSuccess += element.value;
      });
      var ranges =
          "ranges for k=$K:\n${formattedMapStr(ModelEvalution.calcRange(K))}";
      const double minPk = 0.1;
      int minOurUserSuccessPerK =
          min(max(K ~/ 5, 2), (0.2 * USERS_AMOUNT / USERS_GROUPS).round());
      alert(avg[ModelEvalutionMethod.PrecisionK], greaterThanOrEqualTo(minPk),
          reason: "with good train set, avg pk should be >= $minPk,\navg:\n" +
              "${formattedMapStr(avg)}\n$ranges");
      alert(ourUserTotalSuccess / rslt.length,
          greaterThanOrEqualTo(minOurUserSuccessPerK),
          reason: 'with good train set, avg rec need to include in each k=$K events,\n' +
              'at least $minOurUserSuccessPerK similar events to ourUser\'s events. avg of ($minOurUserSuccessPerK/$K) quality event hits,\n' +
              'but found  avg ${(ourUserTotalSuccess / rslt.length).toStringAsFixed(2)}/$K  ' +
              '=>repeat ${rslt.length} times=> total $ourUserTotalSuccess/${K * rslt.length}');
    });

    test('VS random rec system', () async {
      var rndSysRslt = await Future.wait(List.generate(timesToCheck,
          (index) => _testOneTimeRecSys(useSysInstead: (k) => ByRandom())));
      while (realRecSysRslt == null)
        await Future.delayed(Duration(milliseconds: 300));
      var realSysAvg = {};
      var ourUserSuccessRealSys = 0;
      Map rndSysAvg = {};
      int ourUserSuccessRndSys = 0;
      for (int i = 0; i < realRecSysRslt.length; i++) {
        var evalRealSys = realRecSysRslt[i].key;
        var evalRndSys = rndSysRslt[i].key;
        var successRealSys = realRecSysRslt[i].value as int;
        var successRndSys = rndSysRslt[i].value;
        for (var j in evalRealSys.keys) {
          var positiveOrZero = (x) => (x as double).isFinite && x >= 0;
          if (positiveOrZero(evalRealSys[j]) == false ||
              positiveOrZero(evalRndSys[j]) == false) continue;
          realSysAvg[j] =
              (realSysAvg[j] ?? 0) + evalRealSys[j]! / realRecSysRslt.length;
          rndSysAvg[j] =
              (rndSysAvg[j] ?? 0) + evalRndSys[j]! / rndSysRslt.length;
        }
        ourUserSuccessRealSys += successRealSys;
        ourUserSuccessRndSys += successRndSys;
      }

      var ranges =
          "ranges for k=$K:\n${formattedMapStr(ModelEvalution.calcRange(K))}";
      // warning only when all is bad, since random might give the good events (=hits, by id),
      // but we duplicate the event with diff ids, so the id isn't important it this test
      var allValues =
          realSysAvg.keys.map((e) => realSysAvg[e] - rndSysAvg[e]).toList() +
              [ourUserSuccessRealSys - ourUserSuccessRndSys];
      alert(allValues, anyElement(greaterThanOrEqualTo(0)),
          reason: "the model is worse than random model:\n" +
              " [pk is ok since the fake data is good for random model,\n" +
              "  but the hits of quality event should be greater]\n" +
              "current model:\n${formattedMapStr(realSysAvg)}\n" +
              "$ourUserSuccessRealSys / ${K * realRecSysRslt.length} hits of quality event\n" +
              "random model:\n${formattedMapStr(rndSysAvg)}\n" +
              "$ourUserSuccessRndSys / ${K * rndSysRslt.length} hits of quality event" +
              "\n$ranges");
    });
  });
}
