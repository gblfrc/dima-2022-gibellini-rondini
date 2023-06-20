import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/forms/custom_form_field.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/components/forms/edit_profile_form.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<auth.User>(),
  MockSpec<Database>(),
  MockSpec<Storage>(),
  MockSpec<ImagePicker>(),
  MockSpec<File>(),
  MockSpec<HttpClient>(),
])
import 'edit_profile_form_test.mocks.dart';

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late Storage mockStorage;
  late ImagePicker mockImagePicker;
  late File testLocalImageFile;
  late auth.User mockAuthUser;
  late User testUser;
  const String testLocalImagePath = "assets/test/flutter_logo.png";

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockStorage = MockStorage();
    mockAuthUser = MockUser();
    mockImagePicker = MockImagePicker();
    testUser = User.fromJson({'name': 'Mario', 'surname': 'Rossi', 'uid': 'mario_rossi', 'birthday': '1999-04-03'});
    testLocalImageFile = File(testLocalImagePath);
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

  group('form orientation', () {
    testWidgets('vertical form', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(user: testUser, direction: Axis.vertical));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('VerticalEditProfileForm')), findsOneWidget);
        expect(find.byKey(const Key('HorizontalEditProfileForm')), findsNothing);
        expect(find.byKey(const Key('EditProfileImageSection')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileDataSection')), findsOneWidget);
      });
    });
    testWidgets('horizontal form', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(user: testUser, direction: Axis.horizontal));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('VerticalEditProfileForm')), findsNothing);
        expect(find.byKey(const Key('HorizontalEditProfileForm')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileImageSection')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileDataSection')), findsOneWidget);
      });
    });
  });

  group('image section', () {
    testWidgets('displays all basic components', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(user: testUser));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('EditProfileImageSection')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileFormImageOrAccountIcon')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileFormPickPictureButton')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileFormSavePictureButton')), findsOneWidget);
      });
    });

    testWidgets('profile picture already set and image available', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(user: testUser));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('EditProfileImageSection')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileFormImageOrAccountIcon')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileFormProfilePicture')), findsOneWidget);
        expect(find.byKey(const Key('EditProfileFormAccountIcon')), findsNothing);
        expect(find.byKey(const Key('EditProfileFormLocalImage')), findsNothing);
      });
    });

    group('profile section buttons', () {
      testWidgets('save picture button, no image was selected', (WidgetTester tester) async {
        mockNetworkImagesFor(() async {
          await tester.pumpWidget(widgetUnderTest(user: testUser));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('EditProfileFormSavePictureButton')));
          await tester.pump();
          expect(find.byKey(const Key('NotPickedImageSnackBar')), findsOneWidget);
        });
      });

      testWidgets('pick image button, image is selected and saved correctly', (WidgetTester tester) async {
        mockNetworkImagesFor(() async {
          when(mockImagePicker.pickImage()).thenAnswer((realInvocation) => Future.value(testLocalImagePath));
          await tester.pumpWidget(widgetUnderTest(user: testUser));
          await tester.pumpAndSettle();
          // pick image
          await tester.tap(find.byKey(const Key('EditProfileFormPickPictureButton')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('EditProfileFormLocalImage')), findsOneWidget);
          expect(find.byKey(const Key('EditProfileFormProfilePicture')), findsNothing);
          expect(find.byKey(const Key('EditProfileFormAccountIcon')), findsNothing);
          expect(find.byKey(const Key('SuccessfulImageSelectionSnackBar')), findsOneWidget);
          // save image
          await tester.tap(find.byKey(const Key('EditProfileFormSavePictureButton')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('SuccessfullySavedImageSnackBar')), findsOneWidget);
        });
      });
      testWidgets('image is selected but cannot be saved', (WidgetTester tester) async {
        IOOverrides.runZoned(() async {
          mockNetworkImagesFor(() async {
            when(mockImagePicker.pickImage()).thenAnswer((realInvocation) => Future.value(testLocalImagePath));
            when(mockStorage.uploadFile(testLocalImageFile, "profile-pictures/${testUser.uid}"))
                .thenThrow(StorageException('test'));
            await tester.pumpWidget(widgetUnderTest(user: testUser));
            await tester.pumpAndSettle();
            // pick image
            await tester.tap(find.byKey(const Key('EditProfileFormPickPictureButton')));
            await tester.pumpAndSettle();
            expect(find.byKey(const Key('EditProfileFormLocalImage')), findsOneWidget);
            expect(find.byKey(const Key('EditProfileFormProfilePicture')), findsNothing);
            expect(find.byKey(const Key('EditProfileFormAccountIcon')), findsNothing);
            expect(find.byKey(const Key('SuccessfulImageSelectionSnackBar')), findsOneWidget);
            // save image
            await tester.tap(find.byKey(const Key('EditProfileFormSavePictureButton')));
            await tester.pumpAndSettle();
            expect(find.byKey(const Key('ErrorInSavingImageSnackBar')), findsOneWidget);
          });
        }, createFile: (String path) => testLocalImageFile);
      });

      testWidgets('select picture but pick files returns null (aborted selection)', (WidgetTester tester) async {
        mockNetworkImagesFor(() async {
          when(mockImagePicker.pickImage()).thenAnswer((realInvocation) => Future.value(null));
          await tester.pumpWidget(widgetUnderTest(user: testUser));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('EditProfileFormPickPictureButton')));
          await tester.pump();
          expect(find.byKey(const Key('NoImageSelectedSnackBar')), findsOneWidget);
        });
      });
    });
  });

  group('form', () {
    testWidgets('all basic elements are present and default values are set', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('EditProfileFormNameField')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormSurnameField')), findsOneWidget);
      expect(find.byKey(const Key('EditProfileFormBirthdayField')), findsOneWidget);
      // default values coincide with user's data
      CustomFormField nameField =
          find.byKey(const Key('EditProfileFormNameField')).evaluate().single.widget as CustomFormField;
      CustomFormField surnameField =
          find.byKey(const Key('EditProfileFormSurnameField')).evaluate().single.widget as CustomFormField;
      DateTimeField birthdayField =
          find.byKey(const Key('EditProfileFormBirthdayField')).evaluate().single.widget as DateTimeField;
      expect(nameField.controller.text, testUser.name);
      expect(surnameField.controller.text, testUser.surname);
      DateTime birthday = DateFormat.yMd().parse(birthdayField.controller!.text);
      expect(birthday.year, testUser.birthday!.year);
      expect(birthday.month, testUser.birthday!.month);
      expect(birthday.day, testUser.birthday!.day);
      // scroll list to see update button
      await tester.scrollUntilVisible(find.byKey(const Key('EditProfileFormUpdateButton')), 500,
          scrollable: find
              .descendant(
                  of: find.byKey(const Key('EditProfileFormDataSectionScrollable')), matching: find.byType(Scrollable))
              .first);
      expect(find.byKey(const Key('EditProfileFormUpdateButton')), findsOneWidget);
    });

    testWidgets('date picker is shown', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      Finder birthdayFieldFinder = find.byKey(const Key('EditProfileFormBirthdayField'));
      await tester.tap(birthdayFieldFinder);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('date can be erased, then picker shows current time', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      Finder birthdayFieldFinder = find.byKey(const Key('EditProfileFormBirthdayField'));
      Finder resetIcon = find.descendant(of: birthdayFieldFinder, matching: find.byType(Icon));
      DateTimeField birthdayField = birthdayFieldFinder.evaluate().single.widget as DateTimeField;
      await tester.tap(resetIcon);
      await tester.pumpAndSettle();
      expect(birthdayField.controller!.text, "");
      await tester.tap(birthdayFieldFinder);
      await tester.pumpAndSettle();
      Finder datePickerFinder = find.byType(DatePickerDialog);
      DatePickerDialog datePickerDialog = datePickerFinder.evaluate().single.widget as DatePickerDialog;
      expect(datePickerDialog.currentDate.year, DateTime.now().year);
      expect(datePickerDialog.currentDate.month, DateTime.now().month);
      expect(datePickerDialog.currentDate.day, DateTime.now().day);
    });

    testWidgets('error occurs while updating', (WidgetTester tester) async {
      when(mockDatabase.updateUser(testUser)).thenThrow(DatabaseException('test'));
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      Finder scrollable = find
          .descendant(
              of: find.byKey(const Key('EditProfileFormDataSectionScrollable')), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byKey(const Key('EditProfileFormUpdateButton')), 500.0,
          scrollable: scrollable);
      await tester.tap(find.byKey(const Key('EditProfileFormUpdateButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ErrorInUserUpdateSnackBar')), findsOneWidget);
      expect(find.byKey(const Key('SuccessfulUpdateSnackBar')), findsNothing);
    });
    testWidgets('successful update', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      Finder scrollable = find
          .descendant(
              of: find.byKey(const Key('EditProfileFormDataSectionScrollable')), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byKey(const Key('EditProfileFormUpdateButton')), 500.0,
          scrollable: scrollable);
      await tester.tap(find.byKey(const Key('EditProfileFormUpdateButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ErrorInUserUpdateSnackBar')), findsNothing);
      expect(find.byKey(const Key('SuccessfulUpdateSnackBar')), findsOneWidget);
    });
    testWidgets('try to update with empty date', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      // empty date field
      Finder birthdayFieldFinder = find.byKey(const Key('EditProfileFormBirthdayField'));
      Finder resetIcon = find.descendant(of: birthdayFieldFinder, matching: find.byType(Icon));
      await tester.tap(resetIcon);
      await tester.pumpAndSettle();
      // scroll to find update button and tap on it
      Finder scrollable = find
          .descendant(
              of: find.byKey(const Key('EditProfileFormDataSectionScrollable')), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byKey(const Key('EditProfileFormUpdateButton')), 500.0,
          scrollable: scrollable);
      await tester.tap(find.byKey(const Key('EditProfileFormUpdateButton')));
      await tester.pumpAndSettle();
      // should update successfully and user birthday should be null
      expect(find.byKey(const Key('ErrorInUserUpdateSnackBar')), findsNothing);
      expect(find.byKey(const Key('SuccessfulUpdateSnackBar')), findsOneWidget);
      expect(testUser.birthday, null);
    });

    testWidgets('cannot update with empty name', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      // empty name field
      Finder nameFieldFinder = find.byKey(const Key('EditProfileFormNameField'));
      Finder resetIcon = find.descendant(of: nameFieldFinder, matching: find.byType(Icon));
      CustomFormField nameField = nameFieldFinder.evaluate().single.widget as CustomFormField;
      await tester.tap(resetIcon);
      await tester.pumpAndSettle();
      expect(nameField.controller.text, "");
      // scroll to find update button and tap on it
      Finder scrollable = find
          .descendant(
              of: find.byKey(const Key('EditProfileFormDataSectionScrollable')), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byKey(const Key('EditProfileFormUpdateButton')), 500.0,
          scrollable: scrollable);
      await tester.tap(find.byKey(const Key('EditProfileFormUpdateButton')));
      await tester.pumpAndSettle();
      // should update successfully and user birthday should be null
      expect(find.byKey(const Key('ErrorInUserUpdateSnackBar')), findsNothing);
      expect(find.byKey(const Key('SuccessfulUpdateSnackBar')), findsNothing);
      expect(find.text('Name field cannot be empty.'), findsOneWidget);
      expect(find.text('Surname field cannot be empty.'), findsNothing);
    });
    testWidgets('cannot update with empty surname', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(user: testUser));
      await tester.pumpAndSettle();
      // empty surname field
      Finder surnameFieldFinder = find.byKey(const Key('EditProfileFormSurnameField'));
      Finder resetIcon = find.descendant(of: surnameFieldFinder, matching: find.byType(Icon));
      CustomFormField surnameField = surnameFieldFinder.evaluate().single.widget as CustomFormField;
      await tester.tap(resetIcon);
      await tester.pumpAndSettle();
      expect(surnameField.controller.text, "");
      // scroll to find update button and tap on it
      Finder scrollable = find
          .descendant(
              of: find.byKey(const Key('EditProfileFormDataSectionScrollable')), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byKey(const Key('EditProfileFormUpdateButton')), 500.0,
          scrollable: scrollable);
      await tester.tap(find.byKey(const Key('EditProfileFormUpdateButton')));
      await tester.pumpAndSettle();
      // should update successfully and user birthday should be null
      expect(find.byKey(const Key('ErrorInUserUpdateSnackBar')), findsNothing);
      expect(find.byKey(const Key('SuccessfulUpdateSnackBar')), findsNothing);
      expect(find.text('Name field cannot be empty.'), findsNothing);
      expect(find.text('Surname field cannot be empty.'), findsOneWidget);
    });
  });
}
