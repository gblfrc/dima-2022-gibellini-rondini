import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_firebase;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/profile_picture.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/pages/account_page.dart';

@GenerateNiceMocks([MockSpec<Database>(), MockSpec<Storage>(), MockSpec<Auth>(), MockSpec<auth_firebase.User>()])
import 'tiles_test.mocks.dart';

main() {
  User user = User(uid: "xcvb", name: "Mario", surname: "Rossi");
  late Auth auth;
  late auth_firebase.User curUser;

  setUp(() {
    auth = MockAuth();
    curUser = MockUser();
    when(auth.currentUser).thenReturn(curUser);
  });

  testWidgets('User tile', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return Scaffold(body: UserTile.fromUser(user, context, MockStorage(), MockDatabase(), auth));
        }))));
    final titleFinder = find.text('Mario Rossi');
    final imageFinder = find.byWidgetPredicate((widget) => widget is ProfilePicture);
    final tileFinder = find.byWidgetPredicate((widget) => widget is UserTile);

    expect(titleFinder, findsOneWidget);
    expect(imageFinder, findsOneWidget);

    await tester.tap(tileFinder);
    final accountPageFinder = find.byWidgetPredicate((widget) => widget is AccountPage);
    await tester.pump(const Duration(seconds: 2));
    expect(accountPageFinder, findsOneWidget);
  });

  Place place0 = Place(id: "qwerty", name: "Parco Suardi", coords: LatLng(45.9532, 9.420429), type: "park");

  testWidgets('Place tile - no second line', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(
                  body: PlaceTile.fromPlace(
                      place: place0, context: context, auth: MockAuth(), database: MockDatabase(), storage: MockStorage())));
        })));
    final titleFinder = find.text('Parco Suardi');
    final subtitleFinder = find.byWidgetPredicate((widget) => widget is Tile && widget.subtitle == null);
    final iconFinder = find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.park);

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
              home: Scaffold(
                  body: PlaceTile.fromPlace(
                      place: place1, context: context, auth: MockAuth(), database: MockDatabase(), storage: MockStorage())));
        })));
    final titleFinder = find.text('Liceo Mascheroni');
    final subtitleFinder = find.text('Bergamo, Lombardia, Italy');
    final iconFinder = find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.school);

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);
  });

  Proposal proposal0 = Proposal(
      dateTime: DateTime(2023, 6, 15, 15, 40, 43), owner: user, place: place0, type: 'Friends', participants: []);

  testWidgets('Proposal tile - Friends not startable', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(
                  body: ProposalTile.fromProposal(proposal0, context, auth: MockAuth(), database: MockDatabase(),storage: MockStorage())));
        })));
    final titleFinder = find.text('Parco Suardi');
    final subtitleFinder = find.text('Organizer: Mario Rossi');
    //await tester.pump(); // Waits for the spinning animation to complete (the SVG image is ready)
    // final calendarIconFinder = find.byWidgetPredicate((widget) => widget is SvgPicture);
    final privacyIconFinder = find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.lock);
    final startButtonFinder = find.widgetWithText(FilledButton, "Start");

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    //expect(calendarIconFinder, findsOneWidget);
    expect(privacyIconFinder, findsOneWidget);
    expect(startButtonFinder, findsNothing);
  });

  Proposal proposal1 = Proposal(
      dateTime: DateTime(2023, 6, 15, 15, 40, 43), owner: user, place: place0, type: 'Public', participants: []);

  testWidgets('Proposal tile - Public not startable', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(
                  body: ProposalTile.fromProposal(proposal1, context, auth: MockAuth(), database: MockDatabase(),storage: MockStorage())));
        })));
    final titleFinder = find.text('Parco Suardi');
    final subtitleFinder = find.text('Organizer: Mario Rossi');
    await tester.pump(const Duration(seconds: 2)); // Waits for the spinning animation to complete (the SVG image is ready)
    //final calendarIconFinder = find.byWidgetPredicate((widget) => widget is SvgPicture);
    final privacyIconFinder = find.byWidgetPredicate((widget) => widget is Icon && widget.icon == MdiIcons.lockOpen);
    final startButtonFinder = find.widgetWithText(FilledButton, "Start");

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    //expect(calendarIconFinder, findsOneWidget);
    expect(privacyIconFinder, findsOneWidget);
    expect(startButtonFinder, findsNothing);
  });

  testWidgets('Proposal tile - Startable', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(
                  body: ProposalTile.fromProposal(proposal0, context,
                      auth: MockAuth(), database: MockDatabase(), storage: MockStorage(), startable: true)));
        })));
    final titleFinder = find.text('Parco Suardi');
    final subtitleFinder = find.text('Organizer: Mario Rossi');
    await tester.pump(const Duration(seconds: 2)); // Waits for the spinning animation to complete (the SVG image is ready)
    //final calendarIconFinder = find.byWidgetPredicate((widget) => widget is SvgPicture);
    final privacyIconFinder = find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.lock);
    final startButtonFinder = find.widgetWithText(FilledButton, "Start");

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    //expect(calendarIconFinder, findsOneWidget);
    expect(privacyIconFinder, findsNothing);
    expect(startButtonFinder, findsOneWidget);
  });
}
