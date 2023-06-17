import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/model/proposal.dart';

main() {
  late Proposal testProposal0, testProposal1;
  late MapOptions testMapOptions;
  late MapController testMapController;
  late List<Widget> testChildren;

  setUp(() {
    testProposal0 = Proposal.fromJson({
      'pid': 'test_proposal_0',
      'dateTime': "2023-05-23 21:35:06",
      'owner': {
        'name': 'Mario',
        'surname': 'Rossi',
        'uid': 'mario_rossi',
      },
      'place': {
        'id': '11694848',
        'name': 'Parco Suardi',
        'lat': 45.7,
        'lon': 9.6,
      },
      'participants': ['first_participant', 'second_participant'],
      'type': 'Public'
    });
    testProposal1 = Proposal.fromJson({
      'pid': 'test_proposal_1',
      'dateTime': "2023-05-23 21:35:06",
      'owner': {
        'name': 'Luigi',
        'surname': 'Verdi',
        'uid': 'luigi_verdi',
      },
      'place': {
        'id': '81252122',
        'name': 'Liceo Mascheroni',
        'lat': 45.70373305,
        'lon': 9.67972074,
      },
      'participants': ['another_participant'],
      'type': 'Friends'
    });
    testMapOptions = MapOptions(
      maxZoom: 18.4,
      zoom: 15,
      bounds: LatLngBounds(LatLng(45.8, 9.5), LatLng(45.6, 9.7)),
    );
    testMapController = MapController();
    testChildren = [
      MarkerLayer(
        key: const Key('TestChildrenMarkerLayer'),
        markers: [
          Marker(
            point: LatLng(45.7, 9.6),
            builder: (context) => Icon(
              Icons.place,
              color: Colors.red.shade100,
            ),
          )
        ],
      ),
      MarkerLayer(
        key: const Key('TestChildrenMarkerLayerDuplicate'),
        markers: [
          Marker(
            point: LatLng(45.75, 9.65),
            builder: (context) => Icon(
              Icons.place,
              color: Colors.blue.shade100,
            ),
          )
        ],
      ),
    ];
  });

  Widget widgetUnderTest(
      {required MapOptions mapOptions,
      List<Widget> children = const [],
      List<Proposal> proposalForMarkers = const [],
      MapController? mapController}) {
    return MaterialApp(
      home: CustomSmallMap(
        options: mapOptions,
        proposalsForMarkers: proposalForMarkers,
        mapController: mapController,
        children: children,
      ),
    );
  }

  group('basic layers', () {
    testWidgets('no proposal passed for markers', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(mapOptions: testMapOptions, mapController: testMapController));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('CustomSmallMapFlutterMap')), findsOneWidget);
        expect(find.byKey(const Key('CustomSmallMapTileLayer')), findsOneWidget);
        expect(find.byKey(const Key('CustomSmallMapMarkerLayer')), findsNothing);
      });
    });

    testWidgets('some proposals passed for markers', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(
            mapOptions: testMapOptions,
            mapController: testMapController,
            proposalForMarkers: [testProposal0, testProposal1]));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('CustomSmallMapFlutterMap')), findsOneWidget);
        expect(find.byKey(const Key('CustomSmallMapTileLayer')), findsOneWidget);
        expect(find.byKey(const Key('CustomSmallMapMarkerLayer')), findsOneWidget);
        expect(find.byKey(const Key('MarkerFromProposal_test_proposal_0')), findsOneWidget);
        expect(find.byKey(const Key('MarkerFromProposal_test_proposal_1')), findsOneWidget);
      });
    });
  });

  testWidgets('children', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest(
          mapOptions: testMapOptions,
          mapController: testMapController,
          children: testChildren));
      expect(find.byKey(const Key('CustomSmallMapFlutterMap')), findsOneWidget);
      expect(find.byKey(const Key('CustomSmallMapTileLayer')), findsOneWidget);
      expect(find.byKey(const Key('CustomSmallMapMarkerLayer')), findsNothing);
      expect(find.byKey(const Key('TestChildrenMarkerLayer')), findsOneWidget);
      expect(find.byKey(const Key('TestChildrenMarkerLayerDuplicate')), findsOneWidget);
    });
  });

  testWidgets('markers and colors', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest(
          mapOptions: testMapOptions,
          mapController: testMapController,
          proposalForMarkers: [testProposal0, testProposal1]));
      await tester.pumpAndSettle();
      Finder markerPublicIconFinder = find.byKey(const Key('MarkerFromProposal_test_proposal_0_Icon'));
      Finder markerFriendsIconFinder = find.byKey(const Key('MarkerFromProposal_test_proposal_1_Icon'));
      expect(markerPublicIconFinder, findsOneWidget);
      expect(markerFriendsIconFinder, findsOneWidget);
      Icon iconPublic = markerPublicIconFinder.evaluate().single.widget as Icon;
      Icon iconFriends = markerFriendsIconFinder.evaluate().single.widget as Icon;
      expect(iconPublic.color == iconFriends.color, false);
    });
  });

  testWidgets('map actions with default interactive flags', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest(
          mapOptions: testMapOptions,
          mapController: testMapController,
          proposalForMarkers: [testProposal0, testProposal1]));
      await tester.pump();
      Finder mapFinder = find.byKey(const Key('CustomSmallMapFlutterMap'));
      FlutterMap map = mapFinder.evaluate().single.widget as FlutterMap;
      MapController mapController = map.mapController!;
      double initialZoom = mapController.zoom;
      // on double tap should zoom in
      await tester.tap(mapFinder);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(mapFinder);
      await tester.pumpAndSettle();
      expect(mapController.zoom > initialZoom, true);
      // on drag should change position of the center
      LatLng initialCenter = mapController.center;
      await tester.drag(mapFinder, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(initialCenter == mapController.center, false);
      // on pinch out should zoom in
      initialZoom = mapController.zoom;
      // find center of widget
      Offset center = tester.getCenter(mapFinder);
      // define starting touches
      final touch1 = await tester.startGesture(center.translate(-10, 0));
      final touch2 = await tester.startGesture(center.translate(10, 10));
      // move touch points
      await touch1.moveBy(const Offset(-50, 0));
      await touch2.moveBy(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(mapController.zoom > initialZoom, true);
      // on pinch in should zoom out
      initialZoom = mapController.zoom;
      await touch1.moveBy(const Offset(50, 0));
      await touch2.moveBy(const Offset(-20, -20));
      expect(mapController.zoom < initialZoom, true);
    });
  });
}
