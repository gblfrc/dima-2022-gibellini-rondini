import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/components/forms/login_form.dart';
import 'package:progetto/components/forms/registration_form.dart';
import 'package:progetto/pages/login_page.dart';

@GenerateNiceMocks([MockSpec<Database>(), MockSpec<Auth>()])
import 'login_page_test.mocks.dart';

main() {

  testWidgets('Login page', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: Builder(builder: (BuildContext context) {
          return Scaffold(body: LoginPage(database: MockDatabase(), auth: MockAuth()));
        }))));
    final pageFinder = find.byWidgetPredicate((widget) => widget is LoginPage);
    final loginFormFinder = find.byWidgetPredicate((widget) => widget is LoginForm && widget is! RegistrationForm);
    final toggleButtonFinder = find.byKey(const Key('GoToRegistrationButton'));
    final registrationFormFinder = find.byWidgetPredicate((widget) => widget is RegistrationForm);

    expect(pageFinder, findsOneWidget);
    expect(loginFormFinder, findsOneWidget);
    expect(registrationFormFinder, findsNothing);

    await tester.tap(toggleButtonFinder);
    await tester.pumpAndSettle();
    expect(registrationFormFinder, findsOneWidget);
    expect(loginFormFinder, findsNothing);
  });

}