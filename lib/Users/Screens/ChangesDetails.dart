// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/DataBase/DataRepresentations/User.dart';
import 'package:havruta_project/Event/CreateEvent/Authenitcate.dart';
import 'package:havruta_project/HomePage.dart';

import '../../Globals.dart';
import 'package:havruta_project/Auth/Widgets/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChangesDetails extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ChangesDetails> {
  final name = TextEditingController();
  String name_str = "";
  final address = TextEditingController();
  String address_str = "";
  final yeshiva = TextEditingController();
  String yeshiva_str = " ";
  final heightcm = TextEditingController();
  String heightcm_str = " ";
  final description = TextEditingController();
  String description_str = " ";
  final status = TextEditingController();
  String? status_str = Globals.currentUser!.status;
  final AuthService authenticate = AuthService();

  DateTime _dateTime = DateTime(1940, 1, 1);

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
            imageProfile(),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "תאריך לידה   ",
                  style:
                      GoogleFonts.alef(fontSize: 18, color: Colors.teal[400]),
                )),
            SizedBox(height: Globals.scaler.getHeight(1)),
            Container(
              height: 60,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                minimumDate: DateTime(1900, 1, 1),
                initialDateTime: Globals.currentUser!.birthDate,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  _dateTime = newDateTime;
                },
              ),
            ),
            SizedBox(height: Globals.scaler.getHeight(1)),
            newFiled(name, name_str, "שם פרטי ושם משפחה", FontAwesomeIcons.user,
                3.0, Globals.currentUser!.name, TextDirection.rtl),
            newFiled(
                address,
                address_str,
                "כתובת מגורים",
                FontAwesomeIcons.house,
                3.0,
                Globals.currentUser!.address,
                TextDirection.rtl),
            SizedBox(height: Globals.scaler.getHeight(1)),
            FadeAnimation(
              1.7,
              Container(
                  alignment: AlignmentDirectional.centerEnd,
                  width: Globals.scaler.getWidth(32),
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
                    iconSize: Globals.scaler.getTextSize(11),
                    // this increase the size
                    elevation: 100,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: Globals.scaler.getTextSize(8),
                    ),
                    underline: Container(),
                    onChanged: (String? newValue) {
                      setState(() {
                        status_str = newValue;
                      });
                    },
                    items: <String>[
                      "סטטוס משפחתי",
                      "רווק/ה",
                      'נשוי/אה',
                      'גרוש/ה',
                      'אלמן/נה',
                      'לא ידוע',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                            child: Text(value, textAlign: TextAlign.center)),
                      );
                    }).toList(),
                  )),
            ),
            newFiled(yeshiva, yeshiva_str, "ישיבה/מדרשה", FontAwesomeIcons.book,
                3.0, Globals.currentUser!.yeshiva, TextDirection.rtl),
            newFiled(
                heightcm,
                heightcm_str,
                "גובה - ס\"מ",
                FontAwesomeIcons.rulerVertical,
                3.0,
                Globals.currentUser!.heightcm?.toString() ?? "",
                TextDirection.ltr,
                true),
            newFiled1(
                description,
                description_str,
                "פרטים שחשוב לך לשתף",
                FontAwesomeIcons.list,
                8.0,
                Globals.currentUser!.description,
                TextDirection.rtl),
            SizedBox(height: Globals.scaler.getHeight(1)),
            SizedBox(height: Globals.scaler.getHeight(1)),
            ElevatedButton(
              child: Text(
                "שמור שינויים",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(fontSize: 23, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize: Size(
                      Globals.scaler.getWidth(32), Globals.scaler.getHeight(3)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(38.0),
                  ),
                  backgroundColor: Colors.teal,
                  // <-- Button color
                  foregroundColor: Colors.teal),
              onPressed: () async {
                if (_dateTime == null) {
                  _dateTime = DateTime.now();
                }

                name_str = name.text;
                yeshiva_str = yeshiva.text;
                heightcm_str = heightcm.text;
                address_str = address.text;
                description_str = description.text;
                if (address_str.isEmpty ||
                    address_str == null ||
                    name_str.isEmpty ||
                    name_str == null) {
                  Flushbar(
                    title: 'שגיאה בהרשמה',
                    messageText: Text('ודא שמילאת את כל השדות',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.teal[400], fontSize: 20)),
                    duration: Duration(seconds: 3),
                  )..show(context);
                  return;
                }

                User user = Globals.currentUser!;
                user.address = address_str;
                user.name = name_str;
                user.status = status_str;
                user.yeshiva = yeshiva_str;
                user.heightcm = int.tryParse(heightcm_str.trim());
                user.description = description_str;
                user.birthDate = _dateTime;
                Globals.db!.changeDeatailsUser(user);
                // user.name = name_str;
                // user.birthDate = _dateTime;
                // Globals.currentUser = user;
                //var res = Globals.db.insertNewUser(user);
                print("change details Succeeded");

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1))
          ],
        ),
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(children: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            showModalBottomSheet(
                context: context, builder: ((builder) => bottomSheet()));
          },
          child: CircleAvatar(
            radius: 60.0,
            backgroundColor: Colors.teal,
            backgroundImage: (Globals.currentUser!.avatar != null)
                ? NetworkImage(Globals.currentUser!.avatar!)
                : null,
          ),
        ),
        Positioned(
          bottom: Globals.scaler.getHeight(2.2),
          right: Globals.scaler.getWidth(5.3),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: Globals.scaler.getTextSize(11),
            ),
          ),
        ),
      ]),
    );
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
            "בחר/י תמונה",
            style: TextStyle(
              fontSize: Globals.scaler.getTextSize(8.5),
            ),
          ),
          SizedBox(
            height: Globals.scaler.getHeight(1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () async {
                uploadImage(ImageSource.camera);
                Navigator.pop(context);
              },
              label: Text("מצלמה"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                uploadImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              label: Text("גלריה"),
            ),
          ])
        ],
      ),
    );
  }

  Future<void> uploadImage(ImageSource source) async {
    final _storage = FirebaseStorage.instance;
    XFile? image;
    final picker = ImagePicker();
    dynamic result = await authenticate.signInAnon();
    if (result == null) {
      print("error signing in");
    } else {
      print('signed in');
      print(result.uid);
    }
    image = await picker.pickImage(source: source);
    var file = File(image?.path ?? "");
    //String fileName = ObjectId().toString();
    String fileName = sha1
        .convert(utf8.encode(Globals.currentUser!.email! + "avatar"))
        .toString();
    //check if an image was picked
    if (image != null) {
      var snapshot =
          await _storage.ref().child('Images/$fileName').putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        Globals.currentUser!.avatar = downloadUrl;
      });
    } else {
      setState(() {
        Globals.currentUser!.avatar = Globals.DEFAULT_USER_AVATAR;
      });
    }
  }
}

