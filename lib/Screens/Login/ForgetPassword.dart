import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/smtp_server.dart';

import '../../Globals.dart';
import 'FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:toast/toast.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ForgetPassword> {
  final address = TextEditingController();
  String address_str = "";


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
            SizedBox(height: Globals.scaler.getHeight(4)),
            newFiled(address, address_str, "כתובת המייל",
                FontAwesomeIcons.mailBulk, false),
            SizedBox(height: Globals.scaler.getHeight(2)),
            ElevatedButton(
              child: Text(
                "שלח את הסיסמא",
                textAlign: TextAlign.center,
                style: GoogleFonts.abel(fontSize: Globals.scaler.getTextSize(8), color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize:
                  Size(Globals.scaler.getWidth(32), Globals.scaler.getHeight(3)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(38.0),
                  ),
                  primary: Colors.teal,
                  // <-- Button color
                  onPrimary: Colors.teal),
              onPressed: () async {
                address_str = address.text;
                print(address_str);
                bool check = await Globals.db.isUserExist(address_str);
                if (check == true){
                  print(address_str);
                  sendMail1(address_str);
                }
                else{
                  Toast.show('כתובת המייל לא נמצאה', context,duration: Toast.CENTER,gravity: 3);
                }

              },
            ),
            SizedBox(height: Globals.scaler.getHeight(1))
          ],
        ),
      ),
    );
  }
}

newFiled(controller, str, text, icon, cover) {
  return new  FadeAnimation(
      1.7, Column(children: <Widget>[
    SizedBox(height: Globals.scaler.getHeight(1)),
    Center(
      child: Container(
        alignment: AlignmentDirectional.center,
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
        child: TextField(
            textAlign: TextAlign.center,
            controller: controller,
            obscureText: cover,
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
            onChanged: (text) {
              str = controller.text;
              print(text);
            }),
      ),
    ),
  ]));
}

sendMail(BuildContext context, String mailUser ) async {
  String username = 'havrutaproject@gmail.com';
  String password = 'havruta365'; //passsword


  final smtpServer = gmail(username, password);

  // Creating the Gmail server

  // Create our email message.
  final message = new Message()
    ..from = new Address(username, 'Your name')
    ..recipients.add(mailUser)
    ..subject = 'Test Dart Mailer library :: 😀 :: ${new DateTime.now()}'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.';

  try {
    final sendReport = await send(message, smtpServer);
    Toast.show('Message Send Check your mail', context,duration: Toast.CENTER,gravity: 3);
    print('Message sent: ' +
        sendReport.toString()); //print if the email is sent
  } on MailerException catch (e) {
    print('Message not sent. \n' +
        e.toString()); //print if the email is not sent
    // e.toString() will show why the email is not sending
  }
}
sendMail1(String mailUser) async {

  String username = 'havrutaproject@gmail.com';
  String password = 'havruta365';
  String domainSmtp = 'gmail.com';

  //also use for gmail smtp
  //final smtpServer = gmail(username, password);

  //user for your own domain
  final smtpServer = SmtpServer(
      domainSmtp, username: username, password: password, port: 587);

  final message = Message()
    ..from = Address(username, 'Your name')
    ..recipients.add(mailUser)
  //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
  //..bccRecipients.add(Address('bccAddress@example.com'))
    ..subject = 'Dart Mailer library :: 😀 :: ${DateTime.now()}'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<h1>Shawon</h1>\n<p>Hey! Here's some HTML content</p>";

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
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
            "שחזור סיסמא  ",
            textAlign: TextAlign.center,
            style: GoogleFonts.alef(
                fontWeight: FontWeight.bold,
                fontSize: Globals.scaler.getTextSize(9),
                color: Colors.teal[400]),
          ),
          Icon(FontAwesomeIcons.key, size: Globals.scaler.getTextSize(8), color: Colors.teal[400])
        ]),
      ));
}
