import 'package:flutter/material.dart';
import 'package:havruta_project/mydebug.dart';
//import 'package:flutter/cupertino.dart';
import 'modelsHomePages.dart';
import 'package:havruta_project/Screens/HomePageScreen/Events/EventViewFeed.dart';
import 'EventOnlineFeed.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';

// ignore: must_be_immutable
class Events extends StatefulWidget {
  //EventsModel events;
  EventsModel events;
  EventsModel? eventsOnline;
  String? user2View;

  Events(this.events, this.eventsOnline, {this.user2View});

  @override
  _EventsState createState() => _EventsState();
}

enum EventsFilter { Havruta, Shiur, Ijoined, Icreated, hasNonEmptyWaitingQueue }

class EventsFilters {
  // true if agree, false if disagree, @onUnknown if unknown, if false then false always
  static bool? test(Map a, Map b,
      [bool onUnknownBreak = false, bool? onUnknownRslt]) {
    var inte = a.keys.toSet().intersection(b.keys.toSet());
    var rslt = inte.every((k) => a[k] == b[k]);
    if (rslt == false) return false;
    if (a.length < inte.length && b.length < inte.length) {
      return onUnknownBreak ? onUnknownRslt : rslt;
    }
    return rslt;
  }

  static const Map<EventsFilter, bool> NoFilter = {
    EventsFilter.Havruta: false,
    EventsFilter.Icreated: false,
    EventsFilter.Ijoined: false,
    EventsFilter.Shiur: false,
    EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToHav = {
    EventsFilter.Havruta: true,
    EventsFilter.Shiur: false,
    //EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToShiur = {
    EventsFilter.Havruta: false,
    EventsFilter.Shiur: true,
    EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToShiurAndHav = {
    EventsFilter.Havruta: false,
    EventsFilter.Shiur: false,
    EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToIcreated = {
    EventsFilter.Icreated: true,
    EventsFilter.Ijoined: false,
    //EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToIjoined = {
    EventsFilter.Icreated: false,
    EventsFilter.Ijoined: true,
    EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToNewEvents = {
    EventsFilter.Icreated: false,
    EventsFilter.Ijoined: false,
    EventsFilter.hasNonEmptyWaitingQueue: false,
  };
  static const Map<EventsFilter, bool> ToPendingHavReq = {
    EventsFilter.Icreated: true,
    EventsFilter.Ijoined: false,
    EventsFilter.Havruta: true,
    EventsFilter.Shiur: false,
    EventsFilter.hasNonEmptyWaitingQueue: true,
  };
}

class _EventsState extends State<Events> {
  final scrollController = ScrollController();
  final scrollControllerOnline = ScrollController();
  final TextEditingController searchTextController = TextEditingController();
  String? typeFilter;
  Map<EventsFilter, bool> filter = Map.of(EventsFilters.NoFilter);
  // EventsModel events;
  //EventsModel eventsOnline;
  refresh() {
    this.widget.events.refresh();
    this.widget.eventsOnline?.refresh();
  }

  @override
  void initState() {
    super.initState();
    //this.widget.events = EventsModel(false);
    //this.widget.eventsOnline = EventsModel(true);
    Globals.updateRec(force: true);
    /*scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        this.widget.events.loadMore();
      }
    });
    scrollControllerOnline.addListener(() {
      if (scrollControllerOnline.position.maxScrollExtent ==
          scrollControllerOnline.offset) {
        this.widget.eventsOnline?.loadMore();
      }
    });*/

    this.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(children: <Widget>[
            this.widget.eventsOnline == null
                ? SizedBox(
                    height: Globals.scaler.getHeight(2),
                  )
                : Expanded(flex: 2, child: eventsOnlineScroll()),
            searchBar(),
            Expanded(flex: 7, child: eventsScroll())
          ])),
    );
  }

  eventsScroll() {
    return Scrollbar(
        child: StreamBuilder(
      stream: this.widget.events.stream,
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (!_snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return RefreshIndicator(
            onRefresh: this.widget.events.refresh,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 1.0),
              controller: scrollController,
              separatorBuilder: (context, index) => Divider(
                thickness: 0,
              ),
              itemCount: _snapshot.data.length + 1,
              itemBuilder: (BuildContext _context, int index) {
                if (index < _snapshot.data.length) {
                  return EventViewFeed(
                    event: _snapshot.data[index],
                    search: searchTextController.text,
                    user2View: widget.user2View,
                  );
                } else {
                  String txt = (index == 0 && !widget.events.hasMore)
                      ? "- רשימה ריקה -"
                      : "";
                  if (widget.events.hasMore) {
                    txt = "- טוען -";
                    // needed if scrollController not call listener
                    Future.delayed(
                        MyConsts.defaultDelay, () => widget.events.loadMore());
                  }
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(txt),
                      ));
                }
              },
            ),
          );
        }
      },
    ));
  }

  eventsOnlineScroll() {
    return new Stack(children: <Widget>[
      Scrollbar(
          child: StreamBuilder(
        stream: this.widget.eventsOnline!.stream,
        builder: (BuildContext _context, AsyncSnapshot _snapshot) {
          if (!_snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return RefreshIndicator(
              onRefresh: this.widget.eventsOnline!.refresh,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 0),
                controller: scrollControllerOnline,
                separatorBuilder: (context, index) => Divider(
                  thickness: 0,
                ),
                itemCount: _snapshot.data.length + 1,
                itemBuilder: (BuildContext _context, int index) {
                  if (index < _snapshot.data.length) {
                    return EventOnlineFeed(event: _snapshot.data[index]);
                  } else if (this.widget.eventsOnline!.hasMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                    );
                  }
                },
              ),
            );
          }
        },
      )),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
          height: Globals.scaler.getHeight(1),
          width: Globals.scaler.getWidth(10),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: const BorderRadius.all(
              Radius.elliptical(10, 10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.white,
                  offset: const Offset(0, 0),
                  blurRadius: 10.0),
            ],
          ),
          alignment: Alignment.center,
          child: Text('שיעורים מומלצים',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: Globals.scaler.getTextSize(6),
                  fontWeight: FontWeight.bold)),
        )
      ]),
    ]);
  }

  searchBar() {
    bool isSearchTextEmpty = searchTextController.text == "";
    IconData typeFilterIcon = FontAwesomeIcons.filterCircleXmark;
    if (widget.events is EventsModelMultiFilter) {
      typeFilterIcon = FontAwesomeIcons.filter;
    } else if (typeFilter == 'L') {
      typeFilterIcon = FontAwesomeIcons.graduationCap;
    } else if (typeFilter == 'H') {
      typeFilterIcon = FontAwesomeIcons.users;
    }
    return Center(
        //padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 20),
        child: Column(children: <Widget>[
      SizedBox(height: Globals.scaler.getHeight(0.3)),
      Row(
        children: <Widget>[
          SizedBox(width: Globals.scaler.getWidth(1)),
          IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            icon: Icon(typeFilterIcon,
                size: Globals.scaler.getTextSize(8),
                color: Colors.red,
                textDirection: TextDirection.rtl),
          ),
          SizedBox(width: Globals.scaler.getWidth(1)),
          Expanded(
            child: Container(
              height: Globals.scaler.getHeight(2.5),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.all(
                  Radius.circular(38.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      offset: const Offset(0, 2),
                      blurRadius: 8.0),
                ],
              ),
              child: TextField(
                  textInputAction: TextInputAction.go,
                  textAlign: TextAlign.center, //
                  controller: searchTextController, //
                  textDirection: TextDirection.rtl, //
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: isSearchTextEmpty
                            ? null
                            : () {
                                if (!isSearchTextEmpty) {
                                  setState(() {
                                    searchTextController.clear();
                                    this.widget.events.searchData = null;
                                    this.widget.events.refresh();
                                  });
                                }
                              }, // Does the widget build for setState() ??
                        icon: Icon(Icons.clear,
                            size: Globals.scaler.getTextSize(8),
                            color: isSearchTextEmpty
                                ? Colors.transparent
                                : Colors.grey,
                            textDirection: TextDirection.rtl),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }, //MediaQuery.of(context).ke,
                        icon: Icon(FontAwesomeIcons.magnifyingGlass,
                            size: Globals.scaler.getTextSize(8),
                            color: Colors.red,
                            textDirection: TextDirection.rtl),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      //hintText: 'חפש חברותא'),
                      hintText: 'חפש'),
                  onChanged: (text) {
                    // ??if we have 2 words?   text = text.replaceAll(new RegExp(r"\s+"), "");
                    text = text.trim();
                    setState(() {
                      // Does the widget build for setState() ??
                      if (text == "") {
                        this.widget.events.searchData = null;
                      } else {
                        this.widget.events.searchData = text.toLowerCase();
                      }
                      this.widget.events.refresh();
                    });
                  }),
            ),
          ),
          SizedBox(width: Globals.scaler.getWidth(1)),
        ],
      ),
      SizedBox(height: Globals.scaler.getHeight(1))
    ]));
  }

  Widget bottomSheet() {
    // for full filter abilty
    if (this.widget.events is EventsModelMultiFilter) {
      return Bottom(filter, this.widget.events as EventsModelMultiFilter);
    }

    // for some filter abilty (cross events of 2 users)
    return Container(
      height: Globals.scaler.getHeight(5.5),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: Globals.scaler.getWidth(3),
        vertical: Globals.scaler.getHeight(1),
      ),
      child: Column(
        children: <Widget>[
          Text(
            "בחר סוג",
            style: TextStyle(
              fontSize: Globals.scaler.getTextSize(8.5),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.users),
              onPressed: () {
                setState(() {
                  if (typeFilter != 'H') {
                    this.typeFilter = 'H';
                    this.widget.events.typeFilter = 'H';
                    this.widget.events.refresh();
                  }
                  Navigator.pop(context);
                });
              },
              label: Text("חברותא"),
            ),
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.graduationCap),
              onPressed: () {
                setState(() {
                  if (this.typeFilter != 'L') {
                    this.typeFilter = 'L';
                    this.widget.events.typeFilter = 'L';
                    this.widget.events.refresh();
                  }
                  Navigator.pop(context);
                });
              },
              label: Text("שיעור"),
            ),
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.filterCircleXmark),
              onPressed: () {
                setState(() {
                  if (this.typeFilter != null) {
                    this.typeFilter = null;
                    this.widget.events.typeFilter = null;
                    this.widget.events.refresh();
                  }
                  Navigator.pop(context);
                });
              },
              label: Text("לא משנה"),
            ),
          ])
        ],
      ),
    );
  }
}

