import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/components/cards.dart';
import 'package:progetto/components/forms/edit_profile_form.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/model/goal.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/pages/account_page.dart';
import 'package:progetto/pages/edit_profile_page.dart';

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<Database>(),
  MockSpec<Storage>(),
  MockSpec<ImagePicker>(),
  MockSpec<auth.User>(),
])
import 'account_page_test.mocks.dart';

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late Storage mockStorage;
  late ImagePicker mockImagePicker;
  late auth.User mockUser;
  late User testCurrentUser;
  late User testOtherUser;
  late Proposal testProposal0;
  late Proposal testProposal1;
  late Session testSession0;
  late Session testSession1;
  late Goal testGoal0;
  late Goal testGoal1;
  Finder appBarFinder = find.byKey(const Key('AccountPageAppBar'));
  Finder actionButtonFinder = find.byKey(const Key('AccountPageAdditionalActionsButton'));
  Finder actionSnackbarFinder = find.byKey(const Key('AccountPageAdditionalActionsSnackBar'));
  Finder editProfileButtonFinder = find.byKey(const Key('AccountPageEditProfileButton'));
  Finder logoutButtonFinder = find.byKey(const Key('AccountPageLogoutButton'));
  Finder mainBodyFinder = find.byKey(const Key('AccountPageMainCaseBody'));
  Finder horizontalTabletBodyFinder = find.byKey(const Key('AccountPageHorizontalTabletBody'));
  Finder profileHeaderFinder = find.byKey(const Key('AccountPageProfileHeader'));
  Finder tabSectionTabBarFinder = find.byKey(const Key('AccountPageTabSectionTabBar'));
  Finder tabViewFinder = find.byKey(const Key('AccountPageTabSectionTabView'));
  Finder sessionTabFinder = find.byKey(const Key('AccountPageSessionTab'));
  Finder proposalTabFinder = find.byKey(const Key('AccountPageProposalTab'));
  Finder goalTabFinder = find.byKey(const Key('AccountPageGoalTab'));
  Finder sessionTabGridFinder = find.byKey(const Key('AccountPageSessionTabGrid'));
  Finder proposalTabListFinder = find.byKey(const Key('AccountPageProposalTabList'));
  Finder goalTabGridFinder = find.byKey(const Key('AccountPageGoalTabGrid'));
  Finder sessionTabBodyFinder = find.byKey(const Key('AccountPageSessionTabBody'), skipOffstage: false);
  Finder proposalTabBodyFinder = find.byKey(const Key('AccountPageProposalTabBody'));
  Finder goalTabBodyFinder = find.byKey(const Key('AccountPageGoalTabBody'));

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockStorage = MockStorage();
    mockImagePicker = MockImagePicker();
    mockUser = MockUser();
    testCurrentUser = User.fromJson({
      'name': 'Mario',
      'surname': 'Rossi',
      'uid': 'mario_rossi',
      'birthday': '1999-04-03',
    });
    testOtherUser = User.fromJson({
      'name': 'Luigi',
      'surname': 'Verdi',
      'uid': 'luigi_verdi',
    });
    testProposal0 = Proposal.fromJson({
      'pid': 'test_proposal_1',
      'dateTime': "2023-05-23 21:35:06",
      'owner': {
        'name': 'Mario',
        'surname': 'Rossi',
        'uid': 'mario_rossi',
      },
      'place': {
        'id': '11694848',
        'name': 'Parco Suardi',
        'lat': 45.4029422,
        'lon': 9.20194914,
      },
      'participants': ['second_participant'],
      'type': 'Public'
    });
    testProposal1 = Proposal.fromJson({
      'pid': 'test_proposal_1',
      'dateTime': "2023-06-30 18:15:00",
      'owner': {
        'name': 'Luigi',
        'surname': 'Verdi',
        'uid': 'luigi_verdi',
      },
      'place': {
        'id': '11694848',
        'name': 'Parco Suardi',
        'lat': 45.4029422,
        'lon': 9.20194914,
      },
      'participants': ['first_participant', 'third_participant'],
      'type': 'Public'
    });
    testSession0 = Session.fromJson({
      'id': 'test_session_0',
      'distance': 3419.99,
      'duration': 29514.53,
      'positions': [
        [
          LatLng(45, 9),
          LatLng(45.5, 9),
          LatLng(45.6, 9.1),
          LatLng(45.6, 9.2),
        ],
        [
          LatLng(45.8, 9.3),
          LatLng(46, 9.3),
        ]
      ],
      'start': DateTime(2023, 5, 23, 21, 35, 06),
    });
    testSession1 = Session.fromJson({
      'id': 'test_session_1',
      'distance': 3419.99,
      'duration': 29514.53,
      'positions': [
        [
          LatLng(45, 9),
          LatLng(45.6, 9.1),
          LatLng(45.6, 9.2),
        ],
      ],
      'start': DateTime(2023, 6, 21, 15, 12, 00),
    });
    testGoal0 = Goal.fromJson({
      'id': 'test',
      'owner': {'name': 'Mario', 'surname': 'Rossi', 'uid': 'mario_rossi'},
      'type': 'distanceGoal',
      'targetValue': 8.0,
      'currentValue': 5.3,
      'completed': false,
      'createdAt': DateTime(2023, 5, 23, 21, 35, 06),
    });
    testGoal1 = Goal.fromJson({
      'id': 'test',
      'owner': null,
      'type': 'distanceGoal',
      'targetValue': 8.0,
      'currentValue': 5.3,
      'completed': false,
      'createdAt': DateTime(2023, 5, 23, 21, 35, 06),
    });

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn(testCurrentUser.uid);
    when(mockDatabase.getUser(testCurrentUser.uid))
        .thenAnswer((realInvocation) => Stream.fromIterable([testCurrentUser]));
    when(mockDatabase.getUser(testOtherUser.uid)).thenAnswer((realInvocation) => Stream.fromIterable([testOtherUser]));
    when(mockDatabase.getProposalsByUser(testCurrentUser.uid)).thenAnswer((realInvocation) => Stream.fromIterable([
          [testProposal0, testProposal1]
        ]));
    when(mockDatabase.getProposalsByUser(testOtherUser.uid)).thenAnswer((realInvocation) => Stream.fromIterable([
          [testProposal0, testProposal1]
        ]));
    when(mockDatabase.getLatestSessionsByUser(testCurrentUser.uid)).thenAnswer((realInvocation) => Stream.fromIterable([
          [testSession0, testSession1]
        ]));
    when(mockDatabase.getLatestSessionsByUser(testOtherUser.uid)).thenAnswer((realInvocation) => Stream.fromIterable([
          [testSession0, testSession1]
        ]));
    when(mockDatabase.getGoals(testCurrentUser.uid, inProgressOnly: false))
        .thenAnswer((realInvocation) => Stream.fromIterable([
              [testGoal0, testGoal1]
            ]));
    when(mockDatabase.getGoals(testOtherUser.uid, inProgressOnly: false))
        .thenAnswer((realInvocation) => Stream.fromIterable([
              [testGoal1]
            ]));
  });

  tearDown(() {
    resetMockitoState();
  });

  Widget widgetUnderTest(String uid) {
    return MaterialApp(
      home: Scaffold(
        body: AccountPage(
          database: mockDatabase,
          auth: mockAuth,
          storage: mockStorage,
          imagePicker: mockImagePicker,
          uid: uid,
        ),
      ),
    );
  }


  group('basic layout', () {
    testWidgets('vertical phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(mainBodyFinder, findsOneWidget);
        expect(horizontalTabletBodyFinder, findsNothing);
        expect(profileHeaderFinder, findsOneWidget);
        expect(tabSectionTabBarFinder, findsOneWidget);
        expect(tabViewFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(3120, 1440);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(mainBodyFinder, findsOneWidget);
        expect(horizontalTabletBodyFinder, findsNothing);
        expect(profileHeaderFinder, findsOneWidget);
        expect(tabSectionTabBarFinder, findsOneWidget);
        expect(tabViewFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('vertical tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1800, 2560);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(mainBodyFinder, findsOneWidget);
        expect(horizontalTabletBodyFinder, findsNothing);
        expect(profileHeaderFinder, findsOneWidget);
        expect(tabSectionTabBarFinder, findsOneWidget);
        expect(tabViewFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(2560, 1800);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(mainBodyFinder, findsNothing);
        expect(horizontalTabletBodyFinder, findsOneWidget);
        expect(profileHeaderFinder, findsOneWidget);
        expect(tabSectionTabBarFinder, findsOneWidget);
        expect(tabViewFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('tabs and different users', () {
    testWidgets('current user', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(tabSectionTabBarFinder, findsOneWidget);
        expect(sessionTabFinder, findsOneWidget);
        expect(proposalTabFinder, findsOneWidget);
        expect(goalTabFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('other user', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testOtherUser.uid));
        await tester.pumpAndSettle();
        expect(tabSectionTabBarFinder, findsOneWidget);
        expect(sessionTabFinder, findsOneWidget);
        expect(proposalTabFinder, findsOneWidget);
        expect(goalTabFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('alternative outputs, tested on vertical phone', () {
    testWidgets('appbar text if user is current', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(find.descendant(of: appBarFinder, matching: find.text('My account')), findsOneWidget);
        expect(find.descendant(of: appBarFinder, matching: find.text('Account details')), findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('appbar text if user is different than current', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testOtherUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(find.descendant(of: appBarFinder, matching: find.text('My account')), findsNothing);
        expect(find.descendant(of: appBarFinder, matching: find.text('Account details')), findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('actions shown in snack bar for current user', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(actionButtonFinder, findsOneWidget);
        await tester.tap(actionButtonFinder);
        await tester.pumpAndSettle();
        expect(actionSnackbarFinder, findsOneWidget);
        expect(logoutButtonFinder, findsOneWidget);
        expect(editProfileButtonFinder, findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('actions shown in snack bar for current user', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testOtherUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(actionButtonFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('edit profile different output', () {
    testWidgets('on phone push edit profile page - vertical', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(actionButtonFinder, findsOneWidget);
        await tester.tap(actionButtonFinder);
        await tester.pumpAndSettle();
        expect(actionSnackbarFinder, findsOneWidget);
        expect(logoutButtonFinder, findsOneWidget);
        expect(editProfileButtonFinder, findsOneWidget);
        await tester.tap(editProfileButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(EditProfilePage), findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('on phone push edit profile page - horizontal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(3120, 1440);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(actionButtonFinder, findsOneWidget);
        await tester.tap(actionButtonFinder);
        await tester.pumpAndSettle();
        expect(actionSnackbarFinder, findsOneWidget);
        expect(logoutButtonFinder, findsOneWidget);
        expect(editProfileButtonFinder, findsOneWidget);
        await tester.tap(editProfileButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(EditProfilePage), findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('on tablet display dialog with edit profile form, vertical', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1800, 2560);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(actionButtonFinder, findsOneWidget);
        await tester.tap(actionButtonFinder);
        await tester.pumpAndSettle();
        expect(actionSnackbarFinder, findsOneWidget);
        expect(logoutButtonFinder, findsOneWidget);
        expect(editProfileButtonFinder, findsOneWidget);
        await tester.tap(editProfileButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.descendant(of: find.byType(Dialog), matching: find.byType(EditProfileForm)), findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('on tablet display dialog with edit profile form, horizontal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(2560, 1800);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(actionButtonFinder, findsOneWidget);
        await tester.tap(actionButtonFinder);
        await tester.pumpAndSettle();
        expect(actionSnackbarFinder, findsOneWidget);
        expect(logoutButtonFinder, findsOneWidget);
        expect(editProfileButtonFinder, findsOneWidget);
        await tester.tap(editProfileButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.descendant(of: find.byType(Dialog), matching: find.byType(EditProfileForm)), findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  testWidgets('logout button works', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      tester.binding.window.physicalSizeTestValue = const Size(1800, 2560);
      await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
      await tester.pumpAndSettle();
      expect(appBarFinder, findsOneWidget);
      expect(actionButtonFinder, findsOneWidget);
      await tester.tap(actionButtonFinder);
      await tester.pumpAndSettle();
      expect(actionSnackbarFinder, findsOneWidget);
      expect(logoutButtonFinder, findsOneWidget);
      expect(editProfileButtonFinder, findsOneWidget);
      await tester.tap(logoutButtonFinder);
      await tester.pumpAndSettle();
      verify(mockAuth.signOut()).called(1);
    });
  });

  group('session tab', () {
    testWidgets('session tab shows session cards', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        await tester.tap(proposalTabFinder);
        await tester.pumpAndSettle();
        // select first another tab to verify behavior upon entering session tab
        expect(sessionTabBodyFinder, findsNothing);
        expect(proposalTabBodyFinder, findsOneWidget);
        expect(goalTabBodyFinder, findsNothing);
        // show session tab
        await tester.tap(sessionTabFinder);
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsOneWidget);
        expect(sessionTabGridFinder, findsOneWidget);
        expect(proposalTabBodyFinder, findsNothing);
        expect(goalTabBodyFinder, findsNothing);
        // check session tab grid contains 2 session cards
        expect(find.descendant(of: sessionTabBodyFinder, matching: sessionTabGridFinder), findsOneWidget);
        expect(find.descendant(of: sessionTabGridFinder, matching: find.byType(SessionCard)), findsNWidgets(2));
        expect(find.descendant(of: sessionTabBodyFinder, matching: find.text("You haven't completed any session yet.")),
            findsNothing);
        expect(
            find.descendant(of: sessionTabBodyFinder, matching: find.text("An error occurred while loading sessions.")),
            findsNothing);
      });
    });
    testWidgets('session tab with no session cards', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.getLatestSessionsByUser(testCurrentUser.uid))
            .thenAnswer((realInvocation) => Stream.fromIterable([[]]));
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsOneWidget);
        expect(sessionTabGridFinder, findsNothing);
        expect(proposalTabBodyFinder, findsNothing);
        expect(goalTabBodyFinder, findsNothing);
        expect(find.descendant(of: sessionTabBodyFinder, matching: sessionTabGridFinder), findsNothing);
        expect(find.descendant(of: sessionTabGridFinder, matching: find.byType(SessionCard)), findsNothing);
        expect(find.descendant(of: sessionTabBodyFinder, matching: find.text("You haven't completed any session yet.")),
            findsOneWidget);
        expect(
            find.descendant(of: sessionTabBodyFinder, matching: find.text("An error occurred while loading sessions.")),
            findsNothing);
      });
    });
    testWidgets('error in retrieving sessions', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.getLatestSessionsByUser(testCurrentUser.uid))
            .thenAnswer((invocation) => Stream.error(DatabaseException('test')));
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsOneWidget);
        expect(sessionTabGridFinder, findsNothing);
        expect(proposalTabBodyFinder, findsNothing);
        expect(goalTabBodyFinder, findsNothing);
        expect(find.descendant(of: sessionTabBodyFinder, matching: sessionTabGridFinder), findsNothing);
        expect(find.descendant(of: sessionTabGridFinder, matching: find.byType(SessionCard)), findsNothing);
        expect(find.descendant(of: sessionTabBodyFinder, matching: find.text("You haven't completed any session yet.")),
            findsNothing);
        expect(
            find.descendant(of: sessionTabBodyFinder, matching: find.text("An error occurred while loading sessions.")),
            findsOneWidget);
      });
    });
  });

  group('proposal tab', () {
    testWidgets('no proposals received', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.getProposalsByUser(testCurrentUser.uid))
            .thenAnswer((realInvocation) => Stream.fromIterable([[]]));
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        await tester.tap(proposalTabFinder);
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsNothing);
        expect(proposalTabBodyFinder, findsOneWidget);
        expect(proposalTabListFinder, findsNothing);
        expect(goalTabBodyFinder, findsNothing);
        // check proposal tab list contains 2 proposal tiles
        expect(find.descendant(of: proposalTabBodyFinder, matching: proposalTabListFinder), findsNothing);
        expect(find.descendant(of: proposalTabListFinder, matching: find.byType(ProposalTile)), findsNothing);
        expect(find.descendant(of: proposalTabBodyFinder, matching: find.text("No proposal made up to now.")),
            findsOneWidget);
        expect(
            find.descendant(
                of: proposalTabBodyFinder, matching: find.text("An error occurred while loading proposals.")),
            findsNothing);
      });
    });
    testWidgets('error when loading proposals', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.getProposalsByUser(testCurrentUser.uid))
            .thenAnswer((realInvocation) => Stream.error(DatabaseException('test')));
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        await tester.tap(proposalTabFinder);
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsNothing);
        expect(proposalTabBodyFinder, findsOneWidget);
        expect(proposalTabListFinder, findsNothing);
        expect(goalTabBodyFinder, findsNothing);
        // check proposal tab list contains 2 proposal tiles
        expect(find.descendant(of: proposalTabBodyFinder, matching: proposalTabListFinder), findsNothing);
        expect(find.descendant(of: proposalTabListFinder, matching: find.byType(ProposalTile)), findsNothing);
        expect(find.descendant(of: proposalTabBodyFinder, matching: find.text("No proposal made up to now.")),
            findsNothing);
        expect(
            find.descendant(
                of: proposalTabBodyFinder, matching: find.text("An error occurred while loading proposals.")),
            findsOneWidget);
      });
    });
  });

  group('goal tab', () {
    testWidgets('goal tab shows goal cards', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        await tester.tap(goalTabFinder);
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsNothing);
        expect(proposalTabBodyFinder, findsNothing);
        expect(goalTabBodyFinder, findsOneWidget);
        expect(goalTabGridFinder, findsOneWidget);
        // check proposal tab list contains 2 proposal tiles
        expect(find.descendant(of: goalTabBodyFinder, matching: goalTabGridFinder), findsOneWidget);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.byType(GoalCard)), findsNWidgets(2));
        expect(find.descendant(of: goalTabBodyFinder, matching: find.text("No goal set up to now.")), findsNothing);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.text("An error occurred while loading goals.")),
            findsNothing);
      });
    });
    testWidgets('no goals received when querying', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.getGoals(testCurrentUser.uid, inProgressOnly: false))
            .thenAnswer((realInvocation) => Stream.fromIterable([[]]));
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        await tester.tap(goalTabFinder);
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsNothing);
        expect(proposalTabBodyFinder, findsNothing);
        expect(goalTabBodyFinder, findsOneWidget);
        expect(goalTabGridFinder, findsNothing);
        // check proposal tab list contains 2 proposal tiles
        expect(find.descendant(of: goalTabBodyFinder, matching: goalTabGridFinder), findsNothing);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.byType(GoalCard)), findsNothing);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.text("No goal set up to now.")), findsOneWidget);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.text("An error occurred while loading goals.")),
            findsNothing);
      });
    });
    testWidgets('error when accessing database for goals', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.getGoals(testCurrentUser.uid, inProgressOnly: false))
            .thenAnswer((realInvocation) => Stream.error(DatabaseException('test')));
        tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
        await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
        await tester.pumpAndSettle();
        await tester.tap(goalTabFinder);
        await tester.pumpAndSettle();
        expect(sessionTabBodyFinder, findsNothing);
        expect(proposalTabBodyFinder, findsNothing);
        expect(goalTabBodyFinder, findsOneWidget);
        expect(goalTabGridFinder, findsNothing);
        // check proposal tab list contains 2 proposal tiles
        expect(find.descendant(of: goalTabBodyFinder, matching: goalTabGridFinder), findsNothing);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.byType(GoalCard)), findsNothing);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.text("No goal set up to now.")), findsNothing);
        expect(find.descendant(of: goalTabBodyFinder, matching: find.text("An error occurred while loading goals.")),
            findsOneWidget);
      });
    });

  });
}
