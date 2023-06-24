import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/location_handler.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/pages/session_page.dart';

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<Database>(),
  MockSpec<LocationHandler>(),
  MockSpec<User>(),
])
import 'session_page_test.mocks.dart';

class ErrorMockDatabase extends Mock implements Database {
  @override
  Future<void> saveSession(
      {required String uid,
      required List<List<LatLng>> positions,
      required double distance,
      required double duration,
      required DateTime startDT,
      String? proposalId}) async {
    return Future.error(DatabaseException('test'));
  }
}

class CustomMockLocationHandler extends Mock implements LocationHandler {
  static Position testPosition0 = Position(
      longitude: 9.6,
      latitude: 45.7,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);
  static Position testPosition1 = Position(
      longitude: 9.7,
      latitude: 45.8,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);

  @override
  Future<Position> getCurrentPosition() {
    return Future.value(testPosition0);
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    return Stream.fromFutures([
      Future.delayed(const Duration(seconds: 5), () => Future.value(testPosition0)),
      Future.delayed(const Duration(seconds: 10), () => Future.value(testPosition1)),
      Future.delayed(const Duration(seconds: 15), () => Future.value(testPosition0)),
      Future.delayed(const Duration(seconds: 20), () => Future.value(testPosition1)),
      Future.delayed(const Duration(seconds: 25), () => Future.value(testPosition0)),
      Future.delayed(const Duration(seconds: 30), () => Future.value(testPosition1)),
    ]);
  }
}

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late LocationHandler mockLocationHandler;
  late User mockUser;
  late Position testPosition;
  Finder phoneLayoutFinder = find.byKey(const Key('SessionPagePhoneLayout'));
  Finder tabletLayoutFinder = find.byKey(const Key('SessionPageTabletLayout'));
  Finder phoneInfoBoxFinder = find.byKey(const Key('SessionPagePhoneInfoBox'));
  Finder tabletInfoBoxFinder = find.byKey(const Key('SessionPageTabletInfoBox'));
  Finder durationInfoFinder = find.byKey(const Key('SessionPageDurationInfo'));
  Finder distanceInfoFinder = find.byKey(const Key('SessionPageDistanceInfo'));
  Finder mapFinder = find.byKey(const Key('SessionPageMap'));
  Finder errorTextFinder = find.byKey(const Key('SessionPageErrorOnPositionText'));
  Finder startButtonFinder = find.byKey(const Key('SessionPageStartButton'));
  Finder stopButtonFinder = find.byKey(const Key('SessionPageStopButton'));
  Finder resumeButtonFinder = find.byKey(const Key('SessionPageResumeButton'));
  Finder pauseButtonFinder = find.byKey(const Key('SessionPagePauseButton'));

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockLocationHandler = MockLocationHandler();
    mockUser = MockUser();
    testPosition = CustomMockLocationHandler.testPosition0;
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_uid');
    when(mockLocationHandler.getCurrentPosition()).thenAnswer((realInvocation) => Future.value(testPosition));
    when(mockLocationHandler.getPositionStream()).thenAnswer((realInvocation) => Stream.fromIterable([]));
  });

  Widget widgetUnderTest({Proposal? proposal}) {
    return MaterialApp(
      home: Scaffold(
        body: SessionPage(
          auth: mockAuth,
          database: mockDatabase,
          locationHandler: mockLocationHandler,
          proposal: proposal,
        ),
      ),
    );
  }

  group('basic layout', () {
    testWidgets('vertical phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(phoneLayoutFinder, findsOneWidget);
        expect(tabletLayoutFinder, findsNothing);
        expect(phoneInfoBoxFinder, findsOneWidget);
        expect(tabletInfoBoxFinder, findsNothing);
        expect(durationInfoFinder, findsOneWidget);
        expect(distanceInfoFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(startButtonFinder, findsOneWidget);
        expect(stopButtonFinder, findsNothing);
        expect(pauseButtonFinder, findsNothing);
        expect(resumeButtonFinder, findsNothing);
      });
    });
    testWidgets('horizontal phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(3120, 1440);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(phoneLayoutFinder, findsOneWidget);
        expect(tabletLayoutFinder, findsNothing);
        expect(phoneInfoBoxFinder, findsOneWidget);
        expect(tabletInfoBoxFinder, findsNothing);
        expect(durationInfoFinder, findsOneWidget);
        expect(distanceInfoFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(startButtonFinder, findsOneWidget);
        expect(stopButtonFinder, findsNothing);
        expect(pauseButtonFinder, findsNothing);
        expect(resumeButtonFinder, findsNothing);
      });
    });
    testWidgets('vertical tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1800, 2560);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(phoneLayoutFinder, findsNothing);
        expect(tabletLayoutFinder, findsOneWidget);
        expect(phoneInfoBoxFinder, findsNothing);
        expect(tabletInfoBoxFinder, findsOneWidget);
        expect(durationInfoFinder, findsOneWidget);
        expect(distanceInfoFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(startButtonFinder, findsOneWidget);
        expect(stopButtonFinder, findsNothing);
        expect(pauseButtonFinder, findsNothing);
        expect(resumeButtonFinder, findsNothing);
      });
    });
    testWidgets('horizontal tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(2560, 1800);
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(phoneLayoutFinder, findsNothing);
        expect(tabletLayoutFinder, findsOneWidget);
        expect(phoneInfoBoxFinder, findsNothing);
        expect(tabletInfoBoxFinder, findsOneWidget);
        expect(durationInfoFinder, findsOneWidget);
        expect(distanceInfoFinder, findsOneWidget);
        expect(mapFinder, findsOneWidget);
        expect(startButtonFinder, findsOneWidget);
        expect(stopButtonFinder, findsNothing);
        expect(pauseButtonFinder, findsNothing);
        expect(resumeButtonFinder, findsNothing);
      });
    });
  });

  testWidgets('button updates', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      expect(startButtonFinder, findsOneWidget);
      expect(pauseButtonFinder, findsNothing);
      expect(stopButtonFinder, findsNothing);
      expect(resumeButtonFinder, findsNothing);
      await tester.tap(startButtonFinder);
      await tester.pumpAndSettle();
      expect(startButtonFinder, findsNothing);
      expect(pauseButtonFinder, findsOneWidget);
      expect(stopButtonFinder, findsOneWidget);
      expect(resumeButtonFinder, findsNothing);
      await tester.tap(pauseButtonFinder);
      await tester.pumpAndSettle();
      expect(startButtonFinder, findsNothing);
      expect(pauseButtonFinder, findsNothing);
      expect(stopButtonFinder, findsOneWidget);
      expect(resumeButtonFinder, findsOneWidget);
      await tester.tap(resumeButtonFinder);
      await tester.pumpAndSettle();
      expect(startButtonFinder, findsNothing);
      expect(pauseButtonFinder, findsOneWidget);
      expect(stopButtonFinder, findsOneWidget);
      expect(resumeButtonFinder, findsNothing);
      await tester.tap(stopButtonFinder);
      await tester.pumpAndSettle();
      expect(startButtonFinder, findsOneWidget);
      expect(pauseButtonFinder, findsNothing);
      expect(stopButtonFinder, findsNothing);
      expect(resumeButtonFinder, findsNothing);
    });
  });

  group('initialization', () {
    testWidgets('position service access denied', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockLocationHandler.getCurrentPosition())
            .thenAnswer((realInvocation) => Future.error(PermissionDeniedException));
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        expect(mapFinder, findsNothing);
        expect(errorTextFinder, findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
    testWidgets('ongoing initialization', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockLocationHandler.getCurrentPosition()).thenAnswer(
            (realInvocation) => Future.delayed(const Duration(seconds: 5), () => Future.value(testPosition)));
        await tester.pumpWidget(widgetUnderTest());
        await tester.pump();
        expect(mapFinder, findsNothing);
        expect(errorTextFinder, findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
      });
    });
  });

  testWidgets('position update', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      mockLocationHandler = CustomMockLocationHandler();
      await tester.pumpWidget(widgetUnderTest());
      await tester.pump(const Duration(seconds: 10));
      FlutterMap map = mapFinder.evaluate().single.widget as FlutterMap;
      expect(map.mapController!.center.latitude, CustomMockLocationHandler.testPosition1.latitude);
      expect(map.mapController!.center.longitude, CustomMockLocationHandler.testPosition1.longitude);
      // consume all pending timers
      await tester.pump(const Duration(minutes: 1));
    });
  });

  testWidgets('normal behavior when tracking session', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      mockLocationHandler = CustomMockLocationHandler();
      await tester.pumpWidget(widgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      expect(startButtonFinder, findsOneWidget);
      await tester.tap(startButtonFinder);
      await tester.pump(const Duration(seconds: 1));
      expect(startButtonFinder, findsNothing);
      expect(pauseButtonFinder, findsOneWidget);
      expect(stopButtonFinder, findsOneWidget);
      expect(resumeButtonFinder, findsNothing);
      await tester.pump(const Duration(seconds: 10));
      FlutterMap map = mapFinder.evaluate().single.widget as FlutterMap;
      expect(map.mapController!.center.latitude, CustomMockLocationHandler.testPosition1.latitude);
      expect(map.mapController!.center.longitude, CustomMockLocationHandler.testPosition1.longitude);
      await tester.tap(pauseButtonFinder);
      await tester.pump(const Duration(seconds: 2));
      expect(startButtonFinder, findsNothing);
      expect(pauseButtonFinder, findsNothing);
      expect(stopButtonFinder, findsOneWidget);
      expect(resumeButtonFinder, findsOneWidget);
      await tester.tap(resumeButtonFinder);
      await tester.pump(const Duration(seconds: 25));
      expect(map.mapController!.center.latitude, CustomMockLocationHandler.testPosition1.latitude);
      expect(map.mapController!.center.longitude, CustomMockLocationHandler.testPosition1.longitude);
      await tester.tap(stopButtonFinder);
      await tester.pump(const Duration(minutes: 1));
    });
  });

  group('session saving', () {
    testWidgets('correct behavior', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        mockLocationHandler = CustomMockLocationHandler();
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        await tester.tap(startButtonFinder);
        await tester.pump(const Duration(seconds: 10));
        await tester.tap(stopButtonFinder);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.descendant(of: find.byType(SnackBar), matching: find.text('Session saved successfully!')),
            findsOneWidget);
        await tester.pump(const Duration(minutes: 1));
      });
    });
    testWidgets('error in saving', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        mockLocationHandler = CustomMockLocationHandler();
        mockDatabase = ErrorMockDatabase();
        await tester.pumpWidget(widgetUnderTest());
        await tester.pumpAndSettle();
        await tester.tap(startButtonFinder);
        await tester.pump(const Duration(seconds: 10));
        await tester.tap(stopButtonFinder);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.descendant(of: find.byType(SnackBar), matching: find.text('An error occurred when saving the session.')),
            findsOneWidget);
        await tester.pump(const Duration(minutes: 1));
      });
    });
  });
}
