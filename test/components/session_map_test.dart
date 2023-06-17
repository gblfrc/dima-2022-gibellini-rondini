import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/components/session_map.dart';
import 'package:progetto/model/session.dart';

main() {
  late Session testSession;

  setUp(() {
    testSession = Session.fromJson({
      'id': 'test_session',
      'distance': 182.01853264834955,
      'duration': 42.859,
      'positions': [
        [
          LatLng(37.36, 122.07),
          LatLng(37.37, 122.08),
          LatLng(37.39, 122.08),
          LatLng(37.40, 122.08),
        ],
        [
          LatLng(37.41, 122.07),
          LatLng(37.42, 122.08),
          LatLng(37.42, 122.10),
        ]
      ],
      'start': DateTime(2023, 6, 15, 10, 12, 33),
      'owner': null
    });
  });

  Widget widgetUnderTest(Session session, {bool useMarkers = true, int? interactiveFlags}) {
    return MaterialApp(
      home: SessionMap(
        session: session,
        useMarkers: useMarkers,
        interactiveFlags: interactiveFlags,
      ),
    );
  }

  group('basic tests', () {
    testWidgets('all map layers', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testSession, useMarkers: true));
        await tester.pump();
        expect(find.byKey(const Key('SessionMapFlutterMap')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapTileLayer')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapPolylineLayer')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapMarkerLayer')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapMarkerStart')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapMarkerEnd')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapMarkerStartIcon')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapMarkerEndIcon')), findsOneWidget);
      });
    });
    testWidgets('do not use markers', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testSession, useMarkers: false));
        await tester.pump();
        expect(find.byKey(const Key('SessionMapFlutterMap')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapTileLayer')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapPolylineLayer')), findsOneWidget);
        expect(find.byKey(const Key('SessionMapMarkerLayer')), findsNothing);
        expect(find.byKey(const Key('SessionMapMarkerStart')), findsNothing);
        expect(find.byKey(const Key('SessionMapMarkerEnd')), findsNothing);
        expect(find.byKey(const Key('SessionMapMarkerStartIcon')), findsNothing);
        expect(find.byKey(const Key('SessionMapMarkerEndIcon')), findsNothing);
      });
    });
  });

  testWidgets('map properties', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest(testSession, useMarkers: false));
      await tester.pump();
      Finder mapFinder = find.byKey(const Key('SessionMapFlutterMap'));
      // map widget exists
      expect(mapFinder, findsOneWidget);
      // map has bounds and map controller
      FlutterMap map = mapFinder.evaluate().single.widget as FlutterMap;
      expect(map.mapController, isNotNull);
      expect(map.options.bounds, isNotNull);
      expect(map.mapController?.bounds, isNotNull);
    });
  });

  testWidgets('boundary test, all positions in session should lie inside bounds', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest(testSession, useMarkers: false));
      await tester.pump();
      expect(find.byKey(const Key('SessionMapFlutterMap')), findsOneWidget);
      FlutterMap map = find.byKey(const Key('SessionMapFlutterMap')).evaluate().single.widget as FlutterMap;
      LatLngBounds bounds = map.options.bounds!;
      List<LatLng> positions = testSession.positions[0]..addAll(testSession.positions[1]);
      for (LatLng position in positions) {
        expect(bounds.contains(position), true);
      }
    });
  });

  group('interactive flags', () {
    testWidgets('image actions with default interactive flags', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testSession, useMarkers: false));
        await tester.pump();
        Finder mapFinder = find.byKey(const Key('SessionMapFlutterMap'));
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
        await touch1.moveBy(const Offset(-50,0));
        await touch2.moveBy(const Offset(20,20));
        await tester.pumpAndSettle();
        expect(mapController.zoom > initialZoom, true);
        // on pinch in should zoom out
        initialZoom = mapController.zoom;
        await touch1.moveBy(const Offset(50, 0));
        await touch2.moveBy(const Offset(-20,-20));
        expect(mapController.zoom < initialZoom, true);
      });
    });
    testWidgets('image actions with interactive flags set to none', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testSession, useMarkers: false,interactiveFlags: InteractiveFlag.none));
        await tester.pump();
        Finder mapFinder = find.byKey(const Key('SessionMapFlutterMap'));
        FlutterMap map = mapFinder.evaluate().single.widget as FlutterMap;
        MapController mapController = map.mapController!;
        double initialZoom = mapController.zoom;
        // on double tap should zoom in
        await tester.tap(mapFinder);
        await tester.pump(kDoubleTapMinTime);
        await tester.tap(mapFinder);
        await tester.pumpAndSettle();
        expect(mapController.zoom == initialZoom, true);
        // on drag should change position of the center
        LatLng initialCenter = mapController.center;
        await tester.drag(mapFinder, const Offset(500, 0));
        await tester.pumpAndSettle();
        expect(initialCenter == mapController.center, true);
        // on pinch out should zoom in
        initialZoom = mapController.zoom;
        // find center of widget
        Offset center = tester.getCenter(mapFinder);
        // define starting touches
        final touch1 = await tester.startGesture(center.translate(-10, 0));
        final touch2 = await tester.startGesture(center.translate(10, 10));
        // move touch points
        await touch1.moveBy(const Offset(-50,0));
        await touch2.moveBy(const Offset(20,20));
        await tester.pumpAndSettle();
        expect(mapController.zoom == initialZoom, true);
        // on pinch in should zoom out
        initialZoom = mapController.zoom;
        await touch1.moveBy(const Offset(50, 0));
        await touch2.moveBy(const Offset(-20,-20));
        expect(mapController.zoom == initialZoom, true);
      });
    });
  });
}