newFiled(controller, str, text, icon, size, init,
    [TextDirection? dir, bool number = false]) {
  return new FadeAnimation(
      1.7,
      Column(children: <Widget>[
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
                textDirection: dir,
                controller: controller..text = init,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    suffixIcon: Icon(
                      icon,
                      size: Globals.scaler.getTextSize(8),
                      color: Colors.red,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: text),
                keyboardType: number ? TextInputType.number : null,
                inputFormatters: number
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                      ]
                    : null,
                onChanged: (text) {
                  str = controller.text;
                }),
          ),
        ),
      ]));
}

newFiled1(controller, str, text, icon, size, init, [TextDirection? dir]) {
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
              textDirection: dir,
              controller: controller..text = init,
              style: TextStyle(fontSize: Globals.scaler.getTextSize(7.5)),
              decoration: InputDecoration(
                  suffixIcon: Icon(
                    icon,
                    size: Globals.scaler.getTextSize(8),
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
              }),
        ),
      ),
    ]),
  );
}

button(name_str) {
  return OutlinedButton(
    style: ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    ),
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
            "עדכון פרטי משתמש  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(
                fontWeight: FontWeight.bold,
                fontSize: Globals.scaler.getTextSize(9),
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.userLarge, size: 20, color: Colors.teal[400])
        ]),
      ));
}
