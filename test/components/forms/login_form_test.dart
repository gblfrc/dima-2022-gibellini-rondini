import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/components/forms/login_form.dart';

@GenerateNiceMocks([MockSpec<Auth>(), MockSpec<UserCredential>()])
import 'login_form_test.mocks.dart';

main() {
  late MockAuth auth;
  late String loginEmail;
  late String loginPassword;
  late UserCredential credentials;
  late bool toggleCalled;

  setUp(() {
    auth = MockAuth();
    toggleCalled = false;
  });

  void toggleFunction() {
    toggleCalled = true;
  }

  Widget testWidget() {
    return MaterialApp(
      home: Scaffold(
        body: LoginForm(
          auth: auth,
          toggle: toggleFunction,
        ),
      ),
    );
  }

  group('Login form - no error', () {
    setUp(() {
      when(auth.signInWithEmailAndPassword(
          email: "user@example.com", password: "password1234"))
          .thenAnswer((realInvocation) async {
        credentials = MockUserCredential();
        loginEmail = realInvocation.namedArguments[const Symbol('email')];
        loginPassword = realInvocation.namedArguments[const Symbol('password')];
        return credentials;
      });
    });

    testWidgets('Login form - valid credentials', (tester) async {
      await tester.pumpWidget(testWidget());
      final emailField = find.byKey(const Key('Username'));
      final passwordField = find.byKey(const Key('Password'));
      final loginButton = find.byKey(const Key('LoginButton'));
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'password1234');
      await tester.tap(loginButton);
      expect(loginEmail, 'user@example.com');
      expect(loginPassword, 'password1234');
    });

    testWidgets('Login form - tap on toggle button', (tester) async {
      await tester.pumpWidget(testWidget());
      final toggleButton = find.byKey(const Key('GoToRegistrationButton'));
      await tester.tap(toggleButton);
      expect(toggleCalled, true);
    });
  });

  group('Login form - Database error', () {
    setUp(() {
      when(auth.signInWithEmailAndPassword(
          email: "user@example.com", password: "password1234")).thenThrow(AuthenticationException("Random error"));
    });

    testWidgets('Login form - error handling', (tester) async {
      await tester.pumpWidget(testWidget());
      final emailField = find.byKey(const Key('Username'));
      final passwordField = find.byKey(const Key('Password'));
      final loginButton = find.byKey(const Key('LoginButton'));
      final errorSnackBar = find.byKey(const Key('ErrorSnackBar'));
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'password1234');
      await tester.tap(loginButton);
      await tester.pump();

      expect(errorSnackBar, findsOneWidget);
    });
  });
}
