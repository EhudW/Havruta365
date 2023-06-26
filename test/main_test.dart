import 'package:flutter_test/flutter_test.dart';
import 'package:havruta_project/data_base/mongo_commands.dart';
import 'package:havruta_project/mydebug.dart';

import 'clone.dart';
import 'json.dart';
import 'recommendation_sys.dart';
// dont end file name with _test

// make warning if rslt not match m
// it won't stop the test, only alert, to stop use expect instead
//     the idea is to avoid calling 'except',
//     which when 'reason' != null => x not match m => stop test
//     'skip' is String / true => will skip even if x match m
// the third param in this function HERE called 'reason'
//     so it easy to change between alert and except
//
// has to be within test() / testWidget()
void alert(dynamic x, Matcher m, {required dynamic reason}) =>
    m.matches(x, {}) ? null : expect(x, m, skip: reason);

void main() async {
  // any function (assume named 'func') that use db here should be awaited,
  //and the func should await the func with th db
  // otherwise main() will end & db.disconnect before the func(the part with db) ends
  // so notice when using test testWidget as you can't just do normal  await test(...) in func
  var db = MongoCommands();
  myPrintTypes = {};
  print('connect to mongodb...');
  await db.connect();

  // test that Event/Chats...  .fromJson .toJson works fine
  await testAllJsons(db: db);

  // test default rec system at ExampleRecommendationSystem class
  testRecSys(skipCollaborativeCheck: false);
  /* 
  // test specif rec system,
  // in this case test the testRecSys since we give OppositeRecommendationSystem()
  testRecSys(
      timesToCheck: 1,
      testThisSystem: (k) =>
          OppositeRecommendationSystem(MultiConsiderations()));
  */

  // test .deepClone() and similar functions work well
  await testClones(db);

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

  print('disconnect from mongodb...');
  await db.disconnect();
}
