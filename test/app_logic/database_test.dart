import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/model/goal.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
import 'package:progetto/model/session.dart';
import 'package:progetto/model/user.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
  MockSpec<Query<Map<String, dynamic>>>(),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(),
])
import 'database_test.mocks.dart';

main() {
  late Database database;
  late FirebaseFirestore mockFirebaseFirestore;
  late DateTime testDateTime;
  late DateTime testLowerBound;
  late DateTime testUpperBound;
  late LatLngBounds testBounds;
  late User testUser;
  late Proposal testProposal;
  late Place testPlace;
  late Goal testGoal;
  late Map<String, dynamic> mockUserJson0;
  late Map<String, dynamic> mockUserJson1;
  late DocumentReference<Map<String, dynamic>> mockOwnerDocumentReference0;
  late DocumentReference<Map<String, dynamic>> mockOwnerDocumentReference1;
  late Map<String, dynamic> mockFirestoreProposal0;
  late Map<String, dynamic> mockFirestoreProposal1;
  late Map<String, dynamic> mockFirestoreSession0;
  late Map<String, dynamic> mockFirestoreSession1;
  late Map<String, dynamic> mockFirestoreGoal0;
  late Map<String, dynamic> mockFirestoreGoal1;
  final CollectionReference<Map<String, dynamic>> mockCollection = MockCollectionReference();
  final CollectionReference<Map<String, dynamic>> mockUserCollection = MockCollectionReference();
  final DocumentReference<Map<String, dynamic>> mockReference = MockDocumentReference();
  final Query<Map<String, dynamic>> mockQuery0 = MockQuery();
  final QuerySnapshot<Map<String, dynamic>> mockQuerySnapshot0 = MockQuerySnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotFriends0 = MockQueryDocumentSnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotFriends1 = MockQueryDocumentSnapshot();
  final DocumentReference<Map<String, dynamic>> mockReference0 = MockDocumentReference();
  final DocumentReference<Map<String, dynamic>> mockReference1 = MockDocumentReference();
  final Query<Map<String, dynamic>> mockQuery1 = MockQuery();
  final QuerySnapshot<Map<String, dynamic>> mockQuerySnapshot1 = MockQuerySnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotProposal0 = MockQueryDocumentSnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotProposal1 = MockQueryDocumentSnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotSession0 = MockQueryDocumentSnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotSession1 = MockQueryDocumentSnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotGoal0 = MockQueryDocumentSnapshot();
  final QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshotGoal1 = MockQueryDocumentSnapshot();
  final DocumentSnapshot<Map<String, dynamic>> mockSnapshot0 = MockDocumentSnapshot();
  final DocumentSnapshot<Map<String, dynamic>> mockSnapshot1 = MockDocumentSnapshot();

  setUpAll(() {
    mockFirebaseFirestore = MockFirebaseFirestore();
    database = Database(firebaseFirestore: mockFirebaseFirestore);
    testDateTime = DateTime(2023, 6, 14, 10, 30, 15);
  });

  setUp(() {
    testUser = User(name: 'Mario', surname: 'Rossi', uid: 'mario_rossi');
    mockUserJson0 = {
      'name': 'Mario',
      'surname': 'Rossi',
      'uid': 'mario_rossi',
      'friends': [],
    };
    mockUserJson1 = {
      'name': 'Luigi',
      'surname': 'Verdi',
      'uid': 'luigi_verdi',
      'birthday': '1999-04-03',
      'friends': [],
    };
    mockOwnerDocumentReference0 = MockDocumentReference();
    var tempSnapshot0 = MockDocumentSnapshot();
    var tempSnapshot1 = MockDocumentSnapshot();
    when(mockOwnerDocumentReference0.id).thenReturn(mockUserJson0['uid']);
    when(mockOwnerDocumentReference0.get()).thenAnswer((realInvocation) => Future.value(tempSnapshot0));
    when(tempSnapshot0.data()).thenReturn(mockUserJson0);
    mockOwnerDocumentReference1 = MockDocumentReference();
    when(mockOwnerDocumentReference1.id).thenReturn(mockUserJson1['uid']);
    when(mockOwnerDocumentReference1.get()).thenAnswer((realInvocation) => Future.value(tempSnapshot1));
    when(tempSnapshot1.data()).thenReturn(mockUserJson1);
    mockUserJson1['friends'] = [mockOwnerDocumentReference0];
    mockFirestoreProposal0 = {
      'dateTime': Timestamp.fromDate(DateTime(2023, 5, 5)),
      'owner': mockOwnerDocumentReference1,
      'place': {
        'coords': const GeoPoint(45.70169115, 9.67716459),
        'geohash': 'u0ngupe8',
        'id': '11694848',
        'name': 'Parco Suardi',
        'latitude': 45.70169115,
        'longitude': 9.67716459,
      },
      'participants': [],
      'type': 'Friends'
    };
    mockFirestoreProposal1 = {
      'dateTime': Timestamp.fromDate(DateTime(2023, 6, 6)),
      'owner': mockOwnerDocumentReference1,
      'place': {
        'coords': const GeoPoint(45.70373305, 9.67972074),
        'geohash': 'u0nuh20e9',
        'id': '81252122',
        'name': 'Liceo Mascheroni',
        'latitude': 45.70373305,
        'longitude': 9.67972074,
      },
      'participants': [],
      'type': 'Public'
    };
    testBounds = LatLngBounds(LatLng(45.706529, 9.688445), LatLng(45.699355, 9.67264));
    testProposal = Proposal.fromJson({
      'pid': 'test_proposal',
      'dateTime': "2023-05-23 21:35:06",
      'owner': {
        'name': 'Mario',
        'surname': 'Rossi',
        'uid': 'mario_rossi',
      },
      'place': {
        'id': '11694848',
        'name': 'Parco Suardi',
        'lat': 45.7,
        'lon': 9.6,
      },
      'participants': ['first_participant', 'second_participant'],
      'type': 'Public'
    });
    testPlace = Place.fromJson({
      'id': '11694848',
      'name': 'Parco Suardi',
      'lat': 45.7,
      'lon': 9.6,
    });
    testLowerBound = DateTime(2023, 6, 15, 10);
    testUpperBound = DateTime(2023, 6, 15, 12);
    mockFirestoreSession0 = {
      'distance': 182.01853264834955,
      'duration': 42.859,
      'positions': [
        {
          'values': [
            const GeoPoint(37.36, 122.07),
            const GeoPoint(37.37, 122.08),
            const GeoPoint(37.39, 122.08),
            const GeoPoint(37.40, 122.08),
          ]
        },
        {
          'values': [
            const GeoPoint(37.41, 122.07),
            const GeoPoint(37.42, 122.08),
            const GeoPoint(37.42, 122.10),
          ]
        }
      ],
      'startDT': Timestamp.fromDate(DateTime(2023, 6, 15, 10, 12, 33)),
      'userID': mockOwnerDocumentReference0
    };
    mockFirestoreSession1 = {
      'distance': 18.16,
      'duration': 42516,
      'positions': [
        {
          'values': [
            const GeoPoint(37.51, 122.07),
            const GeoPoint(37.52, 122.08),
          ],
        },
      ],
      'startDT': Timestamp.fromDate(DateTime(2023, 6, 5, 18, 22, 33)),
      'userID': mockOwnerDocumentReference0
    };
    mockFirestoreGoal0 = {
      'id': 'test_goal_0',
      'owner': mockOwnerDocumentReference0,
      'type': 'distanceGoal',
      'targetValue': 8.0,
      'currentValue': 5.3,
      'completed': false,
      'createdAt': Timestamp.fromDate(DateTime(2023, 5, 23, 21, 35, 06)),
    };
    mockFirestoreGoal1 = {
      'id': 'test_goal_1',
      'owner': mockOwnerDocumentReference0,
      'type': 'distanceGoal',
      'targetValue': 60,
      'currentValue': 60,
      'completed': true,
      'createdAt': Timestamp.fromDate(DateTime(2023, 5, 29, 18, 15, 22)),
    };
    testGoal = Goal.fromJson({
      'id': 'test',
      'owner': {'name': 'Mario', 'surname': 'Rossi', 'uid': 'mario_rossi'},
      'type': 'distanceGoal',
      'targetValue': 8.0,
      'currentValue': 5.3,
      'completed': false,
      'createdAt': DateTime(2023, 5, 23, 21, 35, 06),
    });
  });

  test('singleton properties', () {
    var database1 = Database();
    expect(database1, database);
    expect(database.databaseType, mockFirebaseFirestore.runtimeType);
  });

  group('user creation', () {
    test('correct output without birthday', () async {
      when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any)).thenAnswer((realInvocation) => mockReference);
      database.createUser(testUser);
    });

    test('correct output with birthday', () async {
      testUser.birthday = DateTime.now();
      when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any)).thenAnswer((realInvocation) => mockReference);
      expect(() => database.createUser(testUser), returnsNormally);
    });

    test('exception is thrown', () async {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.createUser(testUser), throwsA(isA<DatabaseException>()));
    });
  });

  group('user update', () {
    test('correct output without birthday', () async {
      when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any)).thenAnswer((realInvocation) => mockReference);
      expect(() => database.updateUser(testUser), returnsNormally);
    });

    test('correct output with birthday', () async {
      testUser.birthday = DateTime.now();
      when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any)).thenAnswer((realInvocation) => mockReference);
      expect(() => database.updateUser(testUser), returnsNormally);
    });

    test('exception is thrown', () async {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.updateUser(testUser), throwsA(isA<DatabaseException>()));
    });
  });

  group('getting user from database', () {
    test('correct output', () async {
      when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(mockUserJson0['uid'])).thenAnswer((realInvocation) => mockReference);
      when(mockReference.snapshots()).thenAnswer((invocation) => Stream.fromIterable([mockSnapshot0, mockSnapshot1]));
      when(mockSnapshot0.data()).thenReturn(mockUserJson0);
      when(mockSnapshot1.data()).thenReturn(mockUserJson1);
      List<User?> users = await database.getUser(mockUserJson0['uid']).toList();
      expect(users.length, 2);
      expect(users[0]!.name, mockUserJson0['name']);
      expect(users[0]!.surname, mockUserJson0['surname']);
      expect(users[0]!.uid, mockUserJson0['uid']);
      expect(users[0]!.birthday, null);
      expect(users[1]!.name, mockUserJson1['name']);
      expect(users[1]!.surname, mockUserJson1['surname']);
      expect(users[1]!.uid, users[0]!.uid);
      expect(users[1]!.birthday.toString().substring(0, 10), mockUserJson1['birthday']);
    });

    test('does not return a user because result from database is incorrect', () async {
      mockUserJson0['birthday'] = 'test';
      when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(mockUserJson0['uid'])).thenAnswer((realInvocation) => mockReference);
      when(mockReference.snapshots()).thenAnswer((invocation) => Stream.fromIterable([mockSnapshot0]));
      when(mockSnapshot0.data()).thenReturn(mockUserJson0);
      List<User?> users = await database.getUser(mockUserJson0['uid']).toList();
      expect(users[0], null);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.getUser('test'), throwsA(isA<DatabaseException>()));
    });
  });

  // method to initialize the correct case to extract proposals
  // needed in multiple test
  void proposalExtractionInit() {
    when(mockFirebaseFirestore.collection('users')).thenAnswer((realInvocation) => mockCollection);
    when(mockCollection.doc(mockUserJson0['uid'])).thenAnswer((realInvocation) => mockReference);
    when(mockCollection.where('friends', arrayContains: anyNamed('arrayContains')))
        .thenAnswer((realInvocation) => mockQuery0);
    when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
    when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotFriends0, mockQueryDocumentSnapshotFriends1]);
    when(mockQueryDocumentSnapshotFriends0.reference).thenReturn(mockReference0);
    when(mockQueryDocumentSnapshotFriends1.reference).thenReturn(mockReference1);
    when(mockFirebaseFirestore.collection('proposals')).thenAnswer((realInvocation) => mockCollection);
    when(mockCollection.where('owner', whereIn: anyNamed('whereIn'))).thenAnswer((realInvocation) => mockQuery1);
    when(mockQuery1.where('dateTime', isGreaterThanOrEqualTo: testDateTime)).thenAnswer((realInvocation) => mockQuery1);
    when(mockQuery1.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot1));
    when(mockQuerySnapshot1.docs).thenReturn([mockQueryDocumentSnapshotProposal0, mockQueryDocumentSnapshotProposal1]);
    when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockFirestoreProposal0);
    when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockFirestoreProposal1);
  }

  group('obtaining proposals for friends', () {
    test('correct output, empty friend list', () async {
      proposalExtractionInit();
      when(mockQuerySnapshot0.docs).thenReturn([]);
      expect(await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testDateTime), List.empty());
    });

    test('correct output, not empty list', () async {
      proposalExtractionInit();
      List<Proposal?> proposals =
          await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testDateTime);
      expect(proposals.length, 2);
    });

    group('proposal from firestore', () {
      test('friend proposal not visible if user is not friend of owner', () async {
        mockUserJson1['friends'] = [];
        proposalExtractionInit();
        List<Proposal?> proposals =
            await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testDateTime);
        expect(proposals.length, 1);
        expect(proposals[0]!.type, 'Public');
      });

      test('returns null if error is thrown while parsing', () async {
        // force error in timestamp parsing
        mockFirestoreProposal1['dateTime'] = null;
        proposalExtractionInit();
        List<Proposal?> proposals =
            await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testDateTime);
        expect(proposals.length, 1);
        expect(proposals[0]!.type, 'Friends');
      });
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.getFriendProposalsAfterTimestamp('test', after: testDateTime),
          throwsA(isA<DatabaseException>()));
    });
  });

  void proposalWithinBoundsInit() {
    when(mockFirebaseFirestore.collection('proposals')).thenAnswer((realInvocation) => mockCollection);
    when(mockCollection.where('place.geohash', isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo')))
        .thenAnswer((realInvocation) => mockQuery0);
    when(mockQuery0.where('place.geohash', isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo')))
        .thenAnswer((realInvocation) => mockQuery0);
    when(mockQuery0.where('type', isEqualTo: 'Friends')).thenAnswer((realInvocation) => mockQuery0);
    when(mockQuery0.where('type', isEqualTo: 'Public')).thenAnswer((realInvocation) => mockQuery1);
    when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
    when(mockQuery1.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot1));
    when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotProposal0]);
    when(mockQuerySnapshot1.docs).thenReturn([mockQueryDocumentSnapshotProposal1]);
    when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockFirestoreProposal0);
    when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockFirestoreProposal1);
  }

  group('find proposal within bounds', () {
    test('correct output', () async {
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 2);
    });

    test('one of the proposals lies out of bounds', () async {
      mockFirestoreProposal1['place']['coords'] = const GeoPoint(45.698, 9.68);
      mockFirestoreProposal1['place']['latitude'] = 45.698;
      mockFirestoreProposal1['place']['longitude'] = 9.68;
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 1);
    });

    test('proposals are returned in order', () async {
      // set proposal 1 to take place before proposal 0
      mockFirestoreProposal1['dateTime'] = Timestamp.fromDate(DateTime(2023, 1, 1));
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 2);
      expect(proposals[0]!.type, 'Public');
      expect(proposals[1]!.type, 'Friends');
    });

    test('illegal coords field in json', () async {
      mockFirestoreProposal1['place']['coords'] = 10;
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 1);
    });

    test('illegal dateTime field in json', () async {
      mockFirestoreProposal1['dateTime'] = 10;
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 1);
    });

    test('correct behavior with outdated proposals', () async {
      DateTime testAfter = DateTime(2023, 5, 30);
      proposalWithinBoundsInit();
      List<Proposal?> proposals =
          await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid'], after: testAfter);
      expect(proposals.length, 1);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('proposals')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(
          () => database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']), throwsA(isA<DatabaseException>()));
    });
  });

  group('get friends from database', () {
    test('correct output', () async {
      when(mockFirebaseFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(mockUserJson1['uid'])).thenReturn(mockReference0);
      when(mockReference0.get()).thenAnswer((realInvocation) => Future.value(mockSnapshot0));
      when(mockSnapshot0.get('friends')).thenReturn(mockUserJson1['friends']);
      when(mockOwnerDocumentReference0.get()).thenAnswer((realInvocation) => Future.value(mockSnapshot1));
      when(mockSnapshot1.get('name')).thenReturn(mockUserJson0['name']);
      when(mockSnapshot1.get('surname')).thenReturn(mockUserJson0['surname']);
      List<User?> users = await database.getFriends(mockUserJson1['uid']);
      expect(users.length, 1);
      expect(users[0]!.name, mockUserJson0['name']);
      expect(users[0]!.surname, mockUserJson0['surname']);
      expect(users[0]!.uid, mockUserJson0['uid']);
    });

    test('throw exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(() => database.getFriends(mockUserJson0['uid']), throwsA(isA<DatabaseException>()));
    });
  });

  group('add friends', () {
    // this test is currently not working because of a missing _delegate in MockDocumentReference
    // test('correct output', () async {
    //   when(mockFirebaseFirestore.collection('users')).thenReturn(mockCollection);
    //   when(mockCollection.doc(mockUserJson0['uid'])).thenReturn(mockReference);
    //   expect(() => database.addFriend(mockUserJson1['uid'], mockUserJson0['uid']), returnsNormally);
    // });

    test('throw exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(() => database.addFriend(mockUserJson1['uid'], mockUserJson0['uid']), throwsA(isA<DatabaseException>()));
    });
  });

  group('proposal creation', () {
    test('returns normally', () {
      CollectionReference<Map<String, dynamic>> mockCollectionUsers = MockCollectionReference();
      when(mockFirebaseFirestore.collection('proposals')).thenReturn(mockCollection);
      when(mockFirebaseFirestore.collection('users')).thenReturn(mockCollectionUsers);
      when(mockCollectionUsers.doc(mockUserJson0['uid'])).thenReturn(mockReference);
      expect(() => database.createProposal(testProposal), returnsNormally);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('proposals')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(() => database.createProposal(testProposal), throwsA(isA<DatabaseException>()));
    });
  });

  group('proposals from place', () {
    test('correct output', () async {
      when(mockFirebaseFirestore.collection('proposals')).thenReturn(mockCollection);
      when(mockCollection.where('place.id', isEqualTo: testPlace.id)).thenReturn(mockQuery0);
      when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
      when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotProposal0]);
      when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockFirestoreProposal0);
      List<Proposal?> proposals = await database.getProposalsByPlace(testPlace, mockUserJson0['uid']);
      expect(proposals.length, 1);
      expect(proposals[0]!.place.id, '11694848');
    });

    test('correct output with set after timestamp', () async {
      mockFirestoreProposal1['place']['id'] = '11694848';
      when(mockFirebaseFirestore.collection('proposals')).thenReturn(mockCollection);
      when(mockCollection.where('place.id', isEqualTo: testPlace.id)).thenReturn(mockQuery0);
      when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
      when(mockQuerySnapshot0.docs)
          .thenReturn([mockQueryDocumentSnapshotProposal0, mockQueryDocumentSnapshotProposal1]);
      when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockFirestoreProposal0);
      when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockFirestoreProposal1);
      List<Proposal?> proposals =
          await database.getProposalsByPlace(testPlace, mockUserJson0['uid'], after: DateTime(2023, 5, 30));
      expect(proposals.length, 1);
      expect(proposals[0]!.type, 'Public');
    });

    test('error when analyzing docs for illegal dateTime field', () async {
      mockFirestoreProposal0['dateTime'] = 5;
      when(mockFirebaseFirestore.collection('proposals')).thenReturn(mockCollection);
      when(mockCollection.where('place.id', isEqualTo: testPlace.id)).thenReturn(mockQuery0);
      when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
      when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotProposal0]);
      when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockFirestoreProposal0);
      List<Proposal?> proposals =
          await database.getProposalsByPlace(testPlace, mockUserJson0['uid'], after: DateTime(2023, 5, 30));
      expect(proposals.length, 0);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('proposals')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.getProposalsByPlace(testPlace, mockUserJson0['uid']), throwsA(isA<DatabaseException>()));
    });
  });

  group('proposals within time interval', () {
    test('returns list of proposals', () async {
      // adjust proposals to make them meaningful for this test
      mockFirestoreProposal0['owner'] = mockOwnerDocumentReference0;
      mockFirestoreProposal0['dateTime'] = Timestamp.fromDate(testLowerBound.add(const Duration(hours: 1)));
      mockFirestoreProposal1['dateTime'] = Timestamp.fromDate(testLowerBound.add(const Duration(hours: 1)));
      mockFirestoreProposal1['participants'] = [mockOwnerDocumentReference0];
      // extraction of user reference
      when(mockFirebaseFirestore.collection('users')).thenReturn(mockUserCollection);
      when(mockUserCollection.doc(mockUserJson0['uid'])).thenReturn(mockReference);
      // extraction of proposals with user in participants - Query 0
      when(mockFirebaseFirestore.collection('proposals')).thenReturn(mockCollection);
      when(mockCollection.where('participants', arrayContains: mockReference)).thenReturn(mockQuery0);
      when(mockQuery0.where('dateTime', isLessThanOrEqualTo: testUpperBound)).thenReturn(mockQuery0);
      when(mockQuery0.where('dateTime', isGreaterThanOrEqualTo: testLowerBound)).thenReturn(mockQuery0);
      when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
      when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotProposal1]);
      when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockFirestoreProposal1);
      // extraction of proposals owned by user - Query 1
      when(mockCollection.where('owner', isEqualTo: mockReference)).thenReturn(mockQuery1);
      when(mockQuery1.where('dateTime', isLessThanOrEqualTo: testUpperBound)).thenReturn(mockQuery1);
      when(mockQuery1.where('dateTime', isGreaterThanOrEqualTo: testLowerBound)).thenReturn(mockQuery1);
      when(mockQuery1.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot1));
      when(mockQuerySnapshot1.docs).thenReturn([mockQueryDocumentSnapshotProposal0]);
      when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockFirestoreProposal0);
      // call method
      List<Proposal?> proposals = await database
          .getProposalsWithinInterval(mockUserJson0['uid'], after: testLowerBound, before: testUpperBound)
          .first;
      expect(proposals.length, 2);
    });

    test('throws argument exception', () {
      expect(database.getProposalsWithinInterval('test', after: testUpperBound, before: testLowerBound),
          emitsError(isA<ArgumentError>()));
    });

    test('throws database exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test'));
      expect(database.getProposalsWithinInterval('test', after: testLowerBound, before: testUpperBound),
          emitsError(isA<DatabaseException>()));
    });
  });

  void sessionInit() {
    // user collection
    when(mockFirebaseFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(mockUserJson0['uid'])).thenReturn(mockReference);
    // session collection
    when(mockFirebaseFirestore.collection('sessions')).thenReturn(mockCollection);
    when(mockCollection.where('userID', isEqualTo: mockReference)).thenReturn(mockQuery0);
    when(mockQuery0.orderBy("startDT", descending: true)).thenReturn(mockQuery0);
    when(mockQuery0.limit(2)).thenReturn(mockQuery0);
    // stream of snapshots
    when(mockQuery0.snapshots()).thenAnswer((realInvocation) => Stream.fromIterable([mockQuerySnapshot0]));
    // snapshot (list of sessions)
    when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotSession0, mockQueryDocumentSnapshotSession1]);
    when(mockQueryDocumentSnapshotSession0.data()).thenReturn(mockFirestoreSession0);
    when(mockQueryDocumentSnapshotSession0.id).thenReturn('test_session_0');
    when(mockQueryDocumentSnapshotSession1.data()).thenReturn(mockFirestoreSession1);
    when(mockQueryDocumentSnapshotSession1.id).thenReturn('test_session_1');
  }

  group('get user sessions', () {
    test('returns sessions', () async {
      sessionInit();
      List<Session?> sessions = await database.getLatestSessionsByUser(mockUserJson0['uid'], limit: 2).first;
      expect(sessions.length, 2);
    });

    test('one session is null because of errors in the json', () async {
      sessionInit();
      mockFirestoreSession0['distance'] = 'test';
      List<Session?> sessions = await database.getLatestSessionsByUser(mockUserJson0['uid'], limit: 2).first;
      expect(sessions.length, 1);
      expect(sessions[0]!.distance, 18.16); // distance is the one of the second mock session
    });

    test('one session is null because no positions are saved in the arrays', () async {
      sessionInit();
      mockFirestoreSession0['positions'] = [
        {'values': []}
      ];
      List<Session?> sessions = await database.getLatestSessionsByUser(mockUserJson0['uid'], limit: 2).first;
      expect(sessions.length, 1);
      expect(sessions[0]!.distance, 18.16); // distance is the one of the second mock session
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(database.getLatestSessionsByUser('test'), emitsError(isA<DatabaseException>()));
    });
  });

  void goalInit() {
    // user collection and reference to user
    when(mockFirebaseFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(mockUserJson0['uid'])).thenReturn(mockReference);
    // goal collection and query
    when(mockFirebaseFirestore.collection('goals')).thenReturn(mockCollection);
    when(mockCollection.where('owner', isEqualTo: mockReference)).thenReturn(mockQuery0);
    when(mockQuery0.where('completed', isEqualTo: false)).thenReturn(mockQuery0);
    when(mockQuery0.orderBy('createdAt', descending: true)).thenReturn(mockQuery0);
    // list of snapshots
    when(mockQuery0.snapshots()).thenAnswer((realInvocation) => Stream.fromIterable([mockQuerySnapshot0]));
    // documents
    when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotGoal0, mockQueryDocumentSnapshotGoal1]);
    when(mockQueryDocumentSnapshotGoal0.data()).thenReturn(mockFirestoreGoal0);
    when(mockQueryDocumentSnapshotGoal0.id).thenReturn(mockFirestoreGoal0['id']);
    when(mockQueryDocumentSnapshotGoal1.data()).thenReturn(mockFirestoreGoal1);
    when(mockQueryDocumentSnapshotGoal1.id).thenReturn(mockFirestoreGoal1['id']);
  }

  group('get goals', () {
    test('returns all goals correctly', () async {
      goalInit();
      List<Goal> goals = await database.getGoals(mockUserJson0['uid'], inProgressOnly: false).first;
      expect(goals.length, 2);
    });

    test('return goal in progress only', () async {
      goalInit();
      when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotGoal0]);
      List<Goal> goals = await database.getGoals(mockUserJson0['uid'], inProgressOnly: true).first;
      expect(goals.length, 1);
    });

    test('error in json from the database', () async {
      mockFirestoreGoal0['targetValue'] = 'test';
      goalInit();
      List<Goal> goals = await database.getGoals(mockUserJson0['uid'], inProgressOnly: true).first;
      expect(goals.length, 1);
      expect(goals[0].targetValue, 60);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(database.getGoals('test', inProgressOnly: true), emitsError(isA<DatabaseException>()));
    });
  });

  group('goal creation', () {
    test('returns normally', () {
      // user collection and reference
      when(mockFirebaseFirestore.collection('users')).thenReturn(mockUserCollection);
      when(mockUserCollection.doc(mockUserJson0['uid'])).thenReturn(mockReference);
      // goal collection and addition
      when(mockFirebaseFirestore.collection('goals')).thenReturn(mockCollection);
      expect(() => database.createGoal(mockUserJson0['uid'], testGoal), returnsNormally);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(() => database.createGoal('test', testGoal), throwsA(isA<DatabaseException>()));
    });
  });

  group('goal deletion', () {
    test('returns normally', () {
      when(mockFirebaseFirestore.collection('goals')).thenReturn(mockCollection);
      when(mockCollection.doc(testGoal.id)).thenReturn(mockReference);
      expect(() => database.deleteGoal(testGoal), returnsNormally);
    });
    
    test('throws exception', (){
      when(mockFirebaseFirestore.collection('goals')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(() => database.deleteGoal(testGoal), throwsA(isA<DatabaseException>()));
      
    } );
  });
}
