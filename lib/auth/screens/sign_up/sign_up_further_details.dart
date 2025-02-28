import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/event/create_event/authenitcate.dart';
import 'package:havruta_project/home_page.dart';
import 'package:image_picker/image_picker.dart';

import '../../../globals.dart';
import 'package:havruta_project/auth/widgets/fade_animation.dart';
import 'package:flutter/material.dart';

// this is the step 2 of signup for "with google" or "email-pass"
class SignUpFurtherDetails extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<SignUpFurtherDetails> {
  final yeshiva = TextEditingController();
  String yeshivaStr = " ";
  final heightcm = TextEditingController();
  String heightCmStr = "";
  final description = TextEditingController();
  String descriptionStr = " ";
  final status = TextEditingController();
  String? statusStr = "סטטוס משפחתי";
  final AuthService authenticate = AuthService();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          backgroundColor: Colors.teal[100],
          appBar: appBar(context),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: Globals.scaler.getHeight(1)),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "פרטים נוספים   ",
                      style: GoogleFonts.alef(
                          fontSize: Globals.scaler.getTextSize(8),
                          color: Colors.teal[400]),
                    )),
                imageProfile(),
                SizedBox(height: Globals.scaler.getHeight(1)),
                FadeAnimation(
                  1.7,
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
                        value: statusStr,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: Globals.scaler.getTextSize(9),
                        // this increase the size
                        elevation: 100,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: Globals.scaler.getTextSize(8),
                        ),
                        underline: Container(),
                        onChanged: (String? newValue) {
                          setState(() {
                            statusStr = newValue;
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
                                child:
                                    Text(value, textAlign: TextAlign.center)),
                          );
                        }).toList(),
                      )),
                ),
                newFiled(yeshiva, yeshivaStr, "ישיבה/מדרשה",
                    FontAwesomeIcons.book, 3.0, TextDirection.rtl),
                newFiled(
                    heightcm,
                    heightCmStr,
                    "גובה - ס\"מ",
                    FontAwesomeIcons.rulerVertical,
                    3.0,
                    TextDirection.ltr,
                    true),
                newFiled1(description, descriptionStr, "פרטים שחשוב לך לשתף",
                    FontAwesomeIcons.list, 8.0, TextDirection.rtl),
                SizedBox(height: Globals.scaler.getHeight(1)),
                ElevatedButton(
                  child: Text(
                    "מצא לי חברותא ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abel(
                        fontSize: Globals.scaler.getTextSize(9),
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      minimumSize: Size(Globals.scaler.getWidth(32),
                          Globals.scaler.getHeight(3)),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(38.0),
                      ),
                      backgroundColor: Colors.red,
                      // <-- Button color
                      foregroundColor: Colors.teal),
                  onPressed: () async {
                    // tmpNextUser is from step 1 of signup (this screen is step 2 and last)
                    Globals.currentUser = Globals.tmpNextUser;

                    await Globals.db!.insertNewUser(Globals.currentUser!);
                    await Globals.db!.saveIdLocally();
                    yeshivaStr = yeshiva.text;
                    heightCmStr = heightcm.text;
                    descriptionStr = description.text;
                    Globals.currentUser!.yeshiva = yeshivaStr;
                    Globals.currentUser!.heightcm =
                        int.tryParse(heightCmStr.trim());
                    Globals.currentUser!.description = descriptionStr;
                    Globals.currentUser!.status =
                        statusStr == "סטטוס משפחתי" ? "לא ידוע" : statusStr;
                    if (Globals.currentUser!.avatar == null)
                      Globals.currentUser!.avatar = Globals.DEFAULT_USER_AVATAR;
                    await Globals.db!.updateUser(Globals.currentUser!);
                    Globals.onNewLogin(Globals.currentUser!);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        Globals.tmpNextUser = null;
                        return HomePage();
                      }),
                    );
                  },
                ),
                SizedBox(height: Globals.scaler.getHeight(1)),
              ],
            ),
          ),
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
            backgroundImage: (Globals.tmpNextUser?.avatar != null)
                ? NetworkImage(Globals.tmpNextUser!.avatar!)
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
    }
    image = await picker.pickImage(source: source);
    var file = File(image?.path ?? "");
    // fileName will be the same for same user's avatar
    String fileName = sha1
        .convert(utf8.encode(Globals.tmpNextUser!.email! + "avatar"))
        .toString();
    //check if an image was picked
    if (image != null) {
      var snapshot =
          await _storage.ref().child('Images/$fileName').putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        Globals.tmpNextUser!.avatar = downloadUrl;
      });
    } else {
      /*setState(() {
        Globals.tmpNextUser!.avatar =
            Globals.DEFAULT_USER_AVATAR;
      });*/
    }
  }
}

newFiled(controller, str, text, icon, size,
    [TextDirection? dir, bool number = false]) {
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
              textDirection: dir,
              controller: controller,
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
    ]),
  );
}

newFiled1(controller, str, text, icon, size, [TextDirection? dir]) {
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
              controller: controller,
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

appBar(BuildContext context) {
  ScreenScaler scaler = new ScreenScaler();
  return new AppBar(
      leadingWidth: 0,
      toolbarHeight: Globals.scaler.getHeight(2),
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
          Icon(FontAwesomeIcons.userLarge,
              size: Globals.scaler.getTextSize(9), color: Colors.teal[400])
        ]),
      ));
}
