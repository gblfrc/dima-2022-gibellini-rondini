import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/exceptions.dart';

class MockUser extends Mock implements User {}
final _mockUser = MockUser();
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User?> authStateChanges() {
    return Stream.fromIterable([_mockUser]);
  }

  @override
  User? get currentUser => _mockUser;
}
class MockFirebaseAuth2 extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}

main() {
  late Auth auth;
  late FirebaseAuth mockFirebaseAuth;

  setUpAll(() {
    mockFirebaseAuth = MockFirebaseAuth();
    auth = Auth(firebaseAuth: mockFirebaseAuth);
  });

  test('singleton properties', () {
    var auth1 = Auth();
    var auth2 = Auth(firebaseAuth: MockFirebaseAuth2());
    expect(auth, auth1);
    expect(auth, auth2);
    expect(auth2.authType, mockFirebaseAuth.runtimeType);
  });

  test('auth state changes', () async {
    expectLater(auth.authStateChanges, emitsInOrder([_mockUser]));
  });

  test('current user getter', () async {
    expect(auth.currentUser, _mockUser);
  });


  group('create user with email and password', () {
    test('correct output', () async {
      String email = 'email@email.com';
      String password = 'password';
      MockUserCredential mockCredential = MockUserCredential();
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password),
      ).thenAnswer((realInvocation) => Future.value(mockCredential));
      expect(
          await auth.createUserWithEmailAndPassword(
              email: email, password: password),
          mockCredential);
    });

    test('exception', () async {
      String email = 'email';
      String password = 'password';
      when(
            () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password),
      ).thenThrow(FirebaseAuthException(code: 'invalid-email'));
      try {
        await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        expect(false, true);
      } on AuthenticationException {
        expect(true, true);
      }
    });
  });


  group('sign in with email and password', () {
    test('correct output', () async {
      String email = 'email@email.com';
      String password = 'password';
      MockUserCredential mockCredential = MockUserCredential();
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email, password: password),
      ).thenAnswer((realInvocation) => Future.value(mockCredential));
      expect(
          await auth.signInWithEmailAndPassword(
              email: email, password: password),
          mockCredential);
    });

    test('exception', () async {
      String email = 'email';
      String password = 'password';
      when(
            () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email, password: password),
      ).thenThrow(FirebaseAuthException(code: 'invalid-email'));
      try {
        await auth.signInWithEmailAndPassword(
            email: email, password: password);
        expect(false, true);
      } on AuthenticationException {
        expect(true, true);
      }
    });
  });

  test('sign out', () async {
    when(() => mockFirebaseAuth.signOut()).thenAnswer((invocation) => Future.value(null));
    await auth.signOut();
    expect(true, true);
  });
}
