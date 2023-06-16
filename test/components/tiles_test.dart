import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/components/profile_picture.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/model/user.dart';

import 'profile_picture_test.mocks.dart';

main() {
  User user = User(uid: "xcvb", name: "Mario", surname: "Rossi");

  testWidgets('User tile', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(
                  body: UserTile.fromUser(user, context, MockStorage())));
        })));
    final titleFinder = find.text('Mario Rossi');
    final imageFinder =
        find.byWidgetPredicate((widget) => widget is ProfilePicture);

    expect(titleFinder, findsOneWidget);
    expect(imageFinder, findsOneWidget);
  });

  Place place0 = Place(
      id: "qwerty",
      name: "Parco Suardi",
      coords: LatLng(45.9532, 9.420429),
      type: "park");

  testWidgets('Place tile - no second line', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(body: PlaceTile.fromPlace(place0, context)));
        })));
    final titleFinder = find.text('Parco Suardi');
    final subtitleFinder = find.byWidgetPredicate(
        (widget) => widget is Tile && widget.subtitle == null);
    final iconFinder = find.byWidgetPredicate(
        (widget) => widget is Icon && widget.icon == Icons.park);

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);
  });

  Place place1 = Place(
      id: "qwertyu",
      name: "Liceo Mascheroni",
      coords: LatLng(46, 9.4303),
      type: "school",
      city: "Bergamo",
      country: "Italy",
      state: "Lombardia");

  testWidgets('Place tile - complete second line', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(body: PlaceTile.fromPlace(place1, context)));
        })));
    final titleFinder = find.text('Liceo Mascheroni');
    final subtitleFinder = find.text('Bergamo, Lombardia, Italy');
    final iconFinder = find.byWidgetPredicate(
        (widget) => widget is Icon && widget.icon == Icons.school);

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);
  });

  Proposal proposal = Proposal(
      dateTime: DateTime(2023, 6, 15, 15, 40, 43),
      owner: user,
      place: place0,
      type: 'Friends',
      participants: []);

  testWidgets('Proposal tile', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home:
                  Scaffold(body: ProposalTile.fromProposal(proposal, context)));
        })));
    final titleFinder = find.text('Parco Suardi');
    final subtitleFinder = find.text('Organizer: Mario Rossi');
    await tester.pumpAndSettle(); // Waits for the spinning animation to complete (the SVG image is ready)
    final iconFinder = find.byWidgetPredicate((widget) => widget is SvgPicture);

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);
  });
}
