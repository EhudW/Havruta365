import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'package:havruta_project/Globals.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'arc_banner_image.dart';
import 'poster.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDetailHeader extends StatelessWidget {
  UserDetailHeader(User user) {
    this.user = user;
  }

  User user;


  @override
  Widget build(BuildContext context) {
    var textTheme = Theme
        .of(context)
        .textTheme;

    var userInformation = Align(
      alignment: AlignmentDirectional.center,
      child: Text(
        user.name,
        style: GoogleFonts.alef(fontSize: 32,
            textStyle: TextStyle(color: Colors.teal, letterSpacing: 2),
        fontWeight: FontWeight.bold),
        textAlign: TextAlign.center
      ),
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 170.0),
          child: ArcBannerImage(
              "https://static.vecteezy.com/system/resources/previews/001/816/806/non_2x/stack-of-books-on-nature-background-free-photo.jpg"),
        ),
        Positioned(
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //SizedBox(width: 16.0),
              Center(
                child: CircleAvatar(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatar),
                    radius: 80.0,
                  ),
                  backgroundColor: Colors.white,
                  radius: 85.0,
                ),
              ),
              Column(
                children: [
                  userInformation,
                  Text(user.description,
                      style: GoogleFonts.alef(fontSize: 20),
                      textDirection: TextDirection.rtl)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
