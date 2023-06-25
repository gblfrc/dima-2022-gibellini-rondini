import 'package:firebase_auth/firebase_auth.dart' as auth_firebase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/location_handler.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/pages/search_page.dart';

@GenerateNiceMocks([
  MockSpec<Database>(),
  MockSpec<Auth>(),
  MockSpec<Storage>(),
  MockSpec<auth_firebase.User>(),
  MockSpec<SearchEngine>(),
  MockSpec<LocationHandler>()
])
import 'search_page_test.mocks.dart';

main() {
  late MockDatabase database;
  late Auth auth;
  late SearchEngine searchEngine;
  late Widget widget;
  late auth_firebase.User curUser;
  late LocationHandler locationHandler;
  Position testPosition = Position(
      longitude: 9.6,
      latitude: 45.7,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);
  setUp(() {
    database = MockDatabase();
    auth = MockAuth();
    searchEngine = MockSearchEngine();
    curUser = MockUser();
    locationHandler = MockLocationHandler();
    widget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return Scaffold(
              body: SearchPage(
            database: database,
            auth: auth,
            storage: MockStorage(),
            searchEngine: searchEngine,
            locationHandler: locationHandler,
          ));
        })));
    when(auth.currentUser).thenReturn(curUser);
    when(curUser.uid).thenReturn("abcd");
    when(locationHandler.getCurrentPosition())
        .thenAnswer((realInvocation) async {
      return testPosition;
    });
    when(searchEngine.getUsersByName("Mario", excludeUid: "abcd"))
        .thenAnswer((realInvocation) async {
      return [
        User(uid: "xcvb", name: "Mario", surname: "Rossi"),
        User(uid: "xcvb", name: "Mario", surname: "Bianchi")
      ];
    });
    when(searchEngine.getPlacesByName("Parco"))
        .thenAnswer((realInvocation) async {
      return [
        Place(
            id: "qwerty",
            name: "Parco Suardi",
            coords: LatLng(45.9532, 9.420429),
            type: "park"),
        Place(
            id: "qwerty",
            name: "Parco Marenzi",
            coords: LatLng(45.8532, 9.320429),
            type: "park")
      ];
    });

    when(database.getProposalsWithinBounds(any, "abcd",
            after: anyNamed("after")))
        .thenAnswer((realInvocation) async {
      return [
        Proposal(
            dateTime: DateTime(2023, 6, 15, 15, 40, 43),
            owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
            place: Place(
                id: "qwerty",
                name: "Parco Suardi",
                coords: LatLng(45.9532, 9.420429),
                type: "park"),
            type: 'Friends',
            participants: []),
        Proposal(
            dateTime: DateTime(2023, 6, 15, 15, 40, 43),
            owner: User(uid: "xcvb", name: "Mario", surname: "Rossi"),
            place: Place(
                id: "qwerty",
                name: "Parco Suardi",
                coords: LatLng(45.9532, 9.420429),
                type: "park"),
            type: 'Friends',
            participants: [])
      ];
    });
  });

  testWidgets('Search page - User search', (tester) async {
    await tester.pumpWidget(widget);
    final searchBarFinder = find.byKey(const Key('UserSearchBar'));
    final resultFinder = find.byWidgetPredicate((widget) => widget is UserTile);

    await tester.pumpAndSettle();
    await tester.enterText(searchBarFinder, 'Mario');
    await tester.pumpAndSettle();
    expect(resultFinder, findsNWidgets(2));
  });

  testWidgets('Search page - Place search', (tester) async {
    await tester.pumpWidget(widget);
    final placeTabFinder = find.byKey(const Key('PlaceTab'));
    final searchBarFinder = find.byKey(const Key('PlaceSearchBar'));
    final resultFinder =
        find.byWidgetPredicate((widget) => widget is PlaceTile);

    await tester.pumpAndSettle();
    await tester.tap(placeTabFinder);
    await tester.pumpAndSettle();
    await tester.enterText(searchBarFinder, 'Parco');
    await tester.pumpAndSettle();
    expect(resultFinder, findsNWidgets(2));
  });

  testWidgets('Search page - Map search', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widget);
      final mapTabFinder = find.byKey(const Key('MapTab'));
      final mapFinder = find.byWidgetPredicate(
          (widget) => widget is CustomSmallMap,
          skipOffstage: false);
      final proposalFinder =
          find.byWidgetPredicate((widget) => widget is ProposalTile);

      await tester.pumpAndSettle();
      await tester.tap(mapTabFinder);
      await tester.pumpAndSettle();

      expect(mapFinder, findsOneWidget);

      await tester.drag(mapFinder, const Offset(100.0, 50.0));
      await tester.pump(const Duration(seconds: 2));

      expect(proposalFinder, findsNWidgets(2));

      //await tester.dragFrom(tester.getCenter(mapFinder), const Offset(2.0, 1.0));
      /*TestGesture gesture;
      gesture = await tester.startGesture(tester.getCenter(mapFinder), pointer: 2);
      await gesture.moveBy(const Offset(2.0, 1.0));
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));*/
    });
  });
}
