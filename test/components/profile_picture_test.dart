import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/profile_picture.dart';

@GenerateNiceMocks([MockSpec<Storage>()])
import 'profile_picture_test.mocks.dart';

main() {
  late String testUrl;
  late String testUid;
  late Storage storage;

  setUp(() async {
    testUrl = "https://thisisatest.com/test.png";
    testUid = 'test_uid';
    storage = MockStorage();
  });

  tearDown(() {
    reset(storage);
  });

  Widget widgetUnderTest(String uid) {
    return MaterialApp(
      title: 'Test',
      home: ProfilePicture(
        uid: uid,
        storage: storage,
      ),
    );
  }

  group('url can be fetched', () {
    testWidgets('error while loading image', (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(storage.downloadURL(testUid))
            .thenAnswer((invocation) => Future.value(testUrl));
        await tester.pumpWidget(widgetUnderTest(testUid));
        await tester.pump(const Duration(seconds: 2));
        //every time a setState is called, it is necessary to re-pump the widget
        await tester.pump();
        expect(find.byKey(const ValueKey('CircleAvatarBorder')), findsNothing);
        expect(find.byKey(const ValueKey('CircleAvatarImage')), findsNothing);
        expect(find.byKey(const ValueKey('IconReplacingCircleAvatar')),
            findsOneWidget);
      });
    });

    testWidgets('image can be displayed', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await mockNetworkImagesFor(() async {
          when(storage.downloadURL(testUid))
              .thenAnswer((invocation) => Future.value(testUrl));
          await tester.pumpWidget(widgetUnderTest(testUid));
          // await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();
          expect(
              find.byKey(const ValueKey('CircleAvatarBorder')), findsOneWidget);
          expect(
              find.byKey(const ValueKey('CircleAvatarImage')), findsOneWidget);
          expect(find.byKey(const ValueKey('IconReplacingCircleAvatar')),
              findsNothing);
        });
      });
    });
  });

  testWidgets('error while downloading url', (WidgetTester tester) async {
    await tester.runAsync(() async {
      when(storage.downloadURL(testUid)).thenThrow(StorageException('test'));
      await tester.pumpWidget(widgetUnderTest(testUid));
      expect(find.byKey(const ValueKey('CircleAvatarBorder')), findsNothing);
      expect(find.byKey(const ValueKey('CircleAvatarImage')), findsNothing);
      expect(find.byKey(const ValueKey('IconReplacingCircleAvatar')),
          findsOneWidget);
    });
  });
}
