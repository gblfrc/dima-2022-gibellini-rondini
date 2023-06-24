import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth_firebase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/cards.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/goal.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/pages/home_page.dart';

@GenerateNiceMocks([
  MockSpec<Database>(),
  MockSpec<Auth>(),
  MockSpec<Storage>(),
  MockSpec<auth_firebase.User>()
])
import 'home_page_test.mocks.dart';

main() {
  late MockDatabase database;
  late Auth auth;
  late auth_firebase.User curUser;
  User user = User(uid: "xcvb", name: "Mario", surname: "Rossi");
  Place place = Place(
      id: "qwerty",
      name: "Parco Suardi",
      coords: LatLng(45.9532, 9.420429),
      type: "park");
  late Widget widget;

  setUp(() {
    database = MockDatabase();
    auth = MockAuth();
    curUser = MockUser();

    widget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return Scaffold(
              body: HomePage(
                database: database,
                auth: auth,
                storage: MockStorage(),
              ));
        })));

    when(auth.currentUser).thenReturn(curUser);
  });

  group('Home page - With Data', () {
    setUp(() {
      when(database.getProposalsWithinInterval(curUser.uid,
              after: anyNamed("after"), before: anyNamed("before")))
          .thenAnswer((realInvocation) {
        return Stream.fromIterable([
          [
            Proposal(
                dateTime: DateTime(2023, 6, 15, 15, 40, 43),
                owner: user,
                place: place,
                type: 'Public',
                participants: [])
          ]
        ]);
      });
      when(database.getLatestSessionsByUser(curUser.uid, limit: 2))
          .thenAnswer((realInvocation) {
        return Stream.fromIterable([
          [
            Session(
                id: "abcd",
                distance: 3419.99,
                duration: 603,
                positions: [
                  [
                    LatLng(45, 9),
                    LatLng(45.5, 9),
                    LatLng(45.6, 9.1),
                    LatLng(45.6, 9.2),
                  ],
                  [
                    LatLng(45.8, 9.3),
                    LatLng(46, 9.3),
                  ]
                ],
                start: DateTime(2023, 5, 23, 21, 35, 06))
          ]
        ]);
      });
      when(database.getGoals(curUser.uid, inProgressOnly: true))
          .thenAnswer((realInvocation) {
        return Stream.fromIterable([
          [
            Goal(
                id: "abcd",
                owner: user,
                type: 'distanceGoal',
                targetValue: 8.0,
                currentValue: 5.3,
                completed: false,
                creationDate: DateTime(2023, 6, 23, 10, 35, 06)),
            Goal(
                id: "abcd",
                owner: user,
                type: 'timeGoal',
                targetValue: 75,
                currentValue: 78.54,
                completed: true,
                creationDate: DateTime(2022, 6, 23, 10, 35, 06))
          ]
        ]);
      });
    });

    testWidgets('Home page', (tester) async {
      await tester.pumpWidget(widget);

      final proposalTileFinder =
          find.byWidgetPredicate((widget) => widget is ProposalTile);
      final sessionCardFinder =
          find.byWidgetPredicate((widget) => widget is SessionCard);
      final goalCardFinder =
          find.byWidgetPredicate((widget) => widget is GoalCard);
      final fabFinder = find.byKey(const Key('FAB'));

      await tester.pumpAndSettle();
      expect(proposalTileFinder, findsOneWidget);
      expect(sessionCardFinder, findsOneWidget);
      expect(goalCardFinder, findsNWidgets(2));
      expect(fabFinder, findsOneWidget);
    });
  });

  group('Home page - No data', () {
    setUp(() {
      when(database.getProposalsWithinInterval(curUser.uid,
              after: anyNamed("after"), before: anyNamed("before")))
          .thenAnswer((realInvocation) {
        return Stream.fromIterable([[]]);
      });
      when(database.getLatestSessionsByUser(curUser.uid, limit: 2))
          .thenAnswer((realInvocation) {
        return Stream.fromIterable([[]]);
      });
      when(database.getGoals(curUser.uid, inProgressOnly: true))
          .thenAnswer((realInvocation) {
        return Stream.fromIterable([[]]);
      });
    });

    testWidgets('Home page', (tester) async {
      await tester.pumpWidget(widget);

      final proposalContainerFinder =
          find.byKey(const Key('NoProposalsContainer'), skipOffstage: false);
      final sessionTextFinder =
          find.text('You do not have any completed session yet.');
      final goalTextFinder =
          find.text('No goal set at the moment...\nTime for a new challenge?');
      final fabFinder = find.byKey(const Key('FAB'));

      await tester.pumpAndSettle();
      expect(proposalContainerFinder, findsOneWidget);
      expect(sessionTextFinder, findsOneWidget);
      expect(goalTextFinder, findsOneWidget);
      expect(fabFinder, findsOneWidget);
    });
  });

  group('Home page - Database error', () {
    setUp(() {
      when(database.getProposalsWithinInterval(curUser.uid,
              after: anyNamed("after"), before: anyNamed("before")))
          .thenAnswer((realInvocation) =>
              Stream.error(DatabaseException('Random error')));
      when(database.getLatestSessionsByUser(curUser.uid, limit: 2)).thenAnswer(
          (realInvocation) => Stream.error(DatabaseException('Random error')));
      when(database.getGoals(curUser.uid, inProgressOnly: true)).thenAnswer(
          (realInvocation) => Stream.error(DatabaseException('Random error')));
    });

    testWidgets('Home page - Error handling', (tester) async {
      await tester.pumpWidget(widget);
      final proposalSnackBarFinder =
          find.text('An error occurred while loading trainings.');
      final sessionTextFinder =
          find.text('Something went wrong. Please try again later.');
      final goalTextFinder =
          find.text('An error occurred while loading goals.');
      final fabFinder = find.byKey(const Key('FAB'));

      await tester.pumpAndSettle();
      expect(proposalSnackBarFinder, findsOneWidget);
      expect(sessionTextFinder, findsOneWidget);
      expect(goalTextFinder, findsOneWidget);
      expect(fabFinder, findsOneWidget);
    });
  });
}
