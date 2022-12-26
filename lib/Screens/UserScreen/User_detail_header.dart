//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';
import 'arc_banner_image.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class UserDetailHeader extends StatelessWidget {
  UserDetailHeader(User? user) {
    this.user = user;
  }

  User? user;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var textTheme = Theme.of(context).textTheme;

    var userInformation = Align(
      alignment: AlignmentDirectional.center,
      child: Text(user!.name!,
          style: GoogleFonts.alef(
              fontSize: 32,
              textStyle: TextStyle(color: Colors.teal, letterSpacing: 2),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
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
                    backgroundImage: NetworkImage(user!.avatar!),
                    radius: 80.0,
                  ),
                  backgroundColor: Colors.white,
                  radius: 85.0,
                ),
              ),
              Column(
                children: [
                  userInformation,
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
