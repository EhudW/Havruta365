import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/Screens/HomePageScreen/home_page.dart';
import 'Login3.dart';

import '../../Globals.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';

class LoginMoreDetails extends StatefulWidget {
  LoginMoreDetails(this.email);

  final String email;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<LoginMoreDetails> {
  final yeshiva = TextEditingController();
  String yeshiva_str = "";
  final description = TextEditingController();
  String description_str = "";
  final status = TextEditingController();
  String status_str = "רווק/ה";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        child: Text(
          "מצא לי חברותא ",
          textAlign: TextAlign.center,
          style: GoogleFonts.abel(
              fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            minimumSize:
                Size(Globals.scaler.getWidth(35), Globals.scaler.getHeight(3)),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(38.0),
            ),
            primary: Colors.red,
            // <-- Button color
            onPrimary: Colors.teal),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
      backgroundColor: Colors.teal[100],
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Globals.scaler.getHeight(10)),
      FadeAnimation(1.7,
              Container(
                  alignment: AlignmentDirectional.centerEnd,
                  width: Globals.scaler.getWidth(20),
                  height: Globals.scaler.getWidth(5.5),
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
                    items: <String>["רווק/ה", 'נשוי/אה', 'גרוש/ה']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value, textAlign: TextAlign.center)),
                      );
                    }).toList(),
                  )),
            ),
            newFiled(yeshiva, yeshiva_str, "ישיבה/מדרשה", FontAwesomeIcons.book,
                6.0, false),
            newFiled(description, description_str, "פרטים שחשוב לך לשתף",
                FontAwesomeIcons.list, 10.0, true),
            SizedBox(height: Globals.scaler.getHeight(4)),
          ],
        ),
      ),
    );
  }
}

newFiled(controller, str, text, icon, size, expands) {
  return FadeAnimation(
      1.7,
    new Column(children: <Widget>[
      SizedBox(height: Globals.scaler.getHeight(1.5)),
      Center(
        child: Container(
          alignment: AlignmentDirectional.center,
          width: Globals.scaler.getWidth(35),
          height: Globals.scaler.getWidth(size),
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
              expands: expands,
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

button(name_str) {
  return OutlineButton(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    onPressed: () async {
      print(name_str);
    },
    child: Center(
      child: Text(
        "כניסה",
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    ),
  );
}

appBar(BuildContext context) {
  ScreenScaler scaler = new ScreenScaler();

  return new AppBar(
      leadingWidth: 40,
      toolbarHeight: 40,
      elevation: 10,
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
                fontSize: 20,
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.userAlt, size: 20, color: Colors.teal[400])
        ]),
      ));
}
