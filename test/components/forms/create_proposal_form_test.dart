import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/components/forms/create_proposal_form.dart';
import 'package:progetto/model/place.dart';

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<Database>(),
  MockSpec<SearchEngine>(),
  MockSpec<User>(),
])
import 'create_proposal_form_test.mocks.dart';

main() {
  late Auth auth;
  late Database database;
  late SearchEngine searchEngine;
  late User mockUser;
  late Place testPlace;
  const String testUid = 'mario_rossi';
  late int propagationCalls;
  propagateLocationFunction(place) {
    propagationCalls++;
  }

  Finder setLocationTextFinder = find.byKey(const Key('CreateProposalFormSetLocationText'));
  Finder locationFieldFinder = find.byKey(const Key('CreateProposalFormLocationField'));
  Finder setDateTimeTextFinder = find.byKey(const Key('CreateProposalFormSetDateTimeText'));
  Finder dateFieldFinder = find.byKey(const Key('CreateProposalFormDateField'));
  Finder timeFieldFinder = find.byKey(const Key('CreateProposalFormTimeField'));
  Finder openToTextFinder = find.byKey(const Key('CreateProposalFormOpenToText'));
  Finder privacyFieldFinder = find.byKey(const Key('CreateProposalFormPrivacyField'));
  Finder creationButtonFinder = find.byKey(const Key('CreateProposalFormCreationButton'));
  Finder dropdownItemPublicFinder = find.byKey(const Key('DropdownItemPublic'));
  Finder dropdownItemFriendsFinder = find.byKey(const Key('DropdownItemFriends'));
  late Finder testPlaceListTileFinder;

  setUp(() {
    auth = MockAuth();
    database = MockDatabase();
    searchEngine = MockSearchEngine();
    mockUser = MockUser();
    propagationCalls = 0;
    testPlace = Place(id: 'test_place', name: 'Parco Suardi', coords: LatLng(45.7, 9.6));
    testPlaceListTileFinder = find.byKey(Key('LocationListTile_${testPlace.name}'));
    when(auth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('mario_rossi');
  });

  Widget widgetUnderTest({Function(Place?)? propagateLocation}) {
    return MaterialApp(
      home: Scaffold(
        body: CreateProposalForm(
          auth: auth,
          database: database,
          searchEngine: searchEngine,
          propagateLocation: propagateLocation,
        ),
      ),
    );
  }

  testWidgets('all basic components are present', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    expect(setLocationTextFinder, findsOneWidget);
    expect(locationFieldFinder, findsOneWidget);
    expect(setDateTimeTextFinder, findsOneWidget);
    expect(dateFieldFinder, findsOneWidget);
    expect(timeFieldFinder, findsOneWidget);
    expect(openToTextFinder, findsOneWidget);
    expect(privacyFieldFinder, findsOneWidget);
    expect(creationButtonFinder, findsOneWidget);
    expect(testPlaceListTileFinder, findsNothing);
  });

  testWidgets('location propagation is called, location can be set and removed', (WidgetTester tester) async {
    when(searchEngine.getPlacesByName('test')).thenAnswer((invocation) => Future.value([testPlace]));
    await tester.pumpWidget(widgetUnderTest(propagateLocation: propagateLocationFunction));
    await tester.pumpAndSettle();
    // set location
    await tester.enterText(locationFieldFinder, 'test');
    await tester.pumpAndSettle();
    expect(testPlaceListTileFinder, findsOneWidget);
    await tester.tap(testPlaceListTileFinder);
    await tester.pumpAndSettle();
    expect(testPlaceListTileFinder, findsNothing);
    TypeAheadFormField locationField = locationFieldFinder.evaluate().single.widget as TypeAheadFormField;
    expect(locationField.textFieldConfiguration.controller!.text, testPlace.name);
    expect(propagationCalls, 1);
    // remove location
    await tester.tap(find.descendant(of: locationFieldFinder, matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(locationField.textFieldConfiguration.controller!.text, "");
    expect(propagationCalls, 2);
  });

  testWidgets('date selection and deletion', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    // open date picker and select date
    await tester.tap(dateFieldFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    DateTimeField dateField = dateFieldFinder.evaluate().single.widget as DateTimeField;
    expect(dateField.controller!.text, isNot(""));
    // tap on icon to remove date
    await tester.tap(find.descendant(of: dateFieldFinder, matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(dateField.controller!.text, "");
  });

  testWidgets('time selection and deletion', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    // open time picker and select time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
    DateTimeField timeField = timeFieldFinder.evaluate().single.widget as DateTimeField;
    expect(timeField.controller!.text, isNot(""));
    // tap on icon to remove time
    await tester.tap(find.descendant(of: timeFieldFinder, matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(timeField.controller!.text, "");
  });

  testWidgets('time selection, time already present', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    // open time picker and select time
    DateTimeField timeField = timeFieldFinder.evaluate().single.widget as DateTimeField;
    timeField.controller!.text = "14:20";
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
    expect(timeField.controller!.text, "14:20");
  });

  testWidgets('privacy selection', (WidgetTester tester) async {
    await tester.pumpWidget(widgetUnderTest());
    await tester.pumpAndSettle();
    DropdownButton<String> dropdownButton = privacyFieldFinder.evaluate().single.widget as DropdownButton<String>;
    expect(dropdownButton.value, 'Public');
    // tap on friends item
    await tester.tap(privacyFieldFinder);
    await tester.pumpAndSettle();
    expect(dropdownItemPublicFinder, findsNWidgets(2));
    expect(dropdownItemFriendsFinder, findsNWidgets(2));
    // NOTE: it is the correct behavior in flutter to have twice the number of items
    // One of the two items in the IndexedStack of the dropdown menu, the other one is the one shown
    await tester.tap(dropdownItemFriendsFinder.last);
    await tester.pumpAndSettle();
    dropdownButton = privacyFieldFinder.evaluate().single.widget as DropdownButton<String>;
    expect(dropdownButton.value, 'Friends');
    // tap on public item
    await tester.tap(privacyFieldFinder);
    await tester.pumpAndSettle();
    expect(dropdownItemPublicFinder, findsNWidgets(2));
    expect(dropdownItemFriendsFinder, findsNWidgets(2));
    await tester.tap(dropdownItemPublicFinder.last);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    dropdownButton = privacyFieldFinder.evaluate().single.widget as DropdownButton<String>;
    expect(dropdownButton.value, 'Public');
  });

  initializeAndFillForm(WidgetTester tester) async {
    when(searchEngine.getPlacesByName('test')).thenAnswer((invocation) => Future.value([testPlace]));
    await tester.pumpWidget(widgetUnderTest(propagateLocation: propagateLocationFunction));
    await tester.pumpAndSettle();
    // set location
    await tester.enterText(locationFieldFinder, 'test');
    await tester.pumpAndSettle();
    expect(testPlaceListTileFinder, findsOneWidget);
    await tester.tap(testPlaceListTileFinder);
    await tester.pumpAndSettle();
    expect(testPlaceListTileFinder, findsNothing);
    TypeAheadFormField locationField = locationFieldFinder.evaluate().single.widget as TypeAheadFormField;
    expect(locationField.textFieldConfiguration.controller!.text, testPlace.name);
    // set date
    await tester.tap(dateFieldFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    DateTimeField dateField = dateFieldFinder.evaluate().single.widget as DateTimeField;
    expect(dateField.controller!.text, isNot(""));
    // set time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
    DateTimeField timeField = timeFieldFinder.evaluate().single.widget as DateTimeField;
    expect(timeField.controller!.text, isNot(""));
    // set privacy
    await tester.tap(privacyFieldFinder);
    await tester.pumpAndSettle();
    expect(dropdownItemPublicFinder, findsNWidgets(2));
    expect(dropdownItemFriendsFinder, findsNWidgets(2));
    await tester.tap(dropdownItemFriendsFinder.last);
    await tester.pumpAndSettle();
    DropdownButton<String> dropdownButton = privacyFieldFinder.evaluate().single.widget as DropdownButton<String>;
    expect(dropdownButton.value, 'Friends');
  }

  group('proposal creation and validation', () {
    testWidgets('correct creation of the proposal', (WidgetTester tester) async {
      await initializeAndFillForm(tester);
      expect(creationButtonFinder, findsOneWidget);
      expect(dateFieldFinder, findsOneWidget);
      DateTimeField dateField = dateFieldFinder.evaluate().single.widget as DateTimeField;
      DateTime date = DateFormat.yMd().parse(dateField.controller!.text);
      DateTimeField timeField = timeFieldFinder.evaluate().single.widget as DateTimeField;
      TimeOfDay time = TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeField.controller!.text));
      DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      when(database.createProposal(
              dateTime: dateTime,
              ownerId: testUid,
              placeLatitude: testPlace.coords.latitude,
              placeLongitude: testPlace.coords.longitude,
              placeId: testPlace.id,
              placeName: testPlace.name,
              placeCity: testPlace.city,
              placeState: testPlace.state,
              placeCountry: testPlace.country,
              placeType: testPlace.type,
              type: 'Friends'))
          .thenReturn(null);
      await tester.tap(creationButtonFinder);
      await tester.pump();
      expect(find.byKey(const Key('SuccessfulProposalCreationSnackBar')), findsOneWidget);
    });

    testWidgets('illegal location', (WidgetTester tester) async {
      await initializeAndFillForm(tester);
      await tester.tap(find.descendant(of: locationFieldFinder, matching: find.byType(IconButton)));
      await tester.pumpAndSettle();
      await tester.tap(creationButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text('Please, propose a location'), findsOneWidget);
      expect(find.text('Please, enter a date'), findsNothing);
      expect(find.text('Please, enter a time'), findsNothing);
    });
    testWidgets('illegal date', (WidgetTester tester) async {
      await initializeAndFillForm(tester);
      await tester.tap(find.descendant(of: dateFieldFinder, matching: find.byType(IconButton)));
      await tester.pumpAndSettle();
      await tester.tap(creationButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text('Please, propose a location'), findsNothing);
      expect(find.text('Please, enter a date'), findsOneWidget);
      expect(find.text('Please, enter a time'), findsNothing);
    });
    testWidgets('illegal time', (WidgetTester tester) async {
      await initializeAndFillForm(tester);
      await tester.tap(find.descendant(of: timeFieldFinder, matching: find.byType(IconButton)));
      await tester.pumpAndSettle();
      await tester.tap(creationButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text('Please, propose a location'), findsNothing);
      expect(find.text('Please, enter a date'), findsNothing);
      expect(find.text('Please, enter a time'), findsOneWidget);
    });

    testWidgets('error while saving proposal', (WidgetTester tester) async {
      await initializeAndFillForm(tester);
      await tester.pumpAndSettle();
      DateTimeField dateField = dateFieldFinder.evaluate().single.widget as DateTimeField;
      DateTime date = DateFormat.yMd().parse(dateField.controller!.text);
      DateTimeField timeField = timeFieldFinder.evaluate().single.widget as DateTimeField;
      TimeOfDay time = TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeField.controller!.text));
      DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      when(database.createProposal(
              dateTime: dateTime,
              ownerId: testUid,
              placeLatitude: testPlace.coords.latitude,
              placeLongitude: testPlace.coords.longitude,
              placeId: testPlace.id,
              placeName: testPlace.name,
              placeCity: testPlace.city,
              placeState: testPlace.state,
              placeCountry: testPlace.country,
              placeType: testPlace.type,
              type: 'Friends'))
          .thenThrow(DatabaseException('test'));
      await tester.tap(creationButtonFinder);
      await tester.pump();
      expect(find.byKey(const Key('ErrorInProposalCreationSnackBar')), findsOneWidget);
    });
  });
}
