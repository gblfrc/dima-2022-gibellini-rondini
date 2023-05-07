import 'package:firebase_auth/firebase_auth.dart';
import 'package:progetto/app_logic/exceptions.dart';

// Created followin the video:
// https://www.youtube.com/watch?v=rWamixHIKmQ
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: email, password: password);
      return credential;
    } on FirebaseAuthException {
      throw AuthenticationException("Couldn't authenticate user.");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }


}
