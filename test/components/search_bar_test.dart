import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progetto/components/search_bar.dart';

main() {
  String input = "";
  Widget testWidget = MediaQuery(
      data: const MediaQueryData(),
      child: Builder(builder: (BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                body: SearchBar(
                    key: const Key('InputBar'),
                    onChanged: (text) => input = text)));
      }));
  testWidgets('Search bar - text inserted and then overwritten',
      (tester) async {
    await tester.pumpWidget(testWidget);
    Finder inputBar = find.byKey(const Key('InputBar'));
    await tester.enterText(inputBar, "Test text");
    expect(input, "Test text");
    await tester.enterText(inputBar, "Other text");
    expect(input, "Other text");
  });

  testWidgets('Search bar - text inserted and then cleared', (tester) async {
    await tester.pumpWidget(testWidget);
    Finder inputBar = find.byKey(const Key('InputBar'));
    Finder clearIcon = find.byKey(const Key('ClearIcon'));
    await tester.enterText(inputBar, "Test text");
    expect(input, "Test text");
    await tester.tap(clearIcon);
    expect(input, "");
  });
}
