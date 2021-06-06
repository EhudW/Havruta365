import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/EventScreen/EventScreen.dart';
import 'package:havruta_project/Screens/Login/Login1.dart';
import 'package:loading_animations/loading_animations.dart';

import 'DataBase_auth/User.dart';
import 'Screens/HomePageScreen/home_page.dart';
import 'Screens/Login/SignupScreen.dart';

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


  @override
  Widget build(BuildContext context) {
    DateTime a = DateTime.now();
    Event e1 = Event.fromJson({'id': '123', 'creatorUser': "michal@gmail.com",
      'creationDate': DateTime.now(),
      'type': 'lesson', 'topic':"תלמוד בבלי", 'book':"הדף היומי",
      'link':"https://www.dirshu.co.il/31469-2/",
      'description':'דרשו מגיש:\nשיעורי הדף היומי בגמרא בצורה פשוטה ובהירה,\nמפי הרב אליהו אורנשטיין שליט"א',
      'eventImage':"https://moreshet-maran.com/wp-content/uploads/2020/04/%D7%94%D7%93%D7%A3-%D7%94%D7%99%D7%95%D7%9E%D7%99.jpg",
      'lecturer':"הרב אליהו אורנשטיין",
      'participants':["4yonatan4@gmail.com", "michal@gmail.com"],
      'dates':<dynamic>["05-25-2021: 06:22 - 05:20", "05-25-2021: 06:22 - 05:20", "05-25-2021: 06:22 - 05:20", "05-25-2021: 06:22 - 05:20"]});

    User u1 = User.fromUser('Yonatan', '4yonatan4@gmail.com','male');

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
                  Globals.db.insertEvent(e1);
                  Globals.currentUser = u1;

                  return EventScreen(e1);
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