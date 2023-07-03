import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'package:havruta_project/globals.dart';

var sizeHeader = Globals.scaler.getTextSize(8);
var sizeField = Globals.scaler.getTextSize(8);

String shortenStr(String str, {int length = 15}) {
  return str.length > length ? str.substring(0, length) + '...' : str;
}

String splitStr(String str, {int splitEveryWordLongerThan = 30}) {
  var words = str.split(' ');
  var newStr = '';
  for (var word in words) {
    if (word.length <= splitEveryWordLongerThan) {
      newStr += word + ' ';
    } else {
      while (word.length > splitEveryWordLongerThan) {
        newStr += word.substring(0, splitEveryWordLongerThan) + '\n';
        word = word.substring(splitEveryWordLongerThan);
      }
      newStr += word + ' ';
    }
  }
  return newStr;
}

Text strToText(String str,
    {double fontSize = 20.0,
    style = GoogleFonts.secularOne,
    TextAlign textAlign = TextAlign.center}) {
  if (style == GoogleFonts.secularOne)
    style = GoogleFonts.alef(fontSize: fontSize, color: Colors.grey[700]);

  return Text(
    str,
    style: style,
    textAlign: textAlign,
    textDirection: ui.TextDirection.rtl,
  );
}

Widget strToScalerText(String str, ScreenScaler scaler, {double scale = 7.5}) {
  return Text(
    str,
    // textDirection: TextDirection.RTL,
    textAlign: TextAlign.center,
    style: TextStyle(
        fontSize: scaler.getTextSize(scale), fontWeight: FontWeight.bold),
  );
}

Widget strToSmallGreyHeader(String str) {
  return Padding(
      padding: EdgeInsets.only(right: 10),
      child: strToText(str,
          textAlign: TextAlign.right,
          style: GoogleFonts.alef(fontSize: 15.0, color: Colors.grey[700])));
}

Widget strToBoldHeader(String str) {
  return Text(str,
      style: GoogleFonts.alef(fontSize: sizeHeader),
      textDirection: TextDirection.rtl);
}

Widget strToContent(String str, style) {
  return Padding(
      padding: EdgeInsets.only(right: 10),
      child: strToText(str, style: style, textAlign: TextAlign.right));
}

Widget createTwoLinesField(String header, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      strToSmallGreyHeader(header),
      strToContent(content, GoogleFonts.secularOne(fontSize: 18.0)),
    ],
  );
}

Widget conditionalTwoLinesFieldCreation(String header, String content) {
  return content == '' ? Container() : createTwoLinesField(header, content);
}

Widget createShortRow(Widget icon, String field) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      Flexible(
          child: strToText(splitStr(field, splitEveryWordLongerThan: 30),
              style: GoogleFonts.alef(
                  fontSize: sizeField, fontWeight: FontWeight.bold))),
      SizedBox(width: Globals.scaler.getWidth(0.5)),
      icon,
    ],
  );
}

Widget createLongRow(Widget icon, String header, String field) =>
    Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Flexible(
          child: strToText(field,
              style: GoogleFonts.alef(
                  fontSize: sizeField, fontWeight: FontWeight.bold))),
      SizedBox(width: Globals.scaler.getWidth(0.5)),
      strToBoldHeader(header),
      SizedBox(width: Globals.scaler.getWidth(0.5)),
      icon,
    ]);
