import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/rec_system.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../Globals.dart';
import 'Event.dart';

class EventsSelectorBuilder {
  // right now selector.or.eq.. is the same object in the heap, even if EventsSelectorBuilder is different!
  static EventsSelectorBuilder get ESB => EventsSelectorBuilder();
  final SelectorBuilder realSelector;
  final bool emptyQuery;
  // conditions that are MUST [not implemented for each method "against" itself, assuming each method called once]
  final Set<String> assigned;
  EventsSelectorBuilder([SelectorBuilder? selector, Set<String>? assigned])
      : realSelector = selector ?? where,
        assigned = assigned ?? Set(),
        emptyQuery = selector == null;

  EventsSelectorBuilder plus(SelectorBuilder? selector,
      [List<String> assign = const [], bool forceAssign = true]) {
    Set<String> set = Set.of(assigned);
    if (selector != null || forceAssign) {
      set.addAll(assign);
    }
    if (selector != null && !emptyQuery)
      selector = realSelector.and(selector);
    else if (selector == null)
      selector = realSelector;
    else
      selector = selector;
    // right now selector.or.eq.. is the same object in the heap, even if EventsSelectorBuilder is different!
    return EventsSelectorBuilder(selector, set);
  }

// both User.isForMe && EventsSelectorBuilder.targetForMe should have same logic
  /// add needed filters that for my target group(gender ...);
  /// only if I am not the creator etc...
  /// @okWhenCreator might not work well if assigned.contain("avoidTargetFilter")
  EventsSelectorBuilder targetForMe([bool okWhenCreator = true]) {
    var myMail = Globals.currentUser!.email;
    //
    if (assigned.intersection({
      // IinvolvedIn withParticipant cross
      "avoidTargetFilter",
      // I should see my createdBy, but not unrelevant lectures of others person
      okWhenCreator ? "createdBy: $myMail" : "notExistingString1234",
    }).isNotEmpty) {
      return this;
    }
    SelectorBuilder? prefix;
    // targeted age?
    int age = Globals.currentUser!.age;
    prefix = where.notExists("minAge").or(where.lte("minAge", age));
    prefix = prefix.and(where.notExists("maxAge").or(where.gte("maxAge", age)));
    // targeted gender
    var myGender = Globals.currentUser!.gender;
    if (myGender == 'M') {
      prefix = prefix.ne("targetGender", "נשים");
    } else if (myGender == 'F') {
      prefix = prefix.ne("targetGender", "גברים");
    }
    // targeted other issues?
    //prefix = prefix.onlyForStatus
    var l = Event.statusesICanJoin();
    prefix = l.length <= 1
        ? prefix
        : prefix.and(where
            .notExists("onlyForStatus")
            .or(where.oneFrom("onlyForStatus", l)));
    prefix = l.length != 1
        ? prefix
        : prefix.and(where
            .notExists("onlyForStatus")
            .or(where.eq("onlyForStatus", l[0])));
    if (okWhenCreator) {
      prefix = prefix.or(where.eq("creatorUser", myMail));
    }
    return this.plus(prefix);
  }

  EventsSelectorBuilder typeFilter(String? type) {
    return type == null ? this : this.plus(where.eq("type", type));
  }

  EventsSelectorBuilder searchWord(String? word) {
    if (word == null) return this;
    return this.plus(where
        .match('book', word)
        .or(where.match('topic', word))
        //.or(where.eq('type', 'H').and(where.match("creatorName", word)))
        .or(where.match("creatorName", word))
        .or(where.match("location",
            word)) // ? less general than description, but than just persons names
        .or(where.match('lecturer', word)));
  }

  EventsSelectorBuilder createdBy(String? mail) {
    if (mail == null || assigned.contains("createdBy: $mail")) return this;
    return this.plus(where.eq('creatorUser', mail),
        ["createdBy: $mail"]); // dont add "avoidTargetFilter"
  }

