import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/proposal.dart';
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
  late Timestamp testTimestamp;
  late LatLngBounds testBounds;
  late User testUser;
  late Proposal testProposal;
  late Place testPlace;
  late Map<String, dynamic> mockUserJson0;
  late Map<String, dynamic> mockUserJson1;
  late DocumentReference<Map<String, dynamic>> mockOwnerDocumentReference0;
  late DocumentReference<Map<String, dynamic>> mockOwnerDocumentReference1;
  late Map<String, dynamic> mockUserFirestoreProposal0;
  late Map<String, dynamic> mockUserFirestoreProposal1;
  final CollectionReference<Map<String, dynamic>> mockCollection = MockCollectionReference();
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
  final DocumentSnapshot<Map<String, dynamic>> mockSnapshot0 = MockDocumentSnapshot();
  final DocumentSnapshot<Map<String, dynamic>> mockSnapshot1 = MockDocumentSnapshot();

  setUpAll(() {
    mockFirebaseFirestore = MockFirebaseFirestore();
    database = Database(firebaseFirestore: mockFirebaseFirestore);
    testTimestamp = Timestamp(1686732868, 243983000);
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
    mockUserFirestoreProposal0 = {
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
    mockUserFirestoreProposal1 = {
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
      'owner': {'name': 'Mario', 'surname': 'Rossi', 'uid': 'mario_rossi',},
      'place': {'id': '11694848', 'name': 'Parco Suardi', 'lat': 45.7, 'lon': 9.6,},
      'participants': ['first_participant', 'second_participant'],
      'type': 'Public'
    });
    testPlace = Place.fromJson({'id': '11694848', 'name': 'Parco Suardi', 'lat': 45.7, 'lon': 9.6,});
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
    when(mockQuery1.where('dateTime', isGreaterThanOrEqualTo: testTimestamp))
        .thenAnswer((realInvocation) => mockQuery1);
    when(mockQuery1.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot1));
    when(mockQuerySnapshot1.docs).thenReturn([mockQueryDocumentSnapshotProposal0, mockQueryDocumentSnapshotProposal1]);
    when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockUserFirestoreProposal0);
    when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockUserFirestoreProposal1);
  }

  group('obtaining proposals for friends', () {
    test('correct output, empty friend list', () async {
      proposalExtractionInit();
      when(mockQuerySnapshot0.docs).thenReturn([]);
      expect(await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testTimestamp), List.empty());
    });

    test('correct output, not empty list', () async {
      proposalExtractionInit();
      List<Proposal?> proposals =
      await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testTimestamp);
      expect(proposals.length, 2);
    });

    group('proposal from firestore', () {
      test('friend proposal not visible if user is not friend of owner', () async {
        mockUserJson1['friends'] = [];
        proposalExtractionInit();
        List<Proposal?> proposals =
        await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testTimestamp);
        expect(proposals.length, 1);
        expect(proposals[0]!.type, 'Public');
      });

      test('returns null if error is thrown while parsing', () async {
        // force error in timestamp parsing
        mockUserFirestoreProposal1['dateTime'] = null;
        proposalExtractionInit();
        List<Proposal?> proposals =
        await database.getFriendProposalsAfterTimestamp(mockUserJson0['uid'], after: testTimestamp);
        expect(proposals.length, 1);
        expect(proposals[0]!.type, 'Friends');
      });
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.getFriendProposalsAfterTimestamp('test', after: testTimestamp),
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
    when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockUserFirestoreProposal0);
    when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockUserFirestoreProposal1);
  }

  group('find proposal within bounds', () {
    test('correct output', () async {
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 2);
    });

    test('one of the proposals lies out of bounds', () async {
      mockUserFirestoreProposal1['place']['coords'] = const GeoPoint(45.698, 9.68);
      mockUserFirestoreProposal1['place']['latitude'] = 45.698;
      mockUserFirestoreProposal1['place']['longitude'] = 9.68;
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 1);
    });

    test('proposals are returned in order', () async {
      // set proposal 1 to take place before proposal 0
      mockUserFirestoreProposal1['dateTime'] = Timestamp.fromDate(DateTime(2023, 1, 1));
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 2);
      expect(proposals[0]!.type, 'Public');
      expect(proposals[1]!.type, 'Friends');
    });

    test('illegal coords field in json', () async {
      mockUserFirestoreProposal1['place']['coords'] = 10;
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 1);
    });

    test('illegal dateTime field in json', () async {
      mockUserFirestoreProposal1['dateTime'] = 10;
      proposalWithinBoundsInit();
      List<Proposal?> proposals = await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']);
      expect(proposals.length, 1);
    });

    test('correct behavior with outdated proposals', () async {
      Timestamp testAfter = Timestamp.fromDate(DateTime(2023, 5, 30));
      proposalWithinBoundsInit();
      List<Proposal?> proposals =
      await database.getProposalsWithinBounds(testBounds, mockUserJson0['uid'], after: testAfter);
      expect(proposals.length, 1);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('proposals')).thenThrow(FirebaseException(plugin: 'test', message: 'test'));
      expect(
              () => database.getProposalsWithinBounds(testBounds, mockUserJson0['uid']),
          throwsA(isA<DatabaseException>()));
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
      when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockUserFirestoreProposal0);
      List<Proposal?> proposals = await database.getProposalsByPlace(testPlace, mockUserJson0['uid']);
      expect(proposals.length, 1);
      expect(proposals[0]!.place.id, '11694848');
    });

    test('correct output with set after timestamp', () async {
      mockUserFirestoreProposal1['place']['id'] = '11694848';
      when(mockFirebaseFirestore.collection('proposals')).thenReturn(mockCollection);
      when(mockCollection.where('place.id', isEqualTo: testPlace.id)).thenReturn(mockQuery0);
      when(mockQuery0.get()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot0));
      when(mockQuerySnapshot0.docs).thenReturn([mockQueryDocumentSnapshotProposal0,mockQueryDocumentSnapshotProposal1]);
      when(mockQueryDocumentSnapshotProposal0.data()).thenReturn(mockUserFirestoreProposal0);
      when(mockQueryDocumentSnapshotProposal1.data()).thenReturn(mockUserFirestoreProposal1);
      List<Proposal?> proposals = await database.getProposalsByPlace(testPlace, mockUserJson0['uid'], after: Timestamp.fromDate(DateTime(2023,5,30)));
      expect(proposals.length, 1);
      expect(proposals[0]!.type, 'Public');
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('proposals')).thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.getProposalsByPlace(testPlace, mockUserJson0['uid']), throwsA(isA<DatabaseException>()));
    });
  });
}
