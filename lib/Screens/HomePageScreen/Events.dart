import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'modelsHomePages.dart';
import 'package:havruta_project/Screens/HomePageScreen/EventViewFeed.dart';
import 'EventOnlineFeed.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';

class Events extends StatefulWidget {
  const Events({
    Key key,
  }) : super(key: key);

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final scrollController = ScrollController();
  final scrollControllerOnline = ScrollController();

  EventsModel events;
  EventsModel eventsOnline;

  @override
  void initState() {
    events = EventsModel(false);
    eventsOnline = EventsModel(true);
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        print(events);
        events.loadMore();
      }
    });
    scrollControllerOnline.addListener(() {
      if (scrollControllerOnline.position.maxScrollExtent ==
          scrollControllerOnline.offset) {
        print(eventsOnline.runtimeType);
        eventsOnline.loadMore();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(children: <Widget>[
          Expanded(flex: 3, child: eventsOnlineScroll()),
          searchBar(),
          Expanded(flex: 7, child: eventsScroll())
        ]));
  }

  eventsScroll() {
    return Scrollbar(
        child: StreamBuilder(
      stream: events.stream,
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (!_snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return RefreshIndicator(
            onRefresh: events.refresh,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 1.0),
              controller: scrollController,
              separatorBuilder: (context, index) => Divider(
                thickness: 0,
              ),
              itemCount: _snapshot.data.length + 1,
              itemBuilder: (BuildContext _context, int index) {
                if (index < _snapshot.data.length) {
                  return EventViewFeed(event: _snapshot.data[index]);
                } else if (events.hasMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
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
        stream: eventsOnline.stream,
        builder: (BuildContext _context, AsyncSnapshot _snapshot) {
          if (!_snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return RefreshIndicator(
              onRefresh: eventsOnline.refresh,
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
                  } else if (eventsOnline.hasMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return null;
                  }
                },
              ),
            );
          }
        },
      )),
      Container(
        margin: new EdgeInsets.symmetric(horizontal: 150),
        height: 20,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: const BorderRadius.all(
            Radius.elliptical(5, 10),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.white,
                offset: const Offset(0, 0),
                blurRadius: 10.0),
          ],
        ),
        alignment: Alignment.center,
        child: Text('Live שיעורים',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  searchBar() {
    String searchBarString;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 10),
      child: Row(
        children: <Widget>[
          Material(
              child: InkWell(
                  splashColor: Colors.red,
                  customBorder: CircleBorder(),
                  onTap: () {
                    print(1);
                    events.searchData = searchBarString;
                    events.refresh();
                  },
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(38.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.red,
                              offset: const Offset(0, 2),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: (Icon(FontAwesomeIcons.search,
                          size: 22, color: Colors.grey[50]))))),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 15, right: 20, top: 8, bottom: 0),
              child: Container(
                height: 40,
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
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: 'חפש חברותא'),
                    onChanged: (text) {
                      if (text.toLowerCase() == "") {
                        searchBarString = null;
                      } else {
                        searchBarString = text.toLowerCase();
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