  EventsSelectorBuilder withParticipant(String? mail,
      [bool withWaitingQueue = true, bool withRejectedQueue = false]) {
    assert(withWaitingQueue || !withRejectedQueue);
    if (mail == null || assigned.contains("withParticipant/noWQ: $mail"))
      return this;
    if (withWaitingQueue) {
      if (assigned.contains("withParticipant/WQ: $mail")) {
        return this;
      }
      if (withRejectedQueue) {
        if (assigned.contains("withParticipant/RQ: $mail")) {
          return this;
        }

        return this.plus(
            where
                .eq('participants', mail)
                .or(where.eq('waitingQueue', mail))
                .or(where.eq('rejectedQueue', mail)),
            ["withParticipant/RQ: $mail", "avoidTargetFilter"]);
      }
      return this.plus(
          where.eq('participants', mail).or(where.eq('waitingQueue', mail)),
          ["withParticipant/WQ: $mail", "avoidTargetFilter"]);
    } else {
      return this.plus(where.eq('participants', mail),
          ["withParticipant/noWQ: $mail", "avoidTargetFilter"]);
    }
  }

  // not including rejected / left queues that have my mail
  EventsSelectorBuilder withInvolved(String? mail,
      [bool withWaitingQueue = true]) {
    if (mail == null ||
        assigned.contains("withParticipant/noWQ: $mail") ||
        assigned.contains("createdBy: $mail")) return this;
    var p = where.eq('participants', mail);
    var wq = where.eq('waitingQueue', mail);
    var c = where.eq('creatorUser', mail);
    if (withWaitingQueue) {
      if (assigned.contains("withParticipant/RQ: $mail")) {
        // but with withRejectedQueue==false
        return this.withParticipant(mail, true, false);
      }
      if (assigned.contains("withParticipant/WQ: $mail")) {
        return this;
      }
      return this.plus(c.or(p.or(wq)),
          ["withParticipant/WQ & createdBy: $mail", "avoidTargetFilter"]);
    } else {
      if (assigned.contains("withParticipant/WQ: $mail") ||
          assigned.contains("withParticipant/RQ: $mail")) {
        // but with withWaitingQueue==false
        return this.withParticipant(mail, false, false);
      }
      return this.plus(c.or(p),
          ["withParticipant/noWQ & createdBy: $mail", "avoidTargetFilter"]);
    }
  }

  EventsSelectorBuilder withWaitingQueueNotEmpty(
      [bool onlyIfCreatedByFilter = true]) {
    if (onlyIfCreatedByFilter &&
        !assigned.fold(
            false, (pre, curr) => pre || curr.startsWith("createdBy: ")))
      return this;
    return this.plus(where.ne("waitingQueue", null).ne("waitingQueue", []));
  }

  EventsSelectorBuilder cross(
      String mail1, String mail2, bool withRejectedQueue) {
    //clear selector, but avoid what already in this
    var suffix = () => EventsSelectorBuilder(null, assigned);
    /*bool mail1_p_cond = assigned.contains("withParticipant/noWQ: $mail1");
    bool mail1_pw_cond =
        mail1_p_cond || assigned.contains("withParticipant/WQ: $mail1");
    bool mail1_c_cond = assigned.contains("createdBy: $mail1");

    bool mail2_p_cond = assigned.contains("withParticipant/noWQ: $mail2");
    bool mail2_pw_cond =
        mail2_p_cond || assigned.contains("withParticipant/WQ: $mail2");
    bool mail2_c_cond = assigned.contains("createdBy: $mail2");*/
    EventsSelectorBuilder? op1, op2, op3;
    List<String> assign = ["avoidTargetFilter"];
    /*if (mail1_c_cond) assign.add("withParticipant/WQ: $mail2");
    if (mail2_c_cond) assign.add("withParticipant/WQ: $mail1");
    if (mail1_pw_cond && mail2_pw_cond) {
      assign.add("withParticipant/noWQ: $mail1");
      assign.add("withParticipant/noWQ: $mail2");
    }*/
    //if (!mail2_pw_cond && !mail1_c_cond)
    op1 = suffix()
        .withParticipant(mail1, true, withRejectedQueue)
        .createdBy(mail2);
    //if (!mail1_pw_cond && !mail2_c_cond)
    op2 = suffix()
        .withParticipant(mail2, true, withRejectedQueue)
        .createdBy(mail1);
    //if (!mail1_c_cond && !mail2_c_cond)
    op3 = suffix()
        .withParticipant(mail1, false, false)
        .withParticipant(mail2, false, false);
    List<EventsSelectorBuilder?> list = [op1, op2, op3]
        .where((e) => e != null && e.assigned.length != this.assigned.length)
        .toList();
    if (list.isEmpty) return this;
    if (list.length == 1) assign.addAll(list.first!.assigned);
    SelectorBuilder selector = list.first!.realSelector;
    for (int i = 1; i < list.length; i++)
      selector = list[i]!.realSelector.or(selector);
    return this.plus(selector, assign);
  }

