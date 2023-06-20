import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/components/cards.dart';
import 'package:progetto/model/goal.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/model/user.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/pages/session_info_page.dart';

@GenerateNiceMocks([MockSpec<Database>()])
import 'cards_test.mocks.dart';

main() {
  late Session session;
  late Session session2;
  late Goal distanceGoal;
  late Goal timeGoal;
  late Goal timeGoal2;
  late Goal speedGoal;
  late Database database;

  group('Session Card', () {
    setUp(() {
      session = Session(
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
          start: DateTime(2023, 5, 23, 21, 35, 06));

      session2 = Session(
          id: "abcd",
          distance: 799.8,
          duration: 3603,
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
          start: DateTime(2022, 5, 23, 21, 35, 06));
    });

    testWidgets('Session Card - Session 1', (tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
                home: SessionCard(
                  session: session,
                ))));

        final distanceFinder = find.text('3.4 km');
        final timeFinder = find.text('TIME: 10:03');
        Finder dateFinder;
        if (session.start.year < DateTime.now().year) {
          dateFinder = find.text('MAY 23, 2023');
        } else {
          dateFinder = find.text('MAY 23');
        }
        final mapFinder = find.byWidgetPredicate((widget) =>
        widget is FlutterMap &&
            widget.options.interactiveFlags == InteractiveFlag.none &&
            widget.options.bounds?.north == (46 + 1 / 4 * 1) &&
            widget.options.bounds?.west == (9 - 1 / 4 * 0.3) &&
            widget.options.bounds?.south == (45 - 1 / 4 * 1) &&
            widget.options.bounds?.east == (9.3 + 1 / 4 * 0.3));

        expect(distanceFinder, findsOneWidget);
        expect(timeFinder, findsOneWidget);
        expect(dateFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
      });
    });

    testWidgets('Session Card - Session 2', (tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
                home: SessionCard(
                  session: session2,
                ))));

        final distanceFinder = find.text('800 m');
        final timeFinder = find.text('TIME: 1:00:03');
        final dateFinder = find.text('MAY 23, 2022');

        expect(distanceFinder, findsOneWidget);
        expect(timeFinder, findsOneWidget);
        expect(dateFinder, findsOneWidget);
      });
    });

    testWidgets('Session Card - Tap on card', (tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
                home: SessionCard(
                  session: session,
                ))));
        final cardFinder = find.byKey(const Key(
            'DateText')); // TODO: If the tap happens inside the map, the event doesn't reach the InkWell
        await tester.tap(cardFinder);
        await tester.pumpAndSettle();
        final sessionPageFinder =
        find.byWidgetPredicate((widget) => widget is SessionInfoPage);
        expect(sessionPageFinder, findsOneWidget);
      });
    });
  });

  group('Goal Card', () {
    setUp(() {
      distanceGoal = Goal(
          id: "abcd",
          owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
          type: 'distanceGoal',
          targetValue: 8.0,
          currentValue: 5.3,
          completed: false,
          creationDate: DateTime(2023, 6, 23, 10, 35, 06));

      timeGoal = Goal(
          id: "abcd",
          owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
          type: 'timeGoal',
          targetValue: 75,
          currentValue: 78.54,
          completed: true,
          creationDate: DateTime(2022, 6, 23, 10, 35, 06));

      timeGoal2 = Goal(
          id: "abcd",
          owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
          type: 'timeGoal',
          targetValue: 75,
          currentValue: 0,
          completed: false,
          creationDate: DateTime(2022, 6, 23, 10, 35, 06));

      speedGoal = Goal(
          id: "abcd",
          owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
          type: 'speedGoal',
          targetValue: 12.5,
          currentValue: 0,
          completed: false,
          creationDate: DateTime.now());
      
      database = MockDatabase();
      when(database.deleteGoal(timeGoal2)).thenAnswer((realInvocation) async {});
    });

    testWidgets("Goal card - distance goal", (tester) async {
      GlobalKey<NavigatorState> navigatorKey = GlobalKey();
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (BuildContext context) {
            return MaterialApp(
                navigatorKey: navigatorKey, home: GoalCard(distanceGoal, database: database,));
          })));
      final titleFinder = find.text('Run for at least 8.0 km');
      final subtitleFinder = find.text('5.3 km already run');
      final progressBarFinder = find.byWidgetPredicate((widget) =>
      widget is LinearProgressIndicator && widget.value == 5.3 / 8);
      Finder creationDateFinder;
      if (session.start.year < DateTime.now().year) {
        creationDateFinder = find.text('CREATED ON JUN 23, 2023 AT 10:35');
      } else {
        creationDateFinder = find.text('CREATED ON JUN 23 AT 10:35');
      }

      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);
      expect(progressBarFinder, findsOneWidget);
      expect(creationDateFinder, findsOneWidget);
    });

    testWidgets("Goal card - time goal", (tester) async {
      GlobalKey<NavigatorState> navigatorKey = GlobalKey();
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (BuildContext context) {
            return MaterialApp(
                navigatorKey: navigatorKey, home: GoalCard(timeGoal, database: database,));
          })));
      final titleFinder = find.text('Run for at least 75 min');
      final subtitleFinder = find.text('Completed');
      final creationDateFinder = find.text('CREATED ON JUN 23, 2022 AT 10:35');
      final progressBarFinder = find.byWidgetPredicate((widget) =>
      widget is LinearProgressIndicator && widget.value == 78.54 / 75);

      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);
      expect(progressBarFinder, findsOneWidget);
      expect(creationDateFinder, findsOneWidget);
    });

    testWidgets("Goal card - time goal 2", (tester) async {
      GlobalKey<NavigatorState> navigatorKey = GlobalKey();
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (BuildContext context) {
            return MaterialApp(
                navigatorKey: navigatorKey, home: GoalCard(timeGoal2, database: database,));
          })));
      final titleFinder = find.text('Run for at least 75 min');
      final subtitleFinder = find.text('0 min already run');
      final progressBarFinder = find.byWidgetPredicate((widget) =>
      widget is LinearProgressIndicator && widget.value == 0 / 75);

      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);
      expect(progressBarFinder, findsOneWidget);
    });

    testWidgets("Goal card - speed goal", (tester) async {
      GlobalKey<NavigatorState> navigatorKey = GlobalKey();
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (BuildContext context) {
            return MaterialApp(
                navigatorKey: navigatorKey, home: GoalCard(speedGoal, database: database,));
          })));
      final titleFinder =
      find.text('Run with an average speed of at least 12.5 km/h');
      final subtitleFinder = find.text('In progress');
      final progressBarFinder =
      find.byWidgetPredicate((widget) => widget is LinearProgressIndicator);

      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);
      expect(progressBarFinder, findsNothing);
    });

    testWidgets('Goal Card - Delete goal', (tester) async {
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (BuildContext context) {
            return MaterialApp(
              home: Scaffold(body: GoalCard(timeGoal2, database: database,)),);
          })));

      final deleteButtonFinder = find.byKey(const Key('DeleteGoalButton'));
      await tester.tap(deleteButtonFinder);
      verify(database.deleteGoal(timeGoal2));
    });
  });

  group('Goal Card - Database Error', () {
    setUp(() {
      distanceGoal = Goal(
          id: "abcd",
          owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
          type: 'distanceGoal',
          targetValue: 8.0,
          currentValue: 5.3,
          completed: false,
          creationDate: DateTime(2023, 6, 23, 10, 35, 06));

      database = MockDatabase();
      when(database.deleteGoal(distanceGoal)).thenThrow(DatabaseException('Random error'));
    });

    testWidgets('Goal Card - Error handling', (tester) async {
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (BuildContext context) {
            return MaterialApp(
              home: Scaffold(body: GoalCard(distanceGoal, database: database,)),);
          })));

      final deleteButtonFinder = find.byKey(const Key('DeleteGoalButton'));
      await tester.tap(deleteButtonFinder);
      final errorSnackBar = find.byKey(const Key('ErrorSnackBar'));
      await tester.pumpAndSettle();
      expect(errorSnackBar, findsOneWidget);
    });
  });
}
