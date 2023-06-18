// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Storyline extends StatelessWidget {
  Storyline(this.storyline, this.icon);
  final String? storyline;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              storyline!.trim() != "" ? '  תיאור:' : "",
              textDirection: TextDirection.rtl,
              style: GoogleFonts.secularOne(fontSize: 20.0),
            ),
            Icon(
              icon,
              color: Colors.green[900],
            ),
          ],
        ),
        SizedBox(height: 2.0),
        Text(
          storyline!.trim(),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
