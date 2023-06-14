import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/components/cards.dart';
import 'package:progetto/model/session.dart';

main() {
  late Session session;
  session = Session(id: "abcd",
      distance: 3419.99,
      duration: 603,
      positions: [
        [
          LatLng(45, 9),
          LatLng(45.5, 9),
          LatLng(45.6, 9.1),
          LatLng(45.6, 9.2),
        ],
        [LatLng(45.8, 9.3), LatLng(46, 9.3),]
      ],
      start: DateTime(2023, 5, 23, 21, 35, 06));

  testWidgets('Card with a session', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: SessionCard(session: session,))
    ));

    final distanceFinder = find.text('3.4 km');
    final timeFinder = find.text('TIME: 10:03');
    Finder dateFinder;
    if(session.start.year < DateTime.now().year) {
      dateFinder = find.text('MAY 23, 2023');
    }
    else {
      dateFinder = find.text('MAY 23');
    }

    expect(distanceFinder, findsOneWidget);
    expect(timeFinder, findsOneWidget);
    expect(dateFinder, findsOneWidget);
  });
}