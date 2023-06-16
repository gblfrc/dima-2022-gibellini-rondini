import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/components/cards.dart';
import 'package:progetto/model/goal.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/model/user.dart';

main() {
  late Session session;
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

  testWidgets('Session Card', (tester) async {
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
        widget.options.bounds?.west == (9 + 1 / 4 * 0.3) &&
        widget.options.bounds?.south == (45 - 1 / 4 * 1) &&
        widget.options.bounds?.east == (9.3 - 1 / 4 * 0.3));
    // TODO: Possible bug in Session_Map: deltas should be in absolute value

    expect(distanceFinder, findsOneWidget);
    expect(timeFinder, findsOneWidget);
    expect(dateFinder, findsOneWidget);
    expect(mapFinder, findsOneWidget);
  });

  Goal distanceGoal = Goal(
      id: "abcd",
      owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
      type: 'distanceGoal',
      targetValue: 8.0,
      currentValue: 5.3,
      completed: false,
      creationDate: DateTime.now());

  testWidgets("Goal card - distance goal", (tester) async {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              navigatorKey: navigatorKey, home: GoalCard(distanceGoal));
        })));
    final titleFinder = find.text('Run for at least 8.0 km');
    final subtitleFinder = find.text('In progress');
    final progressBarFinder = find.byWidgetPredicate((widget) =>
        widget is LinearProgressIndicator && widget.value == 5.3 / 8);

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(progressBarFinder, findsOneWidget);
  });

  Goal timeGoal = Goal(
      id: "abcd",
      owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
      type: 'timeGoal',
      targetValue: 75,
      currentValue: 78.54,
      completed: true,
      creationDate: DateTime.now());

  testWidgets("Goal card - time goal", (tester) async {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              navigatorKey: navigatorKey, home: GoalCard(timeGoal));
        })));
    final titleFinder = find.text('Run for at least 75 min');
    final subtitleFinder = find.text('Completed');
    final progressBarFinder = find.byWidgetPredicate((widget) =>
        widget is LinearProgressIndicator && widget.value == 78.54 / 75);

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(progressBarFinder, findsOneWidget);
  });

  Goal speedGoal = Goal(
      id: "abcd",
      owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
      type: 'speedGoal',
      targetValue: 12.5,
      currentValue: 0,
      completed: false,
      creationDate: DateTime.now());

  testWidgets("Goal card - speed goal", (tester) async {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              navigatorKey: navigatorKey, home: GoalCard(speedGoal));
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
}
