import 'package:flutter/material.dart';

class MyData {
  List<DropdownMenuItem<String>> topicsDrop = [];
  List<String> topics = [
    "תורה",
    "נ״ך",
    "תלמוד בבלי",
    "תלמוד ירושלמי",
    " הלכה",
    " מחשבה"
  ];
  String selectedTopic;
  String selectedBook;
  List<DropdownMenuItem<String>> booksDrop = [];
  List<String> humashBooks = [
    "בראשית",
    "שמות",
    "ויקרא",
    "במדבר",
    "דברים",
  ];

  List<String> nachBooks = [
    "יהושוע",
    "שופטים",
    "שמואל א ",
    "שמואל ב",
    "מלכים",
  ];

  List<String> talmudBavliBooks = [
    "ברכות",
    "שבת",
    "עירובין",
    "פסחים",
    "שקלים",
  ];

  List<String> talmudYerushalmiBooks = [
    "ברכות",
    "פאה",
    "דמאי",
    "כלאים",
    "שביעית",
  ];

  List<String> halachaBooks = [
    "שולחן ערוך",
    "משנה ברורה",
    "קיצור שלחן ערוך",
    "רמב״ם",
    "פניני הלכה",
  ];

  List<String> howOften = [
    "יומי",
    "שבועי",
    "פעמיים בשבוע",
    "חודשי",
  ];

  List<String> gender = [
    "גברים",
    "נשים",
    "לא משנה",
  ];

  List<String> choice = ["שיעור", "חברותא"];
}
