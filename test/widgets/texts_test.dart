import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:havruta_project/widgets/texts.dart';

void main() {
  group('shortenStr', () {
    test('shortenStr should shorten a string correctly', () {
      // Arrange
      final input1 = 'This is a long string';
      final input2 = 'Short';
      final input3 = 'Another example';
      final expected1 = 'This is a long ...';
      final expected2 = 'Short';
      final expected3 = 'Another example';

      // Act
      final result1 = shortenStr(input1);
      final result2 = shortenStr(input2);
      final result3 = shortenStr(input3);

      // Assert
      // The default shortenStr length is 15
      expect(result1, equals(expected1));
      expect(result2, equals(expected2));
      expect(result3, equals(expected3));
    });

    test(
        'shortenStr should not modify a string if its length is equal to or less than the specified length',
        () {
      // Arrange
      final input1 = 'Hello';
      final input2 = 'World';
      final input3 = '';
      final expected1 = 'Hello';
      final expected2 = 'World';
      final expected3 = '';

      // Act
      final result1 = shortenStr(input1);
      final result2 = shortenStr(input2);
      final result3 = shortenStr(input3);

      // Assert
      expect(result1, equals(expected1));
      expect(result2, equals(expected2));
      expect(result3, equals(expected3));
    });

    test('shortenStr should respect the specified length parameter', () {
      // Arrange
      final input1 = 'This is a long string';
      final input2 = 'Short';
      final input3 = 'Another example';
      final length = 10;
      final expected1 = 'This is a ...';
      final expected2 = 'Short';
      final expected3 = 'Another ex...';

      // Act
      final result1 = shortenStr(input1, length: length);
      final result2 = shortenStr(input2, length: length);
      final result3 = shortenStr(input3, length: length);

      // Assert
      expect(result1, equals(expected1));
      expect(result2, equals(expected2));
      expect(result3, equals(expected3));
    });
  });

  group('splitStr', () {
    test(
        'splitStr should split words longer than the specified length parameter',
        () {
      // Arrange
      final input =
          'This is a long string with some verylongwordthatneedstobesplit';
      final length = 10;
      final expected =
          'This is a long string with some verylongwo\nrdthatneed\nstobesplit ';

      // Act
      final result = splitStr(input, splitEveryWordLongerThan: length);

      // Assert
      expect(result, equals(expected));
    });

    test(
        'splitStr should not split words shorter than or equal to the specified length parameter',
        () {
      // Arrange
      final input = 'This is a short string';
      final length = 10;
      final expected = 'This is a short string ';

      // Act
      final result = splitStr(input, splitEveryWordLongerThan: length);

      // Assert
      expect(result, equals(expected));
    });
  });

  testWidgets(
      'strToSmallGreyHeader should create a Padding widget with the correct properties',
      (WidgetTester tester) async {
    // Arrange
    final str = 'Header';

    // Act
    final widget = strToSmallGreyHeader(str);

    // Assert
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final paddingWidgetFinder = find.byType(Padding);
    expect(paddingWidgetFinder, findsOneWidget);

    final paddingWidget = tester.widget<Padding>(paddingWidgetFinder);
    expect(paddingWidget.padding, equals(EdgeInsets.only(right: 10)));

    final textWidgetFinder = find.text(str);
    expect(textWidgetFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textWidgetFinder);
    expect(textWidget.textAlign, equals(TextAlign.right));
    expect(textWidget.style!.fontSize, equals(15.0));
    expect(textWidget.style!.color, equals(Colors.grey[700]));
  });

  testWidgets(
      'strToContent should create a Padding widget with the correct properties',
      (WidgetTester tester) async {
    // Arrange
    final str = 'Content';
    final style = TextStyle(fontSize: 20.0, color: Colors.blue);

    // Act
    final widget = strToContent(str, style);

    // Assert
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final paddingWidgetFinder = find.byType(Padding);
    expect(paddingWidgetFinder, findsOneWidget);

    final paddingWidget = tester.widget<Padding>(paddingWidgetFinder);
    expect(paddingWidget.padding, equals(EdgeInsets.only(right: 10)));

    final textWidgetFinder = find.text(str);
    expect(textWidgetFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textWidgetFinder);
    expect(textWidget.style!.fontSize, equals(20.0));
    expect(textWidget.style!.color, equals(Colors.blue));
    expect(textWidget.textAlign, equals(TextAlign.right));
  });

  testWidgets(
      'createTwoLinesField should create a Column widget with the correct children',
      (WidgetTester tester) async {
    // Arrange
    final header = 'Header';
    final content = 'Content';

    // Act
    final widget = createTwoLinesField(header, content);

    // Assert
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final columnWidgetFinder = find.byType(Column);
    expect(columnWidgetFinder, findsOneWidget);

    final columnWidget = tester.widget<Column>(columnWidgetFinder);
    expect(columnWidget.crossAxisAlignment, equals(CrossAxisAlignment.end));

    final smallGreyHeaderFinder = find.text(header);
    expect(smallGreyHeaderFinder, findsOneWidget);

    final contentFinder = find.text(content);
    expect(contentFinder, findsOneWidget);
  });

  group('conditionalTwoLinesFieldCreation', () {
    testWidgets(
        'conditionalTwoLinesFieldCreation should create a Container widget if content is empty',
        (WidgetTester tester) async {
      // Arrange
      final header = 'Header';
      final content = '';

      // Act
      final widget = conditionalTwoLinesFieldCreation(header, content);

      // Assert
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
    });

    testWidgets(
        'conditionalTwoLinesFieldCreation should create a Column widget with the correct children if content is not empty',
        (WidgetTester tester) async {
      // Arrange
      final header = 'Header';
      final content = 'Content';

      // Act
      final widget = conditionalTwoLinesFieldCreation(header, content);

      // Assert
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final columnWidgetFinder = find.byType(Column);
      expect(columnWidgetFinder, findsOneWidget);

      final columnWidget = tester.widget<Column>(columnWidgetFinder);
      expect(columnWidget.crossAxisAlignment, equals(CrossAxisAlignment.end));

      final smallGreyHeaderFinder = find.text(header);
      expect(smallGreyHeaderFinder, findsOneWidget);

      final contentFinder = find.text(content);
      expect(contentFinder, findsOneWidget);
    });
  });
}
