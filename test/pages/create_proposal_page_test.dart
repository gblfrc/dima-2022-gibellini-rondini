import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/pages/create_proposal_page.dart';

import '../components/forms/create_proposal_form_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<Database>(),
  MockSpec<SearchEngine>(),
])
main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late SearchEngine mockSearchEngine;
  late Place testPlace;

  Finder appBarFinder = find.byKey(const Key('CreateProposalPageAppBar'));
  Finder verticalBodyFinder = find.byKey(const Key('CreateProposalPageVerticalBody'));
  Finder horizontalBodyFinder = find.byKey(const Key('CreateProposalPageHorizontalBody'));
  Finder verticalMapFinder = find.byKey(const Key('CreateProposalPageVerticalMap'), skipOffstage: false);
  Finder horizontalMapFinder = find.byKey(const Key('CreateProposalPageHorizontalMap'), skipOffstage: false);
  Finder verticalFormFinder = find.byKey(const Key('CreateProposalPageVerticalForm'));
  Finder horizontalFormFinder = find.byKey(const Key('CreateProposalPageHorizontalForm'));

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockSearchEngine = MockSearchEngine();
    testPlace = Place.fromJson({
      'id': '11694848',
      'name': 'Parco Suardi',
      'lat': 45.4029422,
      'lon': 9.20194914,
    });
    when(mockSearchEngine.getPlacesByName('test')).thenAnswer((invocation) => Future.value([testPlace]));
  });

  Widget widgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: CreateProposalPage(
          auth: mockAuth,
          database: mockDatabase,
          searchEngine: mockSearchEngine,
        ),
      ),
    );
  }

  group('basic components', () {
    testWidgets('vertical', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(600, 800);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(verticalBodyFinder, findsOneWidget);
        expect(verticalMapFinder, findsNothing);
        expect(verticalFormFinder, findsOneWidget);
        expect(horizontalBodyFinder, findsNothing);
        expect(horizontalMapFinder, findsNothing);
        expect(horizontalFormFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(verticalBodyFinder, findsNothing);
        expect(verticalMapFinder, findsNothing);
        expect(verticalFormFinder, findsNothing);
        expect(horizontalBodyFinder, findsOneWidget);
        expect(horizontalMapFinder, findsNothing);
        expect(horizontalFormFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('location setting and map update', () {
    testWidgets('vertical', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(600, 800);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        // search for a first time
        await tester.enterText(find.byKey(const Key('CreateProposalFormLocationField')), 'test');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('LocationListTile_${testPlace.name}')), findsOneWidget);
        await tester.tap(find.byKey(Key('LocationListTile_${testPlace.name}')));
        await tester.pumpAndSettle();
        expect(verticalMapFinder, findsOneWidget);
        expect(horizontalMapFinder, findsNothing);
        CustomSmallMap map = find.byType(CustomSmallMap, skipOffstage: false).evaluate().single.widget as CustomSmallMap;
        expect(map.mapController!.center.latitude, testPlace.coords.latitude);
        expect(map.mapController!.center.longitude, testPlace.coords.longitude);
        // clear search, map should disappear
        await tester.tap(find.descendant(of: find.byKey(const Key('CreateProposalFormLocationField')), matching: find.byType(IconButton)));
        await tester.pumpAndSettle();
        expect(verticalMapFinder, findsNothing);
        expect(horizontalMapFinder, findsNothing);
        // search once more (same as first case)
        await tester.enterText(find.byKey(const Key('CreateProposalFormLocationField')), 'test');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('LocationListTile_${testPlace.name}')), findsOneWidget);
        await tester.tap(find.byKey(Key('LocationListTile_${testPlace.name}')));
        await tester.pumpAndSettle();
        expect(verticalMapFinder, findsOneWidget);
        expect(horizontalMapFinder, findsNothing);
        map = find.byType(CustomSmallMap, skipOffstage: false).evaluate().single.widget as CustomSmallMap;
        expect(map.mapController!.center.latitude, testPlace.coords.latitude);
        expect(map.mapController!.center.longitude, testPlace.coords.longitude);
        // change position to test place and verify map controller can move
        testPlace.coords = LatLng(47.0, 9.6);
        await tester.enterText(find.byKey(const Key('CreateProposalFormLocationField')), 'test');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('LocationListTile_${testPlace.name}')), findsOneWidget);
        await tester.tap(find.byKey(Key('LocationListTile_${testPlace.name}')));
        await tester.pumpAndSettle();
        expect(verticalMapFinder, findsOneWidget);
        expect(horizontalMapFinder, findsNothing);
        map = find.byType(CustomSmallMap, skipOffstage: false).evaluate().single.widget as CustomSmallMap;
        expect(map.mapController!.center.latitude, testPlace.coords.latitude);
        expect(map.mapController!.center.longitude, testPlace.coords.longitude);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        // search vertically
        tester.binding.window.physicalSizeTestValue = const Size(600, 950);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('CreateProposalFormLocationField')), 'test');
        await tester.pumpAndSettle();
        expect(find.byKey(Key('LocationListTile_${testPlace.name}')), findsOneWidget);
        await tester.tap(find.byKey(Key('LocationListTile_${testPlace.name}')));
        await tester.pumpAndSettle();
        expect(verticalMapFinder, findsOneWidget);
        expect(horizontalMapFinder, findsNothing);
        CustomSmallMap map = find.byType(CustomSmallMap, skipOffstage: false).evaluate().single.widget as CustomSmallMap;
        expect(map.mapController!.center.latitude, testPlace.coords.latitude);
        expect(map.mapController!.center.longitude, testPlace.coords.longitude);
        // rotate screen --> should become horizontal
        tester.binding.window.physicalSizeTestValue = const Size(950, 600);
        await tester.pump(const Duration(seconds: 2));
        expect(verticalMapFinder, findsNothing);
        expect(horizontalMapFinder, findsOneWidget);
        map = find.byType(CustomSmallMap, skipOffstage: false).evaluate().single.widget as CustomSmallMap;
        expect(map.mapController!.center.latitude, testPlace.coords.latitude);
        expect(map.mapController!.center.longitude, testPlace.coords.longitude);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });
}
