import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/mongo.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('הרשמה'),
          centerTitle: true,
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter a name'),
            ),
            TextField(
              controller: mailController,
              decoration: InputDecoration(hintText: 'Enter a mail'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: 'Enter a password'),
            ),
            FloatingActionButton(
              onPressed: () {
                // // create JSON file with the details
                // Map<String, dynamic> user = {"name": nameController.text,
                // "email": mailController.text, "password": passwordController.text};
                // Mongo mongo = new Mongo();
                // mongo.insertNewUser({"name": nameController.text,
                //   "email": mailController.text, "password": passwordController.text});
                // Navigator.of(context).pushNamed('/homeScreen');
              },
            )
          ],
        ));
  }
}