  EventsSelectorBuilder sortById([bool newestFirst = true]) {
    return EventsSelectorBuilder(
        this.realSelector.sortBy('_id', descending: newestFirst),
        this.assigned);
  }

  EventsSelectorBuilder skip_limit(int? skip, int? limit) {
    SelectorBuilder rslt = this.realSelector;
    if (skip != null) {
      rslt = rslt.skip(skip);
    }
    if (limit != null) {
      rslt = rslt.limit(limit);
    }
    return EventsSelectorBuilder(rslt, assigned);
  }

  // eventTesters return null / the origin event / modified event / new event
  // assume we have event which all its dates are old
  // @filterOldEvents == true -> getEventsByQuery won't return that event
  // @filterOldEvents == false -> getEventsByQuery will return that event
  //     @filterOldDates == true -> getEventsByQuery will return that event with empty dates list
  //     @filterOldDates == false -> getEventsByQuery will return that event and it dates
  // if @filterOldEvents == true than @filterOldDates doesn't matter:
  //      @filterOldEvents == true  -->  @filterOldDates = true
  Future<List<Event>> fetch(bool filterOldEvents,
      {bool filterOldDates = true,
      List<Event? Function(Event)> eventTesters = const []}) async {
    filterOldDates = filterOldEvents || filterOldDates;
    var collection = Globals.db!.db.collection('Events');
    final events = (await collection.find(realSelector).toList());
    // if  filterOldDates = false  -> filterOldEvents = false
    if (!filterOldDates) {
      List<Event> tmp = [];
      for (var i in events) {
        tmp.add(
            Event.fromJson(await Mongo.getUpdateUserInfo(i, isEvent: true)));
      }
      return applyTesters(tmp, eventTesters);
    }
    // filterOldDates = true, but maybe we still won't filterOldEvents
    List<Event> data = [];
    DateTime timeNow = DateTime.now();
    for (var i in events) {
      Event e =
          new Event.fromJson(await Mongo.getUpdateUserInfo(i, isEvent: true));
      var len = e.dates!.length;
      // filterOldDate=true :
      for (int j = 0; j < len; j++) {
        if (timeNow
            .subtract(Duration(minutes: e.duration ?? 0))
            .isAfter(e.dates![j])) {
          e.dates!.remove(e.dates![j]);
          len -= 1;
          j--;
        }
      }
      // keep events if filterOldEvents=false or if it has dates
      if (!filterOldEvents || e.dates!.isNotEmpty) {
        data.add(e);
      }
    }
    return applyTesters(data, eventTesters);
  }

