import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/pages/session_info_page.dart';

main() {
  Session session = Session(
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
  Session session2 = Session(
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


  testWidgets('Session Info Page - Session 1', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(home: Builder(builder: (BuildContext context) {
            return Scaffold(body: SessionInfoPage(session));
          }))));
      final startDateFinder = find.text('23 May 2023 21:35');
      final distanceFinder = find.text('3.42 km');
      final timeFinder = find.text('10:03');
      final mapFinder = find.byWidgetPredicate((widget) =>
      widget is FlutterMap &&
          widget.options.interactiveFlags == InteractiveFlag.all &&
          widget.options.bounds?.north == (46 + 1 / 4 * 1) &&
          widget.options.bounds?.west == (9 - 1 / 4 * 0.3) &&
          widget.options.bounds?.south == (45 - 1 / 4 * 1) &&
          widget.options.bounds?.east == (9.3 + 1 / 4 * 0.3));

      expect(startDateFinder, findsOneWidget);
      expect(distanceFinder, findsOneWidget);
      expect(timeFinder, findsOneWidget);
      expect(mapFinder, findsOneWidget);
    });
  });

  testWidgets('Session Info Page - Session 2', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(home: Builder(builder: (BuildContext context) {
            return Scaffold(body: SessionInfoPage(session2));
          }))));
      final startDateFinder = find.text('23 May 2022 21:35');
      final distanceFinder = find.text('800 m');
      final timeFinder = find.text('1:00:03');

      expect(startDateFinder, findsOneWidget);
      expect(distanceFinder, findsOneWidget);
      expect(timeFinder, findsOneWidget);
    });
  });
}
