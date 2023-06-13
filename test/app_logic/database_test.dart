import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/model/user.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
])
import 'database_test.mocks.dart';

main() {
  late Database database;
  late FirebaseFirestore mockFirebaseFirestore;
  late User testUser;
  late Map<String, dynamic> mockUserJson0;
  late Map<String, dynamic> mockUserJson1;

  setUpAll(() {
    mockFirebaseFirestore = MockFirebaseFirestore();
    database = Database(firebaseFirestore: mockFirebaseFirestore);
  });

  setUp(() {
    testUser = User(name: 'Mario', surname: 'Rossi', uid: 'mario_rossi');
    mockUserJson0 = {
      'name':'Mario',
      'surname':'Rossi',
      'uid':'mario_rossi',
    };
    mockUserJson1 = {
      'name':'Luigi',
      'surname':'Verdi',
      'uid':'luigi_verdi',
      'birthday':'1999-04-03'
    };
  });

  test('singleton properties', () {
    var database1 = Database();
    expect(database1, database);
    expect(database.databaseType, mockFirebaseFirestore.runtimeType);
  });

  group('user creation', () {
    test('correct output without birthday', () async {
      CollectionReference<Map<String, dynamic>> mockCollection =
          MockCollectionReference();
      DocumentReference<Map<String, dynamic>> mockReference =
          MockDocumentReference();
      when(mockFirebaseFirestore.collection('users'))
          .thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any))
          .thenAnswer((realInvocation) => mockReference);
      database.createUser(testUser);
    });

    test('correct output with birthday', () async {
      testUser.birthday = DateTime.now();
      CollectionReference<Map<String, dynamic>> mockCollection =
          MockCollectionReference();
      DocumentReference<Map<String, dynamic>> mockReference =
          MockDocumentReference();
      when(mockFirebaseFirestore.collection('users'))
          .thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any))
          .thenAnswer((realInvocation) => mockReference);
      expect(() => database.createUser(testUser), returnsNormally);
    });

    test('exception is thrown', () async {
      when(mockFirebaseFirestore.collection('users'))
          .thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.createUser(testUser),
          throwsA(isA<DatabaseException>()));
    });
  });

  group('user update', () {
    test('correct output without birthday', () async {
      CollectionReference<Map<String, dynamic>> mockCollection =
          MockCollectionReference();
      DocumentReference<Map<String, dynamic>> mockReference =
          MockDocumentReference();
      when(mockFirebaseFirestore.collection('users'))
          .thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any))
          .thenAnswer((realInvocation) => mockReference);
      database.updateUser(testUser);
    });

    test('correct output with birthday', () async {
      testUser.birthday = DateTime.now();
      CollectionReference<Map<String, dynamic>> mockCollection =
          MockCollectionReference();
      DocumentReference<Map<String, dynamic>> mockReference =
          MockDocumentReference();
      when(mockFirebaseFirestore.collection('users'))
          .thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(any))
          .thenAnswer((realInvocation) => mockReference);
      expect(() => database.updateUser(testUser), returnsNormally);
    });

    test('exception is thrown', () async {
      when(mockFirebaseFirestore.collection('users'))
          .thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.updateUser(testUser),
          throwsA(isA<DatabaseException>()));
    });
  });

  group('getting user from database', () {
    test('correct output', () async {
      CollectionReference<Map<String, dynamic>> mockCollection =
          MockCollectionReference();
      DocumentReference<Map<String, dynamic>> mockReference =
          MockDocumentReference();
      DocumentSnapshot<Map<String, dynamic>> mockSnapshot0 = MockDocumentSnapshot();
      DocumentSnapshot<Map<String, dynamic>> mockSnapshot1 = MockDocumentSnapshot();
      when(mockFirebaseFirestore.collection('users'))
          .thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(mockUserJson0['uid']))
          .thenAnswer((realInvocation) => mockReference);
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
      expect(users[1]!.birthday.toString().substring(0,10), mockUserJson1['birthday']);
    });

    test('does not return a user because result from database is incorrect', () async {
      mockUserJson0['birthday'] = 'test';
      CollectionReference<Map<String, dynamic>> mockCollection =
          MockCollectionReference();
      DocumentReference<Map<String, dynamic>> mockReference =
          MockDocumentReference();
      DocumentSnapshot<Map<String, dynamic>> mockSnapshot0 = MockDocumentSnapshot();
      when(mockFirebaseFirestore.collection('users'))
          .thenAnswer((realInvocation) => mockCollection);
      when(mockCollection.doc(mockUserJson0['uid']))
          .thenAnswer((realInvocation) => mockReference);
      when(mockReference.snapshots()).thenAnswer((invocation) => Stream.fromIterable([mockSnapshot0]));
      when(mockSnapshot0.data()).thenReturn(mockUserJson0);
      List<User?> users = await database.getUser(mockUserJson0['uid']).toList();
      expect(users[0], null);
    });

    test('throws exception', () {
      when(mockFirebaseFirestore.collection('users'))
          .thenThrow(FirebaseException(plugin: 'test'));
      expect(() => database.getUser('test'), throwsA(isA<DatabaseException>()));
    });


  });
}
