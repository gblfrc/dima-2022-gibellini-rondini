import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
import 'package:flutter/material.dart';
import 'package:progetto/pages/place_page.dart';

@GenerateNiceMocks([MockSpec<Auth>(), MockSpec<Database>(), MockSpec<User>()])
import 'place_page_test.mocks.dart';

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late User mockUser;
  late Place testPlace;
  late Proposal testProposal0;
  late Proposal testProposal1;
  Finder mapSectionFinder = find.byKey(const Key('MapSection'));
  Finder nonMapSectionFinder = find.byKey(const Key('NonMapSection'));
  Finder mapFinder = find.byKey(const Key('PlacePageMap'));
  Finder markerFinder = find.byKey(const Key('PlacePageMarker'));
  Finder noAvailableProposalTextFinder = find.byKey(const Key('PlacePageNoAvailableProposalText'));
  Finder proposalListFinder = find.byKey(const Key('PlacePageProposalList'));
  Finder errorTextFinder = find.byKey(const Key('PlacePageErrorInFetchingProposalText'));
  Finder circularProgressIndicatorFinder = find.byKey(const Key('PlacePageProposalCircularProgressIndicator'));

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockUser = MockUser();
    testPlace = Place.fromJson({
      'id': 'test_place',
      'name': 'Parco Suardi',
      'city': 'Bergamo',
      'lat': 45.4029422,
      'lon': 9.20194914,
      'state': null,
      'country': 'Italy',
      'type': 'park'
    });
    testProposal0 = Proposal.fromJson({
      'pid': 'test_proposal_1',
      'dateTime': "2023-05-23 21:35:06",
      'owner': {
        'name': 'Mario',
        'surname': 'Rossi',
        'uid': 'mario_rossi',
      },
      'place': {
        'id': '11694848',
        'name': 'Parco Suardi',
        'lat': 45.4029422,
        'lon': 9.20194914,
      },
      'participants': ['second_participant'],
      'type': 'Public'
    });
    testProposal1 = Proposal.fromJson({
      'pid': 'test_proposal_1',
      'dateTime': "2023-06-30 18:15:00",
      'owner': {
        'name': 'Luigi',
        'surname': 'Verdi',
        'uid': 'luigi_verdi',
      },
      'place': {
        'id': '11694848',
        'name': 'Parco Suardi',
        'lat': 45.4029422,
        'lon': 9.20194914,
      },
      'participants': ['first_participant', 'third_participant'],
      'type': 'Public'
    });
  });

  Widget widgetUnderTest(Place place) {
    return MaterialApp(
      home: Scaffold(
        body: PlacePage(
          place: place,
          auth: mockAuth,
          database: mockDatabase,
        ),
      ),
    );
  }

  group('basic components, orientation, devices', () {
    testWidgets('vertical phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((realInvocation) => Future.value([testProposal0, testProposal1]));
        tester.binding.window.physicalSizeTestValue = const Size(600, 800);
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pump(const Duration(seconds: 2));
        Flexible mapSection = mapSectionFinder.evaluate().single.widget as Flexible;
        Flexible nonMapSection = nonMapSectionFinder.evaluate().single.widget as Flexible;
        expect(mapSectionFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(markerFinder, findsOneWidget);
        expect(nonMapSectionFinder, findsOneWidget);
        expect(proposalListFinder, findsOneWidget);
        expect(errorTextFinder, findsNothing);
        expect(noAvailableProposalTextFinder, findsNothing);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(mapSection.flex, 3);
        expect(nonMapSection.flex, 5);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('vertical tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((realInvocation) => Future.value([testProposal0, testProposal1]));
        tester.binding.window.physicalSizeTestValue = const Size(1800, 2560);
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pump(const Duration(seconds: 2));
        Flexible mapSection = mapSectionFinder.evaluate().single.widget as Flexible;
        Flexible nonMapSection = nonMapSectionFinder.evaluate().single.widget as Flexible;
        expect(mapSectionFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(markerFinder, findsOneWidget);
        expect(nonMapSectionFinder, findsOneWidget);
        expect(proposalListFinder, findsOneWidget);
        expect(errorTextFinder, findsNothing);
        expect(noAvailableProposalTextFinder, findsNothing);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(mapSection.flex, 5);
        expect(nonMapSection.flex, 6);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((realInvocation) => Future.value([testProposal0, testProposal1]));
        tester.binding.window.physicalSizeTestValue = const Size(2560, 1800);
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pump(const Duration(seconds: 2));
        Flexible mapSection = mapSectionFinder.evaluate().single.widget as Flexible;
        Flexible nonMapSection = nonMapSectionFinder.evaluate().single.widget as Flexible;
        expect(mapSectionFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(markerFinder, findsOneWidget);
        expect(nonMapSectionFinder, findsOneWidget);
        expect(proposalListFinder, findsOneWidget);
        expect(errorTextFinder, findsNothing);
        expect(noAvailableProposalTextFinder, findsNothing);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(mapSection.flex, 5);
        expect(nonMapSection.flex, 5);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((realInvocation) => Future.value([testProposal0, testProposal1]));
        tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pump(const Duration(seconds: 2));
        Flexible mapSection = mapSectionFinder.evaluate().single.widget as Flexible;
        Flexible nonMapSection = nonMapSectionFinder.evaluate().single.widget as Flexible;
        expect(mapSectionFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(markerFinder, findsOneWidget);
        expect(nonMapSectionFinder, findsOneWidget);
        expect(proposalListFinder, findsOneWidget);
        expect(errorTextFinder, findsNothing);
        expect(noAvailableProposalTextFinder, findsNothing);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(mapSection.flex, 5);
        expect(nonMapSection.flex, 6);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('behaviors', () {
    testWidgets('correctly received 2 proposals', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((realInvocation) => Future.value([testProposal0, testProposal1]));
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pump(const Duration(seconds: 2));
        expect(proposalListFinder, findsOneWidget);
        expect(errorTextFinder, findsNothing);
        expect(noAvailableProposalTextFinder, findsNothing);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(find.byKey(const Key('PlacePageProposalTile_0')), findsOneWidget);
        expect(find.byKey(const Key('PlacePageProposalTile_1')), findsOneWidget);
      });
    });
    testWidgets('correctly received 0 proposals', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((realInvocation) => Future.value([]));
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pumpAndSettle();
        expect(proposalListFinder, findsNothing);
        expect(errorTextFinder, findsNothing);
        expect(noAvailableProposalTextFinder, findsOneWidget);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(find.byKey(const Key('PlacePageProposalTile_0')), findsNothing);
        expect(find.byKey(const Key('PlacePageProposalTile_1')), findsNothing);
      });
    });
    testWidgets('error in snapshot', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('mario_rossi');
        when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
            .thenAnswer((invocation) => Future.error(DatabaseException('test')));
        await tester.pumpWidget(widgetUnderTest(testPlace));
        await tester.pump(const Duration(seconds: 2));
        expect(proposalListFinder, findsNothing);
        expect(errorTextFinder, findsOneWidget);
        expect(noAvailableProposalTextFinder, findsNothing);
        expect(circularProgressIndicatorFinder, findsNothing);
        expect(find.byKey(const Key('PlacePageProposalTile_0')), findsNothing);
        expect(find.byKey(const Key('PlacePageProposalTile_1')), findsNothing);
      });
    });
    // testWidgets('waiting for proposals', (WidgetTester tester) async {
    //   mockNetworkImagesFor(() async {
    //     Completer completer = Completer();
    //     when(mockAuth.currentUser).thenReturn(mockUser);
    //     when(mockUser.uid).thenReturn('mario_rossi');
    //     when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
    //         .thenAnswer((realInvocation) => completer.future);
    //
    //     await tester.pumpWidget(widgetUnderTest(testPlace));
    //     await tester.pump();
    //     expect(proposalListFinder, findsNothing);
    //     expect(errorTextFinder, findsNothing);
    //     expect(noAvailableProposalTextFinder, findsNothing);
    //     expect(circularProgressIndicatorFinder, findsOneWidget);
    //     expect(find.byKey(const Key('PlacePageProposalTile_0')), findsNothing);
    //     expect(find.byKey(const Key('PlacePageProposalTile_1')), findsNothing);
    //   });
    // });
  });

  testWidgets('map and coordinates', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('mario_rossi');
      when(mockDatabase.getProposalsByPlace(testPlace, 'mario_rossi'))
          .thenAnswer((invocation) => Future.error(DatabaseException('test')));
      await tester.pumpWidget(widgetUnderTest(testPlace));
      await tester.pump(const Duration(seconds: 2));
      expect(mapFinder, findsOneWidget);
      CustomSmallMap map = mapFinder.evaluate().single.widget as CustomSmallMap;
      expect(map.mapController!.center.latitude, testPlace.coords.latitude);
      expect(map.mapController!.center.longitude, testPlace.coords.longitude);
    });
  });

  // test on circular progress indicator
}
