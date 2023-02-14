import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'modelsHomePages.dart';
import 'package:havruta_project/Screens/HomePageScreen/Events/EventViewFeed.dart';
import 'EventOnlineFeed.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';

// ignore: must_be_immutable
class Events extends StatefulWidget {
  EventsModel events;
  EventsModel? eventsOnline;

  Events(this.events, this.eventsOnline);

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final scrollController = ScrollController();
  final scrollControllerOnline = ScrollController();
  final TextEditingController searchTextController = TextEditingController();
  String? typeFilter;
  // EventsModel events;
  //EventsModel eventsOnline;
  refresh() {
    this.widget.events.refresh();
    this.widget.eventsOnline?.refresh();
  }

  @override
  void initState() {
    //this.widget.events = EventsModel(false);
    //this.widget.eventsOnline = EventsModel(true);
    scrollController.addListener(() {
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
    });
    super.initState();
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
                  );
                } else if (this.widget.events.hasMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                        child: _snapshot.data.length == 0
                            //? Text("לא נמצאה חברותא מתאימה")
                            ? Text("לא נמצאה תוצאה מתאימה")
                            : Text("")),
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
    if (typeFilter == 'L') {
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
                  this.typeFilter = 'H';
                  this.widget.events.typeFilter = 'H';
                  this.widget.events.refresh();
                  Navigator.pop(context);
                });
              },
              label: Text("חברותא"),
            ),
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.graduationCap),
              onPressed: () {
                setState(() {
                  this.typeFilter = 'L';
                  this.widget.events.typeFilter = 'L';
                  this.widget.events.refresh();
                  Navigator.pop(context);
                });
              },
              label: Text("שיעור"),
            ),
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
            ),
          ])
        ],
      ),
    );
  }
}
