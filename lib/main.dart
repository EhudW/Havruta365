import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'file:///C:/src/Havruta365/lib/Screens/HomePageScreen/home_page.dart';
import 'package:loading_animations/loading_animations.dart';

import 'Screens/SignupScreen.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future mongoConnectFuture;

  @override
  void initState(){
    super.initState();
    Globals.db = new Mongo();
    mongoConnectFuture = Globals.db.connect();
  }

  @override
  void dispose(){
    super.dispose();
    Globals.db.db.close();
  }


  Event event = Event.fromJson({'id': '123', 'creatorUser': "michal@gmail.com",
    'creationDate': '123',
    'type': 'lesson', 'topic':"תלמוד בבלי", 'book':"הדף היומי",
    'link':"https://www.dirshu.co.il/31469-2/",
    'description':'דרשו מגיש:\nשיעורי הדף היומי בגמרא בצורה פשוטה ובהירה,\nמפי הרב אליהו אורנשטיין שליט"א',
    'eventImage':"https://moreshet-maran.com/wp-content/uploads/2020/04/%D7%94%D7%93%D7%A3-%D7%94%D7%99%D7%95%D7%9E%D7%99.jpg",
    'lecturer':"הרב אליהו אורנשטיין",
    'participants':["4yona@gmail.com", "4yona4@gmail.com", "michal@gmail.com"],
    'dates':[]});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: FutureBuilder(
            future: mongoConnectFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: LoadingBouncingGrid.square(
                      borderColor: Colors.teal[400],
                      backgroundColor: Colors.teal[400],
                      size: 80.0,
                    ),
                  );
                case ConnectionState.done:
                  return HomePage();
                default:
                  return Text('default');
              }
            },
          ),
        )
      ),
    );
  }
}