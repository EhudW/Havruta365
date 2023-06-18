//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/globals.dart';
import '../user_screen/user_screen.dart';
import '../../widgets/arc_banner_image.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ProfileDetailHeader extends StatelessWidget {
  ProfileDetailHeader(User? user) {
    this.user = user;
  }

  User? user;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var textTheme = Theme.of(context).textTheme;

    var userInformation = Align(
        alignment: AlignmentDirectional.center,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserScreen(user!.email)),
            );
          },
          child: Column(children: [
            Text(user!.name!,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.alef(
                    fontSize: Globals.scaler.getTextSize(10),
                    textStyle: TextStyle(color: Colors.teal, letterSpacing: 2),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            Text(user!.email!,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.alef(
                    fontSize: Globals.scaler.getTextSize(7),
                    textStyle:
                        TextStyle(color: Colors.teal[600], letterSpacing: 1),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)
          ]),
        ));

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Globals.scaler.getHeight(8)),
          child: ArcBannerImage(
              "https://static.vecteezy.com/system/resources/previews/001/816/806/non_2x/stack-of-books-on-nature-background-free-photo.jpg"),
        ),
        Positioned(
          bottom: Globals.scaler.getHeight(0),
          left: Globals.scaler.getWidth(0),
          right: Globals.scaler.getWidth(0),
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
                    child: IconButton(
                        icon: Icon(Icons.quiz_sharp),
                        iconSize: 60.0,
                        color: Colors.white.withOpacity(0),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserScreen(user!.email)),
                          );
                        }),
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
