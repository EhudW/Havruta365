// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'json.dart';
import 'recommendation_sys.dart';
// dont end file name with _test

void main() async {
  // test that Event/Chats...  .fromJson .toJson works fine
  await testAllJsons(['Events', 'Topics ', 'Users', 'Chats', 'Notifications']);
  // test default rec system at ExampleRecommendationSystem class
  testRecSys();
  /* 
  // test specif rec system,
  // in this case test the testRecSys since we give OppositeRecommendationSystem()
  testRecSys(
      timesToCheck: 1,
      testThisSystem: (k) =>
          OppositeRecommendationSystem(MultiConsiderations()));
  */

  test('Null Test', () async => null);
  /*testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });*/
}
