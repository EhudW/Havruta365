// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Storyline extends StatelessWidget {
  Storyline(this.storyline);
  final String? storyline;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'תיאור',
          style: GoogleFonts.secularOne(fontSize: 20.0),
        ),
        SizedBox(height: 2.0),
        Text(
          storyline!,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
