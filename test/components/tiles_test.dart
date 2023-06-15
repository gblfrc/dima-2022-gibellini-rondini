import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progetto/components/profile_picture.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/user.dart';

import 'profile_picture_test.mocks.dart';

main() {
  User user = User(uid: "xcvb", name: "Mario", surname: "Rossi");

  testWidgets('User tile', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
              home: Scaffold(
                  body: UserTile.fromUser(user, context, MockStorage())));
        })));
    final titleFinder = find.text('Mario Rossi');
    final imageFinder =
        find.byWidgetPredicate((widget) => widget is ProfilePicture);

    expect(titleFinder, findsOneWidget);
    expect(imageFinder, findsOneWidget);
  });
}
