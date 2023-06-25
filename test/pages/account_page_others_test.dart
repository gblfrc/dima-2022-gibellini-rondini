import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/model/user.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/pages/account_page.dart';

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
  Finder proposalTabFinder = find.byKey(const Key('AccountPageProposalTab'));
  Finder proposalTabListFinder = find.byKey(const Key('AccountPageProposalTabList'));
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
        .thenAnswer((realInvocation) => Stream.fromIterable([[]]));
    when(mockDatabase.getGoals(testOtherUser.uid, inProgressOnly: false))
        .thenAnswer((realInvocation) => Stream.fromIterable([[]]));
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

  testWidgets('proposal tab shows proposal tiles', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      tester.binding.window.physicalSizeTestValue = const Size(1440, 3120);
      await tester.pumpWidget(widgetUnderTest(testCurrentUser.uid));
      await tester.pumpAndSettle();
      await tester.tap(proposalTabFinder);
      await tester.pumpAndSettle();
      expect(sessionTabBodyFinder, findsNothing);
      expect(proposalTabBodyFinder, findsOneWidget);
      expect(proposalTabListFinder, findsOneWidget);
      expect(goalTabBodyFinder, findsNothing);
      // check proposal tab list contains 2 proposal tiles
      expect(find.descendant(of: proposalTabBodyFinder, matching: proposalTabListFinder), findsOneWidget);
      expect(find.descendant(of: proposalTabListFinder, matching: find.byType(ProposalTile)), findsNWidgets(2));
      expect(find.descendant(of: proposalTabBodyFinder, matching: find.text("No proposal made up to now.")),
          findsNothing);
      expect(
          find.descendant(of: proposalTabBodyFinder, matching: find.text("An error occurred while loading proposals.")),
          findsNothing);
    });
  });

}
