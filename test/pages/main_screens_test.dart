import 'package:firebase_auth/firebase_auth.dart' as auth_firebase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/pages/account_page.dart';
import 'package:progetto/pages/friends_page.dart';
import 'package:progetto/pages/home_page.dart';
import 'package:progetto/pages/main_screens.dart';
import 'package:progetto/pages/search_page.dart';

@GenerateNiceMocks([
  MockSpec<Database>(),
  MockSpec<Auth>(),
  MockSpec<Storage>(),
  MockSpec<auth_firebase.User>()
])
import 'main_screens_test.mocks.dart';

main() {
  late Auth auth;
  late auth_firebase.User curUser;

  setUp(() {
    auth = MockAuth();
    curUser = MockUser();

    when(auth.currentUser).thenReturn(curUser);
  });

  testWidgets('Main screens', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return MainScreens(
              database: MockDatabase(), auth: auth, storage: MockStorage());
        }))));

    final homePageFinder = find.byWidgetPredicate((widget) => widget is HomePage);
    final searchPageFinder = find.byWidgetPredicate((widget) => widget is SearchPage);
    final friendsPageFinder = find.byWidgetPredicate((widget) => widget is FriendsPage);
    final accountPageFinder = find.byWidgetPredicate((widget) => widget is AccountPage);
    final searchPageButton = find.byIcon(Icons.search);
    final friendsPageButton = find.byIcon(Icons.people);
    final accountPageButton = find.byIcon(Icons.person);

    expect(homePageFinder, findsOneWidget);
    await tester.tap(searchPageButton);
    await tester.pumpAndSettle();
    expect(searchPageFinder, findsOneWidget);
    await tester.tap(friendsPageButton);
    await tester.pumpAndSettle();
    expect(friendsPageFinder, findsOneWidget);
    await tester.tap(accountPageButton);
    await tester.pump(const Duration(seconds: 2));
    expect(accountPageFinder, findsOneWidget);
  });
}