  // no implementation for all created&waiting&joined in this method
  static Future<List<Event>> fetchFrom({
    String? createdBy, //email
    bool onlyReq = false, // if createdBy != null
    //
    String? withParticipant, //email
    //relevant only if withParticipant != null
    //then not only joined but also waiting;
    bool withWaitingQueue = true,
    required bool withRejectedQueue,
    String? withParticipant2, //email
    //
    String? search,
    String? typeFilter,
    //
    int? startFrom = 0,
    int? maxEvents = 10,
    bool newestFirst = true,
    //
    bool filterOldEvents = true,
    bool filterOldDates = true, // dont change
    //// eventTesters return null / the origin event / modified event / new event
    List<Event? Function(Event)> eventTesters = const [],
  }) {
    if ((createdBy != null || withParticipant != null) && filterOldEvents) {
      // maybe for only accept future havruta requests?
      //myPrint("ESB: are you sure you intended to filterOldEvents?",
      //    MyPrintType.None);
    }
    EventsSelectorBuilder esb = ESB;
    esb = withParticipant2 != null
        ? esb.cross(withParticipant!, withParticipant2, withRejectedQueue)
        : esb.withParticipant(
            withParticipant, withWaitingQueue, withRejectedQueue);
    esb = esb.createdBy(createdBy);
    esb = onlyReq ? esb.withWaitingQueueNotEmpty(true) : esb;
    esb = esb
        .searchWord(search)
        .typeFilter(typeFilter)
        // for current logged-User; assuming @withParticipant == null or MY mail
        //                        ; assuming @createdBy == null or MY mail
        //      so there is no need to filter when these not null:
        // withParticipant() createdBy(*see targetForMe()) cross() withInvolved()
        .targetForMe()
        .sortById(newestFirst)
        .skip_limit(startFrom, maxEvents);
    return esb.fetch(filterOldEvents,
        eventTesters: eventTesters, filterOldDates: filterOldDates);
  }

  // only implementation for all created&waiting&joined in this method
  static Future<List<Event>> IinvolvedIn({
    required String myMail, //email
    //then not only joined but also waiting;
    bool withWaitingQueue = true,
    //
    String? search,
    String? typeFilter,
    //
    int? startFrom = 0,
    int? maxEvents = 10,
    bool newestFirst = true,
    //
    bool filterOldEvents = true,
    bool filterOldDates = true, // dont change
    //// eventTesters return null / the origin event / modified event / new event
    List<Event? Function(Event)> eventTesters = const [],
  }) {
    if (filterOldEvents) {
      // might be true if we wont to avoid future event overlaps
      //myPrint("ESB: are you sure you intended to filterOldEvents?",
      //    MyPrintType.None);
    }
    EventsSelectorBuilder esb = ESB;
    esb = esb
        .withInvolved(
            myMail, withWaitingQueue) // events I created/joined/waiting
        .searchWord(search)
        .typeFilter(typeFilter)
        // no need to add .targetForMe()
        .sortById(newestFirst)
        .skip_limit(startFrom, maxEvents);
    return esb.fetch(filterOldEvents,
        eventTesters: eventTesters, filterOldDates: filterOldDates);
  }

  // eventTesters return null / the origin event / modified event / new event
  static List<Event> applyTesters(
      List<Event> events, List<Event? Function(Event)> testers) {
    List<Event?> rslt = List.of(events);
    for (int i = 0; i < rslt.length; i++) {
      for (var test in testers) {
        rslt[i] = rslt[i] == null ? null : test(rslt[i]!);
      }
    }
    return rslt.where((e) => e != null).map((e) => e!).toList();
  }

  // if times != null, change Event.dates, and return true iff Event.dates.isNotEmpty
  static Event? Function(Event) timeFilter(
    List<PartOfDay>? times,
  ) {
    Set timesset = times?.toSet() ?? Set();
    return (Event e) {
      if (times == null) return e;
      int duration = e.duration ?? 0;
      var testOneDate = (t) => getPartsOfDayOf(t, duration)
          .toSet()
          .intersection(timesset)
          .isNotEmpty;
      e.dates = e.dates!.where(testOneDate).toList();
      return e.dates!.isNotEmpty ? e : null;
    };
  }
}
