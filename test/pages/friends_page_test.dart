import 'package:firebase_auth/firebase_auth.dart' as auth_firebase;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/pages/friends_page.dart';

@GenerateNiceMocks([
  MockSpec<Database>(),
  MockSpec<Auth>(),
  MockSpec<Storage>(),
  MockSpec<auth_firebase.User>()
])
import 'friends_page_test.mocks.dart';

main() {
  late MockDatabase database;
  late Auth auth;
  late auth_firebase.User curUser;
  late Widget widget;

  setUp(() {
    database = MockDatabase();
    auth = MockAuth();
    curUser = MockUser();
    widget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return Scaffold(
              body: FriendsPage(
            database: database,
            auth: auth,
            storage: MockStorage(),
          ));
        })));
    when(auth.currentUser).thenReturn(curUser);
  });

  group('Friends page - No data', () {
    setUp(() {
      when(database.getFriendProposalsAfterTimestamp(curUser.uid,
              after: anyNamed("after")))
          .thenAnswer((realInvocation) async {
        return [];
      });

      when(database.getFriends(curUser.uid)).thenAnswer((realInvocation) {
        print("CALLED");
        return Stream.fromIterable([[]]);
      });
    });

    testWidgets('Friends page - No proposals', (tester) async {
      await tester.pumpWidget(widget);

      final noProposalsTextFinder = find.text(
          'There are no proposals made by people that have added you to their friends.');

      await tester.pumpAndSettle();
      expect(noProposalsTextFinder, findsOneWidget);
    });

  //   testWidgets('Friends page - No friends', (tester) async {
  //     await tester.pumpWidget(widget);
  //
  //     final friendsTabFinder = find.byKey(const Key('FriendsTab'));
  //     final noFriendsTextFinder = find.text(
  //         'You haven\'t added any friends yet.', skipOffstage: false);
  //
  //     await tester.pumpAndSettle();
  //     await tester.tap(friendsTabFinder);
  //     await tester.pump(Duration(seconds: 2));
  //     //await tester.ensureVisible(noFriendsTextFinder);
  //     debugDumpApp();
  //     expect(noFriendsTextFinder, findsOneWidget);
  //   });
  });

  group('Friends page - Data', () { });
}
