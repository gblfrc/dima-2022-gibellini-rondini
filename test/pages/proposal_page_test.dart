import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/model/user.dart' as model;
import 'package:progetto/pages/proposal_page.dart';

@GenerateNiceMocks([
  MockSpec<Auth>(),
  MockSpec<Database>(),
  MockSpec<Storage>(),
  MockSpec<User>(),
])
import 'proposal_page_test.mocks.dart';

main() {
  late Auth mockAuth;
  late Database mockDatabase;
  late Storage mockStorage;
  late User mockUser;
  late Proposal testProposal0;
  late Proposal testProposal1;
  late model.User testUser0;
  late model.User testUser1;
  Finder appBarFinder = find.byKey(const Key('ProposalPageAppBar'));
  Finder deleteIconFinder = find.byKey(const Key('ProposalPageDeleteIcon'));
  Finder verticalBodyFinder = find.byKey(const Key('ProposalPageVerticalBody'));
  Finder horizontalBodyFinder = find.byKey(const Key('ProposalPageHorizontalBody'));
  Finder verticalMapSectionFinder = find.byKey(const Key('ProposalPageVerticalMapSection'));
  Finder horizontalMapSectionFinder = find.byKey(const Key('ProposalPageHorizontalMapSection'));
  Finder verticalInfoSectionFinder = find.byKey(const Key('ProposalPageVerticalInfoSection'));
  Finder horizontalInfoSectionFinder = find.byKey(const Key('ProposalPageHorizontalInfoSection'));
  Finder horizontalInfoScrollableFinder = find.byKey(const Key('ProposalPageHorizontalInfoScrollable'));
  Finder locationTileFinder = find.byKey(const Key('ProposalPageLocationTile'));
  Finder ownerTileFinder = find.byKey(const Key('ProposalPageOwnerTile'));
  Finder participantGridFinder = find.byKey(const Key('ProposalPageOwnerTile'));
  Finder joinButtonFinder = find.byKey(const Key('ProposalPageJoinButton'));
  Finder leaveButtonFinder = find.byKey(const Key('ProposalPageLeaveButton'));
  Finder removalDialogFinder = find.byKey(const Key('ProposalPageRemovalDialog'));

  setUp(() {
    mockAuth = MockAuth();
    mockDatabase = MockDatabase();
    mockStorage = MockStorage();
    mockUser = MockUser();
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
      'participants': ['luigi_verdi'],
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
      'participants': ['mario_rossi'],
      'type': 'Public'
    });
    testUser0 = testProposal0.owner;
    testUser1 = testProposal1.owner;
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('mario_rossi');
    when(mockDatabase.getUser(testUser0.uid)).thenAnswer((realInvocation) => Stream.fromIterable([testUser0]));
    when(mockDatabase.getUser(testUser1.uid)).thenAnswer((realInvocation) => Stream.fromIterable([testUser1]));
  });

  Widget widgetUnderTest(Proposal proposal) {
    return MaterialApp(
      home: Scaffold(
        body: ProposalPage(
          proposal: proposal,
          auth: mockAuth,
          database: mockDatabase,
          storage: mockStorage,
        ),
      ),
    );
  }

  group('basic components and orientation', () {
    // all proposals in this group are owned by the current user
    testWidgets('vertical phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(600, 800);
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(deleteIconFinder, findsOneWidget);
        expect(verticalBodyFinder, findsOneWidget);
        expect(horizontalBodyFinder, findsNothing);
        expect(verticalMapSectionFinder, findsOneWidget);
        expect(horizontalMapSectionFinder, findsNothing);
        expect(verticalInfoSectionFinder, findsOneWidget);
        expect(find.text('Scheduled for '), findsOneWidget);
        expect(find.text('Open to '), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Organizer'), findsOneWidget);
        expect(find.text('Participants'), findsOneWidget);
        expect(find.text('No user has already joined the training.'), findsNothing);
        expect(horizontalInfoSectionFinder, findsNothing);
        expect(horizontalInfoScrollableFinder, findsNothing);
        expect(locationTileFinder, findsOneWidget);
        expect(ownerTileFinder, findsOneWidget);
        expect(participantGridFinder, findsOneWidget);
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('vertical tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(1800, 2560);
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(deleteIconFinder, findsOneWidget);
        expect(verticalBodyFinder, findsOneWidget);
        expect(horizontalBodyFinder, findsNothing);
        expect(verticalMapSectionFinder, findsOneWidget);
        expect(horizontalMapSectionFinder, findsNothing);
        expect(verticalInfoSectionFinder, findsOneWidget);
        expect(find.text('Scheduled for '), findsOneWidget);
        expect(find.text('Open to '), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Organizer'), findsOneWidget);
        expect(find.text('Participants'), findsOneWidget);
        expect(find.text('No user has already joined the training.'), findsNothing);
        expect(horizontalInfoSectionFinder, findsNothing);
        expect(horizontalInfoScrollableFinder, findsNothing);
        expect(locationTileFinder, findsOneWidget);
        expect(ownerTileFinder, findsOneWidget);
        expect(participantGridFinder, findsOneWidget);
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal tablet', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(2560, 1800);
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(deleteIconFinder, findsOneWidget);
        expect(verticalBodyFinder, findsNothing);
        expect(horizontalBodyFinder, findsOneWidget);
        expect(verticalMapSectionFinder, findsNothing);
        expect(horizontalMapSectionFinder, findsOneWidget);
        expect(verticalInfoSectionFinder, findsNothing);
        expect(find.text('Scheduled for '), findsOneWidget);
        expect(find.text('Open to '), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Organizer'), findsOneWidget);
        expect(find.text('Participants'), findsOneWidget);
        expect(find.text('No user has already joined the training.'), findsNothing);
        expect(horizontalInfoSectionFinder, findsOneWidget);
        expect(horizontalInfoScrollableFinder, findsOneWidget);
        expect(locationTileFinder, findsOneWidget);
        expect(ownerTileFinder, findsOneWidget);
        expect(participantGridFinder, findsOneWidget);
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('horizontal phone', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(appBarFinder, findsOneWidget);
        expect(deleteIconFinder, findsOneWidget);
        expect(verticalBodyFinder, findsNothing);
        expect(horizontalBodyFinder, findsOneWidget);
        expect(verticalMapSectionFinder, findsNothing);
        expect(horizontalMapSectionFinder, findsOneWidget);
        expect(verticalInfoSectionFinder, findsNothing);
        expect(find.text('Scheduled for '), findsOneWidget);
        expect(find.text('Open to '), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Organizer'), findsOneWidget);
        expect(find.text('Participants'), findsOneWidget);
        expect(find.text('No user has already joined the training.'), findsNothing);
        expect(horizontalInfoSectionFinder, findsOneWidget);
        expect(horizontalInfoScrollableFinder, findsOneWidget);
        expect(locationTileFinder, findsOneWidget);
        expect(ownerTileFinder, findsOneWidget);
        expect(participantGridFinder, findsOneWidget);
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('button', () {
    testWidgets('proposal owned by current user, button not visible', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsNothing);
      });
    });
    testWidgets('past proposal owned by another user, button not visible', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal1.dateTime = DateTime.now().add(const Duration(days: -2));
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsNothing);
      });
    });
    testWidgets('proposal owned by another user, current user not participant', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal1.dateTime = DateTime.now().add(const Duration(days: 2));
        testProposal1.participants = [];
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsOneWidget);
        expect(leaveButtonFinder, findsNothing);
      });
    });
    testWidgets('proposal owned by another user, current user already participant', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal1.dateTime = DateTime.now().add(const Duration(days: 2));
        testProposal1.participants = [testUser0.uid];
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsOneWidget);
      });
    });

    testWidgets('correct tap behavior', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal1.dateTime = DateTime.now().add(const Duration(days: 2));
        testProposal1.participants = [];
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsOneWidget);
        expect(leaveButtonFinder, findsNothing);
        await tester.tap(joinButtonFinder);
        await tester.pumpAndSettle();
        verify(mockDatabase.addParticipantToProposal(testProposal1, testUser0.uid)).called(1);
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsOneWidget);
        await tester.tap(leaveButtonFinder);
        await tester.pumpAndSettle();
        verify(mockDatabase.removeParticipantFromProposal(testProposal1, testUser0.uid)).called(1);
        expect(joinButtonFinder, findsOneWidget);
        expect(leaveButtonFinder, findsNothing);
      });
    });
    testWidgets('error when adding participant', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.addParticipantToProposal(testProposal1, testUser0.uid)).thenThrow(DatabaseException('test'));
        testProposal1.dateTime = DateTime.now().add(const Duration(days: 2));
        testProposal1.participants = [];
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsOneWidget);
        expect(leaveButtonFinder, findsNothing);
        await tester.tap(joinButtonFinder);
        await tester.pumpAndSettle();
        verify(mockDatabase.addParticipantToProposal(testProposal1, testUser0.uid)).called(1);
        expect(joinButtonFinder, findsOneWidget);
        expect(leaveButtonFinder, findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
            find.descendant(of: find.byType(SnackBar), matching: find.text("An error occurred. Couldn't join session")),
            findsOneWidget);
      });
    });
    testWidgets('error when removing participant', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.removeParticipantFromProposal(testProposal1, testUser0.uid))
            .thenThrow(DatabaseException('test'));
        testProposal1.dateTime = DateTime.now().add(const Duration(days: 2));
        testProposal1.participants = [testUser0.uid];
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsOneWidget);
        await tester.tap(leaveButtonFinder);
        await tester.pumpAndSettle();
        verify(mockDatabase.removeParticipantFromProposal(testProposal1, testUser0.uid)).called(1);
        expect(joinButtonFinder, findsNothing);
        expect(leaveButtonFinder, findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
            find.descendant(
                of: find.byType(SnackBar), matching: find.text("An error occurred. Couldn't leave session")),
            findsOneWidget);
      });
    });
  });

  group('alternative outputs', () {
    testWidgets('proposal of a past year, not current one', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal0.dateTime = DateTime.now().add(const Duration(days: -1000));
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(find.text(DateFormat('MMM d y, HH:mm').format(testProposal0.dateTime)), findsOneWidget);
        expect(find.text(DateFormat('MMM d, HH:mm').format(testProposal0.dateTime)), findsNothing);
      });
    });
    testWidgets('proposal of a future year, not current one', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal0.dateTime = DateTime.now().add(const Duration(days: 1000));
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(find.text(DateFormat('MMM d y, HH:mm').format(testProposal0.dateTime)), findsOneWidget);
        expect(find.text(DateFormat('MMM d, HH:mm').format(testProposal0.dateTime)), findsNothing);
      });
    });
    testWidgets('proposal in current year', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal0.dateTime = DateTime.now();
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(find.text(DateFormat('MMM d y, HH:mm').format(testProposal0.dateTime)), findsNothing);
        expect(find.text(DateFormat('MMM d, HH:mm').format(testProposal0.dateTime)), findsOneWidget);
      });
    });
    testWidgets('public proposal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(find.text('Everybody'), findsOneWidget);
        expect(find.text("Mario Rossi's friends"), findsNothing);
      });
    });
    testWidgets('friend proposal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        testProposal0.type = 'Friends';
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(find.text('Everybody'), findsNothing);
        expect(find.text("Mario Rossi's friends"), findsOneWidget);
      });
    });
  });

  group('proposal removal', () {
    testWidgets('proposal owned by a different user does not show icon for removal', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testProposal1));
        await tester.pumpAndSettle();
        expect(deleteIconFinder, findsNothing);
      });
    });
    testWidgets('correct behavior for tapping and canceling deletion', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(deleteIconFinder, findsOneWidget);
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();
        expect(removalDialogFinder, findsOneWidget);
        await tester.tap(find.descendant(
            of: removalDialogFinder, matching: find.ancestor(of: find.text("No"), matching: find.byType(TextButton))));
        await tester.pumpAndSettle();
        expect(find.byType(ProposalPage), findsOneWidget);
      });
    });
    testWidgets('correct behavior for tapping and confirming deletion', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(deleteIconFinder, findsOneWidget);
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();
        expect(removalDialogFinder, findsOneWidget);
        await tester.tap(find.descendant(
            of: removalDialogFinder, matching: find.ancestor(of: find.text("Yes"), matching: find.byType(TextButton))));
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.descendant(of: find.byType(SnackBar), matching: find.text('Proposal deleted successfully.')),
            findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(ProposalPage), findsNothing);
      });
    });
    testWidgets('exception upon deletion', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        when(mockDatabase.deleteProposal(testProposal0)).thenThrow(DatabaseException('test'));
        await tester.pumpWidget(widgetUnderTest(testProposal0));
        await tester.pumpAndSettle();
        expect(deleteIconFinder, findsOneWidget);
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();
        expect(removalDialogFinder, findsOneWidget);
        await tester.tap(find.descendant(
            of: removalDialogFinder, matching: find.ancestor(of: find.text("Yes"), matching: find.byType(TextButton))));
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(ProposalPage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
            find.descendant(
                of: find.byType(SnackBar), matching: find.text('An error occurred when deleting the proposal.')),
            findsOneWidget);
        await tester.pumpAndSettle();
      });
    });
  });

  testWidgets('correct tiles', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(widgetUnderTest(testProposal0));
      await tester.pumpAndSettle();
      expect(locationTileFinder, findsOneWidget);
      PlaceTile locationTile = locationTileFinder.evaluate().single.widget as PlaceTile;
      expect(locationTile.title, testProposal0.place.name);
      expect(ownerTileFinder, findsOneWidget);
      UserTile ownerTile = ownerTileFinder.evaluate().single.widget as UserTile;
      expect(ownerTile.title, "${testProposal0.owner.name} ${testProposal0.owner.surname}");
      expect(participantGridFinder, findsOneWidget);
      expect(find.byKey(Key('ProposalPageParticipantTile_${testProposal0.participants[0]}')), findsOneWidget);
    });
  });
}
