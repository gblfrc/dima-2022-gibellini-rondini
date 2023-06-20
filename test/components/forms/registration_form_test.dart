import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/components/forms/custom_form_field.dart';
import 'package:progetto/components/forms/registration_form.dart';

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<Database>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
import 'registration_form_test.mocks.dart';

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late UserCredential mockCredentials;
  late User mockUser;
  late String testUid;
  late Function testToggle;
  late int testToggleCalls;

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockCredentials = MockUserCredential();
    mockUser = MockUser();
    testUid = 'text_uid';
    testToggleCalls = 0;
    testToggle = () {
      testToggleCalls++;
    };
  });

  Widget widgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: RegistrationForm(
          database: mockDatabase,
          auth: mockAuth,
          toggle: testToggle,
          // toggle: (){},
        ),
      ),
    );
  }

  tearDown(() {
    resetMockitoState();
  });

  testWidgets('basic components are shown', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('RegistrationFormActualForm')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormEmailFormField')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormPasswordFormField')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormNameFormField')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormSurnameFormField')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormBirthdayFormField')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormButton')), findsOneWidget);
    expect(find.byKey(const Key('RegistrationFormToLoginButton')), findsOneWidget);
    expect(find.text('Already registered?'), findsOneWidget);
  });

  testWidgets('toggle button calls toggle function', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('RegistrationFormToLoginButton')));
    await tester.pumpAndSettle();
    expect(testToggleCalls, 1);
  });

  group('missing values in form fields', () {
    testWidgets('missing name', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('RegistrationFormSurnameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormEmailFormField')), 'text@test.com');
      await tester.enterText(find.byKey(const Key('RegistrationFormPasswordFormField')), 'text');
      Finder nameFieldFinder = find.byKey(const Key('RegistrationFormNameFormField'));
      CustomFormField nameField = nameFieldFinder.evaluate().single.widget as CustomFormField;
      expect(nameField.controller.text, "");
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.text('Name field cannot be empty'), findsOneWidget);
      expect(find.text('Surname field cannot be empty'), findsNothing);
      expect(find.text('Email field cannot be empty'), findsNothing);
      expect(find.text('Illegal value for email field'), findsNothing);
      expect(find.text('Password field cannot be empty'), findsNothing);
    });
    testWidgets('missing surname', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('RegistrationFormNameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormEmailFormField')), 'text@test.com');
      await tester.enterText(find.byKey(const Key('RegistrationFormPasswordFormField')), 'text');
      Finder surnameFieldFinder = find.byKey(const Key('RegistrationFormSurnameFormField'));
      CustomFormField surnameField = surnameFieldFinder.evaluate().single.widget as CustomFormField;
      expect(surnameField.controller.text, "");
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.text('Name field cannot be empty'), findsNothing);
      expect(find.text('Surname field cannot be empty'), findsOneWidget);
      expect(find.text('Email field cannot be empty'), findsNothing);
      expect(find.text('Illegal value for email field'), findsNothing);
      expect(find.text('Password field cannot be empty'), findsNothing);
    });
    testWidgets('missing email', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('RegistrationFormNameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormSurnameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormPasswordFormField')), 'text');
      Finder emailFieldFinder = find.byKey(const Key('RegistrationFormEmailFormField'));
      CustomFormField emailField = emailFieldFinder.evaluate().single.widget as CustomFormField;
      expect(emailField.controller.text, "");
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.text('Name field cannot be empty'), findsNothing);
      expect(find.text('Surname field cannot be empty'), findsNothing);
      expect(find.text('Email field cannot be empty'), findsOneWidget);
      expect(find.text('Illegal value for email field'), findsNothing);
      expect(find.text('Password field cannot be empty'), findsNothing);
    });
    testWidgets('illegal email', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('RegistrationFormNameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormSurnameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormEmailFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormPasswordFormField')), 'text');
      Finder emailFieldFinder = find.byKey(const Key('RegistrationFormEmailFormField'));
      CustomFormField emailField = emailFieldFinder.evaluate().single.widget as CustomFormField;
      expect(emailField.controller.text, "text");
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.text('Name field cannot be empty'), findsNothing);
      expect(find.text('Surname field cannot be empty'), findsNothing);
      expect(find.text('Email field cannot be empty'), findsNothing);
      expect(find.text('Illegal value for email field'), findsOneWidget);
      expect(find.text('Password field cannot be empty'), findsNothing);
    });
    testWidgets('missing password', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('RegistrationFormNameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormSurnameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormEmailFormField')), 'text@test.com');
      Finder passwordFieldFinder = find.byKey(const Key('RegistrationFormPasswordFormField'));
      CustomFormField passwordField = passwordFieldFinder.evaluate().single.widget as CustomFormField;
      expect(passwordField.controller.text, "");
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.text('Name field cannot be empty'), findsNothing);
      expect(find.text('Surname field cannot be empty'), findsNothing);
      expect(find.text('Email field cannot be empty'), findsNothing);
      expect(find.text('Illegal value for email field'), findsNothing);
      expect(find.text('Password field cannot be empty'), findsOneWidget);
    });
    testWidgets('missing birthday', (WidgetTester tester) async {
      when(mockAuth.createUserWithEmailAndPassword(email: 'text', password: 'text'))
          .thenThrow(AuthenticationException('test'));
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('RegistrationFormNameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormSurnameFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormEmailFormField')), 'text');
      await tester.enterText(find.byKey(const Key('RegistrationFormPasswordFormField')), 'text');
      Finder birthdayFieldFinder = find.byKey(const Key('RegistrationFormBirthdayFormField'));
      DateTimeField birthdayField = birthdayFieldFinder.evaluate().single.widget as DateTimeField;
      expect(birthdayField.controller!.text, "");
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('MissingValuesSnackBar')), findsNothing);
    });
  });

  formFill(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('RegistrationFormNameFormField')), 'text');
    await tester.enterText(find.byKey(const Key('RegistrationFormSurnameFormField')), 'text');
    await tester.enterText(find.byKey(const Key('RegistrationFormEmailFormField')), 'text@test.com');
    await tester.enterText(find.byKey(const Key('RegistrationFormPasswordFormField')), 'text');
  }

  group('authentication', () {
    testWidgets('no error in registration', (WidgetTester tester) async {
      when(mockAuth.createUserWithEmailAndPassword(email: 'text@test.com', password: 'text'))
          .thenAnswer((realInvocation) => Future.value(mockCredentials));
      when(mockCredentials.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUid);
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await formFill(tester);
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('error in user creation on auth server', (WidgetTester tester) async {
      when(mockAuth.createUserWithEmailAndPassword(email: 'text@test.com', password: 'text'))
          .thenThrow(AuthenticationException('test'));
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await formFill(tester);
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('AuthenticationErrorSnackBar')), findsOneWidget);
    });

    testWidgets('error in connecting to database', (WidgetTester tester) async {
      when(mockAuth.createUserWithEmailAndPassword(email: 'text@test.com', password: 'text'))
          .thenAnswer((realInvocation) => Future.value(mockCredentials));
      when(mockCredentials.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUid);
      when(mockDatabase.createUser(uid: testUid, name: 'text', surname: 'text')).thenThrow(DatabaseException('test'));
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await formFill(tester);
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('DatabaseErrorSnackBar')), findsOneWidget);
    });
    testWidgets('error in connecting to database, error in deleting user', (WidgetTester tester) async {
      when(mockAuth.createUserWithEmailAndPassword(email: 'text@test.com', password: 'text'))
          .thenAnswer((realInvocation) => Future.value(mockCredentials));
      when(mockCredentials.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUid);
      when(mockDatabase.createUser(uid: testUid, name: 'text', surname: 'text')).thenThrow(DatabaseException('test'));
      when(mockAuth.deleteUser()).thenThrow(AuthenticationException('test'));
      await tester.pumpWidget(widgetUnderTest());
      await tester.pumpAndSettle();
      await formFill(tester);
      await tester.tap(find.byKey(const Key('RegistrationFormButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('DatabaseErrorSnackBar')), findsOneWidget);
    });
  });

  testWidgets('date can be erased, then picker shows current time', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    Finder birthdayFieldFinder = find.byKey(const Key('RegistrationFormBirthdayFormField'));
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
}
