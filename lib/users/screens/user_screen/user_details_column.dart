// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/widgets/texts.dart';

class UserDetailsColumn extends StatelessWidget {
  UserDetailsColumn(this.user);

  final User? user;

  gender() {
    if (user!.gender == 'M') {
      return "גבר";
    }
    return "אשה";
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;

    var icon_to_widget = (IconData icon) => Icon(
          icon,
          size: 26.0,
          color: Colors.grey[600],
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          createLongRow(icon_to_widget(FontAwesomeIcons.userGraduate), "למד ב-",
              user!.yeshiva!),
          SizedBox(height: 15.0),
          createLongRow(icon_to_widget(FontAwesomeIcons.locationDot), "גר ב-",
              user!.address!),
          SizedBox(height: 15.0),
          createShortRow(icon_to_widget(FontAwesomeIcons.restroom), gender()),
          SizedBox(height: 15.0),
          createShortRow(icon_to_widget(FontAwesomeIcons.calendarDay),
              "בגיל " + user!.age.toString()),
          user!.heightcm != null ? SizedBox(height: 15.0) : SizedBox(),
          user!.heightcm != null
              ? createLongRow(icon_to_widget(FontAwesomeIcons.rulerVertical),
                  "גובה - ס\"מ", user!.heightcm!.toString())
              : SizedBox(),
          SizedBox(height: 15.0),
          createShortRow(icon_to_widget(FontAwesomeIcons.heart), user!.status!),
          SizedBox(height: 15.0),
          createShortRow(
              icon_to_widget(FontAwesomeIcons.circleInfo), user!.description!),
        ],
      ),
    );
  }
}
