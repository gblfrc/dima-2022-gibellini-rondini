import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/pages/create_goal_page.dart';

@GenerateNiceMocks([MockSpec<Database>(), MockSpec<Auth>()])
import 'create_goal_page_test.mocks.dart';

main() {
  testWidgets('Create Goal Page', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return Scaffold(body: CreateGoalPage(database: MockDatabase(), auth: MockAuth()));
        }))));
    final pageFinder = find.byWidgetPredicate((widget) => widget is CreateGoalPage);
    expect(pageFinder, findsOneWidget);
  });
}
