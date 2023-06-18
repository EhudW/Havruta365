// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/QQQglobals.dart';

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
    var size_field = Globals.scaler.getTextSize(8);
    var size_header = Globals.scaler.getTextSize(8);

    var split_str = (String str, int split_every_word_longer_than) {
      var words = str.split(' ');
      var new_str = '';
      for (var word in words) {
        if (word.length <= split_every_word_longer_than) {
          new_str += word + ' ';
        } else {
          while (word.length > split_every_word_longer_than) {
            new_str += word.substring(0, split_every_word_longer_than) + '\n';
            word = word.substring(split_every_word_longer_than);
          }
          new_str += word + ' ';
        }
      }
      return new_str;
    };

    var shorten_str = (String str, int length) =>
        str.length > length ? str.substring(0, length) + '...' : str;

    var str_to_header = (String str, double font_size) => Text(str,
        style: GoogleFonts.alef(fontSize: size_header),
        textDirection: TextDirection.rtl);

    var str_to_field = (String str) => Text(str,
        style:
            GoogleFonts.alef(fontSize: size_field, fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl);

    var icon_to_widget = (IconData icon) => Icon(
          icon,
          size: 26.0,
          color: Colors.grey[600],
        );

    var create_long_row = (IconData icon, String header, String field) =>
        Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          str_to_field(shorten_str(field, 26 - header.length)),
          SizedBox(width: Globals.scaler.getWidth(0.5)),
          str_to_header(header, size_header),
          SizedBox(width: Globals.scaler.getWidth(0.5)),
          icon_to_widget(icon),
        ]);

    var create_short_row = (IconData icon, String field) => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            str_to_field(split_str(field, 30)),
            SizedBox(width: Globals.scaler.getWidth(0.5)),
            icon_to_widget(icon),
          ],
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          create_long_row(
              FontAwesomeIcons.userGraduate, "למד ב-", user!.yeshiva!),
          SizedBox(height: 15.0),
          create_long_row(
              FontAwesomeIcons.locationDot, "גר ב-", user!.address!),
          SizedBox(height: 15.0),
          create_short_row(FontAwesomeIcons.restroom, gender()),
          SizedBox(height: 15.0),
          create_short_row(
              FontAwesomeIcons.calendarDay, "בגיל " + user!.age.toString()),
          user!.heightcm != null ? SizedBox(height: 15.0) : SizedBox(),
          user!.heightcm != null
              ? create_long_row(FontAwesomeIcons.rulerVertical, "גובה - ס\"מ",
                  user!.heightcm!.toString())
              : SizedBox(),
          SizedBox(height: 15.0),
          create_short_row(FontAwesomeIcons.heart, user!.status!),
          SizedBox(height: 15.0),
          create_short_row(FontAwesomeIcons.circleInfo, user!.description!),
        ],
      ),
    );
  }
}
