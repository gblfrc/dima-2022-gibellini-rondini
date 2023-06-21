import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/components/forms/edit_profile_form.dart';
import 'package:progetto/pages/edit_profile_page.dart';
import 'package:progetto/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<auth.User>(),
  MockSpec<Database>(),
  MockSpec<Storage>(),
  MockSpec<ImagePicker>(),
])
import 'edit_profile_page_test.mocks.dart';

main() {
  late Database database;
  late Auth mockAuth;
  late Storage storage;
  late ImagePicker imagePicker;
  late auth.User mockAuthUser;
  late User testUser;
  const String testImageUrl = 'testUrl';
  Finder appBarFinder = find.byKey(const Key('EditProfilePageAppBar'));
  Finder formFinder = find.byKey(const Key('EditProfilePageForm'));

  setUp(() {
    database = MockDatabase();
    mockAuth = MockAuth();
    storage = MockStorage();
    imagePicker = MockImagePicker();
    mockAuthUser = MockUser();
    testUser = User.fromJson({'name': 'Mario', 'surname': 'Rossi', 'uid': 'mario_rossi', 'birthday': '1999-04-03'});
    when(mockAuth.currentUser).thenReturn(mockAuthUser);
    when(mockAuthUser.uid).thenReturn(testUser.uid);
    when(storage.downloadURL("profile_pictures/${testUser.uid}"))
        .thenAnswer((invocation) => Future.value(testImageUrl));
  });

  Widget widgetUnderTest() {
    return MaterialApp(
      home: EditProfilePage(
        user: testUser,
        database: database,
        auth: mockAuth,
        storage: storage,
        imagePicker: imagePicker,
      ),
    );
  }

  testWidgets('components are present', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    expect(appBarFinder, findsOneWidget);
    expect(find.descendant(of: appBarFinder, matching: find.text('Edit profile')), findsOneWidget);
    expect(formFinder, findsOneWidget);
  });

  group('orientation', () {
    testWidgets('landscape screen orientation, horizontal form', (WidgetTester tester) async {
      // default size is 800*600 for flutter widget testing
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      expect(formFinder, findsOneWidget);
      EditProfileForm form = formFinder.evaluate().single.widget as EditProfileForm;
      expect(form.direction, Axis.horizontal);
    });
    testWidgets('portrait screen orientation, vertical form', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(600,800); // rotated default size
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      expect(formFinder, findsOneWidget);
      EditProfileForm form = formFinder.evaluate().single.widget as EditProfileForm;
      expect(form.direction, Axis.vertical);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
