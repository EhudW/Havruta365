import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:havruta_project/data_base/data_representations/event.dart';
import 'package:havruta_project/event/recommendation_system/evaluation/eval_interface.dart';
import 'package:havruta_project/event/recommendation_system/example_rec_eval_usage.dart';
import 'package:havruta_project/event/recommendation_system/rec_interface.dart';
import 'package:havruta_project/event/recommendation_system/systems/random_sys.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'functions.dart';

// all functions here are only warn and not expect, since it's not "error" if the rec sys is 'bad'
// some runs might make some different results of warning, beacuse there is use of random(),shuffle()...

void main() {
// test default rec system at ExampleRecommendationSystem class
  testRecSys(skipCollaborativeCheck: false);
  /* 
  // test specif rec system,
  // in this case test the testRecSys since we give OppositeRecommendationSystem()
  testRecSys(
      timesToCheck: 1,
      testThisSystem: (k) =>
          OppositeRecommendationSystem(MultiConsiderations()));
  */
}

// here, and in the lib/../recommendation_system folder
// for now Queues  none=nuetral,  rejected\left=bad,  waiting\participants=good
// so that it how the recommendation done,  if we add 'star' rank feature from 1(bad) to 5(good)
// then here, in the test below, we should also add that persons rank according to their
// rejected = 1  left = 2  none=null     waiting = 4  participant = 5
// in the general case, it is up to you to decide if rejected it worse than -1?
// maybe rejecte/now  doesn't matter to the USER star-rate decesion,(even after normailzation)
// anyway, here in the test there should be connection between good rank = participant = 5 starts,
// and vice versa, so the logic of the test['good' vs 'bad' event] will work.
//
// anyway the code below might need to be changed if recommend system will need more than
// possibleEvents to rank, and myEvents to INIT the rank map,
// (INIT is to decide the rank: Event->double   that later will rank(someevent) )
// if allEvents will be needed to THE INIT RANK MAP, (like collaborative rank),
// consider make it in different var than possibleEvents, since we assume the rec system will try
// to rank it, and then filter events I already joined, so to avoid the filter we manipulate it,
// but we couldn't have done it to data needed to INIT the rank map, like myEvents var
const int K = 10;
// should be USERS_AMOUN ~/ USERS_GROUP >= 2 * K
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
      onlyForStatus: Event.onlyForStatus_Options[groupNumber].first,
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
// check few test if succeed to pass pk, vs random , etc...
void testRecSys({
  int timesToCheck = 10,
  RecommendationSystem<Event> Function(int k)? testThisSystem,
  bool skipPkAndQualityCheck = false,
  bool skipVsRandomCheck = false,
  bool skipPopularBasedCheck = false,
  bool skipCustomBasedCheck = false,
  bool skipCollaborativeCheck = false,
}) {
  List<MapEntry<Map<ModelEvalutionMethod, double>, int>>? realRecSysRslt;
  String sysName = testThisSystem == null
      ? "default"
      : testThisSystem(K).runtimeType.toString();
  group('Test rec system [$sysName]', () {
    if (skipPkAndQualityCheck == false || skipVsRandomCheck == false) {
      // !!! needed for p@k AND vs rnd checks
      Future.wait(List.generate(timesToCheck,
              (index) => _testOneTimeRecSys(useSysInstead: testThisSystem)))
          .then((value) => realRecSysRslt = value);
    }
    if (skipPkAndQualityCheck == false)
      test('p@k & quality hits, $timesToCheck times', () async {
        while (realRecSysRslt == null)
          await Future.delayed(Duration(milliseconds: 300));
        var rslt = realRecSysRslt!;
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

    if (skipVsRandomCheck == false)
      test('VS random rec system', () async {
        var rndSysRslt = await Future.wait(List.generate(timesToCheck,
            (index) => _testOneTimeRecSys(useSysInstead: (k) => ByRandom())));
        while (realRecSysRslt == null)
          await Future.delayed(Duration(milliseconds: 300));
        var realSysAvg = {};
        var ourUserSuccessRealSys = 0;
        Map rndSysAvg = {};
        int ourUserSuccessRndSys = 0;
        for (int i = 0; i < realRecSysRslt!.length; i++) {
          var evalRealSys = realRecSysRslt![i].key;
          var evalRndSys = rndSysRslt[i].key;
          var successRealSys = realRecSysRslt![i].value;
          var successRndSys = rndSysRslt[i].value;
          for (var j in evalRealSys.keys) {
            var positiveOrZero = (x) => (x as double).isFinite && x >= 0;
            if (positiveOrZero(evalRealSys[j]) == false ||
                positiveOrZero(evalRndSys[j]) == false) continue;
            realSysAvg[j] =
                (realSysAvg[j] ?? 0) + evalRealSys[j]! / realRecSysRslt!.length;
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
                "$ourUserSuccessRealSys / ${K * realRecSysRslt!.length} hits of quality event\n" +
                "random model:\n${formattedMapStr(rndSysAvg)}\n" +
                "$ourUserSuccessRndSys / ${K * rndSysRslt.length} hits of quality event" +
                "\n$ranges");
      });
    // create semi-uniqeu event accroding to i, with empty queues, no id
    var createEvent = (int i) => Event(
          book: 'book$i',
          creationDate: DateTime.now().subtract(Duration(days: 1 + i)),
          dates: [DateTime.now().add(Duration(days: 1 + i))],
          creatorName: 'name$i',
          creatorUser: '$i@mail.com',
          description: 'dscrp$i',
          eventImage: 'img$i',
          duration: 30 + 30 * i,
          lecturer: 'lect$i',
          link: 'link$i',
          location: 'location$i',
          maxAge: 40 + 10 * i,
          minAge: 10 + 5 * i,
          // enough place, group, and keep variety
          maxParticipants: 10 * i + 1 + (USERS_AMOUNT / USERS_GROUPS).ceil(),
          onlyForStatus: Event.onlyForStatus_Options[i].first,
          participants: [],
          waitingQueue: [],
          rejectedQueue: [],
          leftQueue: [],
          targetGender: ['גברים', 'נשים'][i % 2],
          topic: 'topic$i',
          type: ['H', 'L'][i % 2],
        );

    // get few events, anf few users, and test, with amplification, the recommendation results
    // not adding the userToTest, but remove, so there will be possible to rec it.
    // not affect the original key in amplify param
    Future<List<Event>> getAmplificationResults(
        Map<Event, int> amplify, String userToTest) async {
      List<Event> allEvents = [];
      List<Event> myEvents = [];
      // each event should be amplify
      for (var event_int in amplify.entries) {
        var event = event_int.key;
        var amount = event_int.value;
        // add to my events if I in one of the queues
        for (var q in EventQueues.values) {
          if (event.of(q).contains(userToTest)) {
            myEvents += List.generate(
                amount, (_) => event.deepClone()..id = ObjectId());
            break;
          }
        }
        // to all possible events, add as I not there, so It will count as new event for me,
        // so the system will be able to recommend it for me, and won't filter it
        var eventWithoutMe = event.deepClone()
          ..moveToQueueLocal(userToTest, null);
        // update total data with amplify
        allEvents += List.generate(
            amount, (_) => eventWithoutMe.deepClone()..id = ObjectId());
      }
      allEvents.shuffle();
      if (testThisSystem != null) {
        var sys = testThisSystem(K);
        sys.setData({
          "compareToMe": Future.value(myEvents),
          "possibleEvents": Future.value(allEvents),
          "myMail": userToTest,
          "clearCacheAfter": true,
          "saveLastRank": false,
        });
        await sys.calc(K);
        return sys.getTop(K);
      }
      var sys = ExampleRecommendationSystem.create(userToTest,
          k: K, fakeAllEvents: allEvents, fakeMyEvents: myEvents);
      return (await ExampleRecommendationSystem.calcAndGetTopEventsFrom(sys))!;
    }

    if (skipCustomBasedCheck == false || skipPopularBasedCheck == false)
      test("recommend for user-custom/general-cold-start based rank", () async {
        // 2 events
        var goodEvent = createEvent(0)..book = 'good event';
        // make them as similar as possible
        var badEvent = goodEvent.deepClone()..book = 'bad event';
        // with users / without users
        goodEvent.participants = List.generate(
            USERS_AMOUNT ~/ USERS_GROUPS, (index) => '$index@fakemail.com');
        badEvent.leftQueue = List.of(goodEvent.participants!); //same people
        int major = USERS_AMOUNT * K;
        int minor = USERS_AMOUNT ~/ USERS_GROUPS;
        // good event should be returned to cold start, even if the majority is 'bad'
        String coldStartMail = 'cold@start.user';
        var rslt = await getAmplificationResults(
            {goodEvent: minor, badEvent: major}, coldStartMail);
        int goodEventInColdStart =
            rslt.where((e) => e.book == goodEvent.book).length;
        // bad event should returned to person who love this type, even if all others people don't,
        // even if the majority is 'good'
        String specificUser = 'let@me.choose.my.own.events';
        badEvent.acceptLocal(specificUser);
        rslt = await getAmplificationResults(
            {goodEvent: major, badEvent: minor}, specificUser);
        int basedOnUserRec = rslt.where((e) => e.book == badEvent.book).length;
        if (skipPopularBasedCheck == false)
          alert(goodEventInColdStart, greaterThanOrEqualTo(2),
              reason:
                  "should recommend also high 'self'/'good'/'popular' ranked events,\n" +
                      "even if it is the minorty, at least twice out of $K");
        if (skipCustomBasedCheck == false)
          alert(basedOnUserRec, greaterThanOrEqualTo(2),
              reason: 'should recommend also high \'custom-user-based\' ranked events,\n' +
                  'even if it is the minorty,\n' +
                  'and even if it is low \'self\' rank, at least twice out of $K');
      });

    if (skipCollaborativeCheck == false)
      test("recommend for collaborative based rank", () async {
        // 2 events with same people group
        var eventA = createEvent(0);
        var eventB = createEvent(2);
        int minor = USERS_AMOUNT ~/ USERS_GROUPS;
        eventA.participants =
            List.generate(minor, (index) => '$index@fakemail.com');
        eventB.participants = List.of(eventA.participants!);
        String specificUser = 'me@me.me';
        eventA.participants!.add(specificUser);
        // good event = with lots of people & lots of amplification
        var eventC = createEvent(1);
        eventC.participants =
            List.generate(minor, (index) => '$index@another.111.fakemail.com');
        eventC.waitingQueue =
            List.generate(minor, (index) => '$index@another.222.fakemail.com');
        int major = USERS_AMOUNT * K;
        // eventB that is similar* to my events(eventA)\friends(in eventA)
        // should be returned, even if the majority is eventC with 'good' rank by itself
        // * similar not by its data, which is custom to me based rec, tested above
        //           but similar means similar user like me (that has similar events)
        //            or similar events like my events (events that has similar participants)
        var rslt = await getAmplificationResults(
            {eventA: minor, eventB: minor, eventC: major}, specificUser);
        int eventBInRec = rslt.where((e) => e.book == eventB.book).length;
        alert(eventBInRec, greaterThanOrEqualTo(2),
            reason: 'should recommend also collaborative based events,\n' +
                'even if it is the minorty, at least twice out of $K');
      });
  });
}
