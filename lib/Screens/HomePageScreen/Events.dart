import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'modelsHomePages.dart';
import 'package:havruta_project/Screens/HomePageScreen/EventViewFeed.dart';
import 'EventOnlineFeed.dart';
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
        events.loadMore();
      }
    });
    scrollControllerOnline.addListener(() {
      if (scrollControllerOnline.position.maxScrollExtent ==
          scrollControllerOnline.offset) {
        eventsOnline.loadMore();
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
            Expanded(flex: 2, child: eventsOnlineScroll()),
            searchBar(),
            Expanded(flex: 7, child: eventsScroll())
          ])),
    );
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
                    child: Center(
                        child: _snapshot.data.length == 0
                            ? Text("לא נמצאה חברותא מתאימה")
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
                      child: Center(
                          child: _snapshot.data.length == 0
                              ? Text("לא נמצאה חברותא מתאימה")
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
    String searchBarString;
    return Center(
        //padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 20),
        child: Column(children: <Widget>[
          SizedBox(height: Globals.scaler.getHeight(0.3)),
      Row(
        children: <Widget>[
          SizedBox(width: Globals.scaler.getWidth(1)),
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
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      suffixIcon: Icon(FontAwesomeIcons.search,
                          size: Globals.scaler.getTextSize(8), color: Colors.red , textDirection: TextDirection.rtl),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'חפש חברותא'),
                  onChanged: (text) {
                    print(text);
                    text.replaceAll(new RegExp(r"\s+"), "");
                    if (text == "") {
                      events.searchData = null;
                    } else {
                      searchBarString = text.toLowerCase();
                      events.searchData = searchBarString;
                    }
                    events.refresh();
                  }),
            ),
          ),
          SizedBox(width: Globals.scaler.getWidth(1)),
        ],
      ),
      SizedBox(height: Globals.scaler.getHeight(1))
    ]));
  }
}
