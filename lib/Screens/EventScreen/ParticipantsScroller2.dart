import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/Globals.dart';
import 'package:havruta_project/Screens/ChatScreen/Chat1v1.dart';
import 'package:havruta_project/Screens/ChatScreen/SendScreen.dart';
import 'package:havruta_project/Screens/UserScreen/UserScreen.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart' hide Center;
import 'dart:ui' as ui;

class ParticipentsScroller2 extends StatefulWidget {
  ParticipentsScroller2({Key? key, required this.eventId}) : super(key: key);
  final String eventId;

  @override
  _ParticipentsScroller2State createState() => _ParticipentsScroller2State();
}

class _ParticipentsScroller2State extends State<ParticipentsScroller2> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
