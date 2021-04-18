import 'package:flutter/material.dart';

class Storyline extends StatelessWidget {
  Storyline(this.storyline);
  final String storyline;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'תיאור',
          style: textTheme.subhead.copyWith(fontSize: 18.0),
        ),
        SizedBox(height: 2.0),
        Text(
          storyline,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: textTheme.body1.copyWith(
            color: Colors.black45,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