class Bottom extends StatefulWidget {
  final Map<EventsFilter, bool> filterRef;
  final EventsModelMultiFilter model;
  const Bottom(this.filterRef, this.model, {Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  Map<EventsFilter, bool> filterCopy = {};
  @override
  void initState() {
    super.initState();
    filterCopy = Map.of(widget.filterRef);
  }

  Widget myButton(
      String label, IconData icon, dynamic applyMap, selected, unselected) {
    bool on = EventsFilters.test(filterCopy, applyMap, false)!; //true, true)!;
    dynamic func = on
        ? null
        : () {
            filterCopy.addAll(applyMap);
            setState(() {});
          };

    var colors = on ? selected : unselected;
    var b = OutlinedButton(
        onPressed: func,
        style: OutlinedButton.styleFrom(
            foregroundColor: unselected[1],
            side: BorderSide(color: colors[0], width: 2),
            disabledBackgroundColor: selected[2],
            disabledForegroundColor: selected[1]),
        child: Row(
          children: [
            Icon(
              icon,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              label,
            )
          ],
        ));
    return b;
  }

  mybuttonRow(List bttns, selected, unselected) {
    return Row(
      mainAxisAlignment: bttns.length == 1
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: bttns
          .map((e) => myButton(e[0], e[1], e[2], selected, unselected))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    //outline text fill
    var selected1 = [Colors.blue, Colors.blue, Colors.transparent];
    var unselected1 = [Colors.transparent, Colors.blue, Colors.transparent];
    var selected2 = [Colors.purple, Colors.purple, Colors.transparent];
    var unselected2 = [Colors.transparent, Colors.purple, Colors.transparent];
    var selected3 = [
      Colors.orange[800],
      Colors.orange[800],
      Colors.transparent
    ];
    var unselected3 = [
      Colors.transparent,
      Colors.orange[800],
      Colors.transparent
    ];
    return Container(
        height: Globals.scaler.getHeight(20),
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
          horizontal: Globals.scaler.getWidth(3),
          vertical: Globals.scaler.getHeight(1),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "סנן לפי",
                style: TextStyle(
                  fontSize: Globals.scaler.getTextSize(8.5),
                ),
              ),
              Divider(thickness: 3),
              mybuttonRow([
                ["חברותא", FontAwesomeIcons.users, EventsFilters.ToHav],
                [
                  "שיעור",
                  FontAwesomeIcons.graduationCap,
                  EventsFilters.ToShiur
                ],
                [
                  "הכל",
                  FontAwesomeIcons.filterCircleXmark,
                  EventsFilters.ToShiurAndHav
                ]
              ], selected1, unselected1),
              Divider(thickness: 3),
              mybuttonRow([
                [
                  "ביוזמתי",
                  FontAwesomeIcons.personChalkboard,
                  EventsFilters.ToIcreated
                ],
                ["נרשמתי", FontAwesomeIcons.handshake, EventsFilters.ToIjoined],
                [
                  "הכל",
                  FontAwesomeIcons.filterCircleXmark,
                  EventsFilters.ToNewEvents
                ]
              ], selected2, unselected2),
              Divider(thickness: 3),
              mybuttonRow([
                [
                  "מחכים לאישור ממני",
                  FontAwesomeIcons.ellipsis,
                  EventsFilters.ToPendingHavReq
                ],
              ], selected3, unselected3),
              Divider(thickness: 3),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 255, 4, 4),
                      side: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.circleXmark,
                        ),
                        Text(
                          "  " + "ביטול",
                        )
                      ],
                    )),
                OutlinedButton(
                    onPressed: () {
                      if (EventsFilters.test(filterCopy, widget.filterRef,
                              false) == //true, false) ==
                          false) {
                        widget.filterRef.addAll(filterCopy);
                        widget.model.filter = Map.of(widget.filterRef);
                        widget.model.refresh();
                      }
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[900],
                      side: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.check,
                        ),
                        Text(
                          "  " + "סינון",
                        )
                      ],
                    )),
              ]),
              /*
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.filterCircleXmark),
              onPressed: () {
                setState(() {
                  this.typeFilter = null;
                  this.widget.events.typeFilter = null;
                  this.widget.events.refresh();
                  Navigator.pop(context);
                });
              },
              label: Text("לא משנה"),
            ),*/
            ]));
  }
}
