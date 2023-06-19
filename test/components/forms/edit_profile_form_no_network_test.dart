import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/components/forms/edit_profile_form.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'edit_profile_form_test.mocks.dart';

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late Storage mockStorage;
  late ImagePicker mockImagePicker;
  late auth.User mockAuthUser;
  late User testUser;

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockStorage = MockStorage();
    mockAuthUser = MockUser();
    mockImagePicker = MockImagePicker();
    testUser = User.fromJson({'name': 'Mario', 'surname': 'Rossi', 'uid': 'mario_rossi', 'birthday': '1999-04-03'});
    when(mockAuth.currentUser).thenReturn(mockAuthUser);
    when(mockAuth.authStateChanges).thenAnswer((realInvocation) => Stream.fromIterable([mockAuthUser]));
    when(mockAuthUser.uid).thenReturn(testUser.uid);
  });

  Widget widgetUnderTest({required User user, Axis direction = Axis.vertical}) {
    return MaterialApp(
      home: Scaffold(
        body: EditProfileForm(
          storage: mockStorage,
          auth: mockAuth,
          database: mockDatabase,
          user: user,
          direction: direction,
          imagePicker: mockImagePicker,
        ),
      ),
    );
  }



    testWidgets('exception is thrown when attempting to obtain url', (WidgetTester tester) async {
      when(mockStorage.downloadURL("profile-pictures/${testUser.uid}"))
          .thenAnswer((realInvocation) => Future.error(StorageException('test')));
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('EditProfileImageSection')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormImageOrAccountIcon')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormProfilePicture')), findsNothing);
      expect(find.byKey(const Key('EditProfileFormAccountIcon')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormLocalImage')), findsNothing);
    });

    testWidgets('url is obtained correctly but image has error on loading', (WidgetTester tester) async {
      when(mockStorage.downloadURL("profile-pictures/${testUser.uid}"))
          .thenAnswer((realInvocation) => Future.value('test'));
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('EditProfileImageSection')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormImageOrAccountIcon')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormProfilePicture')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormAccountIcon')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormLocalImage')), findsNothing);
    });

}
