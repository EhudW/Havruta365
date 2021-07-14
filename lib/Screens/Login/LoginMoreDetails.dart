import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Globals.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';

class LoginMoreDetails extends StatefulWidget {


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<LoginMoreDetails> {
  final yeshiva = TextEditingController();
  String yeshiva_str = " ";
  final description = TextEditingController();
  String description_str = " ";
  final status = TextEditingController();
  String status_str = "סטטוס משפחתי";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Globals.scaler.getHeight(1)),
            Align(
                alignment: Alignment.centerRight,
                child:Text("פרטים נוספים   " ,style: GoogleFonts.alef(
                    fontSize: 18,
                    color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(8)),
      FadeAnimation(1.7,
              Container(
                  alignment: AlignmentDirectional.centerEnd,
                  width: Globals.scaler.getWidth(20),
                  height: Globals.scaler.getHeight(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(1),
                          offset: const Offset(0, 2),
                          blurRadius: 8.0),
                    ],
                  ),
                  child: DropdownButton<String>(
                    iconDisabledColor: Colors.teal,
                    isExpanded: true,
                    value: status_str,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 30,
                    //this inicrease the size
                    elevation: 100,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                    underline: Container(),
                    onChanged: (String newValue) {
                      setState(() {
                        status_str = newValue;
                      });
                    },
                    items: <String>["סטטוס משפחתי","רווק/ה", 'נשוי/אה', 'גרוש/ה']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value, textAlign: TextAlign.center)),
                      );
                    }).toList(),
                  )),
            ),
            newFiled(yeshiva, yeshiva_str, "ישיבה/מדרשה", FontAwesomeIcons.book,
                3.0),
            newFiled1(description, description_str, "פרטים שחשוב לך לשתף",
                FontAwesomeIcons.list, 8.0),
            SizedBox(height: Globals.scaler.getHeight(1)),
            ElevatedButton(
              child: Text(
                "מצא לי חברותא ",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(
                    fontSize: 23, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize:
                  Size(Globals.scaler.getWidth(32), Globals.scaler.getHeight(3)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(38.0),
                  ),
                  primary: Colors.red,
                  // <-- Button color
                  onPrimary: Colors.teal),
              onPressed: () async {
                // TODO currentUser.id - save ObjectId locally
                var coll = Globals.db.db.collection('Users');
                var user_json = await coll.findOne(where.eq('email', Globals.currentUser.email));
                // This is ObjectID!!
                var id = user_json['_id'];
                final SharedPreferences prefs = await _prefs;
                await prefs.setString('id', id.toString());
                yeshiva_str = yeshiva.text;
                description_str = description.text;
                status_str = status.text;
                Globals.currentUser.yeshiva = yeshiva_str;
                Globals.currentUser.description = description_str;
                Globals.currentUser.status = status_str;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1)),
          ],
        ),
      ),
    );
  }
}

newFiled(controller, str, text, icon, size) {
  return FadeAnimation(
      1.7,
    new Column(children: <Widget>[
      SizedBox(height: Globals.scaler.getHeight(1)),
      Center(
        child: Container(
          alignment: AlignmentDirectional.center,
          width: Globals.scaler.getWidth(32),
          height: Globals.scaler.getHeight(size),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(30.0),
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
              controller: controller,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  suffixIcon: Icon(
                    icon,
                    size: 22,
                    color: Colors.red,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: text),
              onChanged: (text) {
                str = controller.text;
                print(text);
              }),
        ),
      ),
    ]),
  );
}

newFiled1(controller, str, text, icon, size) {
  return FadeAnimation(
    1.7,
    new Column(children: <Widget>[
      SizedBox(height: Globals.scaler.getHeight(1)),
      Center(
        child: Container(
          alignment: AlignmentDirectional.center,
          width: Globals.scaler.getWidth(32),
          height: Globals.scaler.getHeight(size),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(30.0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(1),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: TextField(
              maxLines: null,
              expands: true,
              textAlign: TextAlign.center,
              controller: controller,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  suffixIcon: Icon(
                    icon,
                    size: 22,
                    color: Colors.red,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: text),
              onChanged: (text) {
                str = controller.text;
                print(text);
              }),
        ),
      ),
    ]),
  );
}
appBar(BuildContext context) {
  ScreenScaler scaler = new ScreenScaler();

  return new AppBar(
      leadingWidth: 0,
      toolbarHeight: 40,
      elevation: 30,
      shadowColor: Colors.teal[400],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
          )),
      backgroundColor: Colors.white,
      title: Container(
        width: scaler.getWidth(50),
        child:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            "משתמש חדש  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(
                fontWeight: FontWeight.bold,
                fontSize: Globals.scaler.getTextSize(9),
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.userAlt, size: 20, color: Colors.teal[400])
        ]),
      ));
}