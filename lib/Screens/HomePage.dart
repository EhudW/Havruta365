import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';

import 'package:http/http.dart' as http;

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Event> _events = List<Event>();
  List<Event> _eventsForDisplay = List<Event>();

  Future<List<Event>> fetchNotes() async {
    var url = 'https://raw.githubusercontent.com/boriszv/json/master/random_example.json';
    var response = await http.get(url);

    var events = List<Event>();
    Event n = new Event('_user', '_type', '_topic', '_book', '_times', '_hour',
        '_date', '_participants', '_link', '_descripton');
    events.add(n);
    Event n2 = new Event('user1', 'type1', 'topic1', 'book1', 'times1', 'hour1',
        'date1', 'participants1', 'link1', 'descripton1');
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);
    events.add(n2);

    // if (response.statusCode == 200) {
    //   var EventesJson = json.decode(response.body);
    //   for (var noteJson in notesJson) {
    //     notes.add(Event.fromJson(noteJson));
    //   }
    // }
    return events;
  }

  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        _events.addAll(value);
        _eventsForDisplay = _events;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: Text('havruta project'),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return index == 0 ? _searchBar() : _listItem(index-1);
          },
          itemCount: _eventsForDisplay.length+1,
        )
    );
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search...'
        ),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _eventsForDisplay = _events.where((event) {
              var eventTitle = event.topic.toLowerCase();
              return eventTitle.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index) {
    return Card(  child: new InkWell(
        onTap: () {
      print(index);
      //NavigationToolbar.push(context, new MaterialPageRoute(bulder))
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0, bottom: 32.0, left: 16.0, right: 16.0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _eventsForDisplay[index].topic,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              _eventsForDisplay[index].book,
              style: TextStyle(
                  color: Colors.grey.shade600
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}