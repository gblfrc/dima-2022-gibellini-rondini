import 'package:firebase_auth/firebase_auth.dart';
import 'package:progetto/app_logic/exceptions.dart';

/*
* Originally created following the video: https://www.youtube.com/watch?v=rWamixHIKmQ
*
* This class is meant to be a singleton to handle authentication by interacting
* with the Firebase Authentication services.
*/
class Auth {
  static late Auth _instance;
  late FirebaseAuth _auth;

  /*
  * Factory method to create the instance of the singleton.
  * If parameter firebaseAuth is not passed, the singleton will work with usual
  * Firebase Authentication services. Setting a different parameter to the
  * constructor is mainly needed in testing phases.
  */
  factory Auth({FirebaseAuth? firebaseAuth}) {
    try {
      return (_instance);
    } on Error {
      _instance = Auth._internal(firebaseAuth);
      return _instance;
    }
  }

  /*
  * Internal constructor; follows common naming convention for dart singletons.
  * For parameter meaning, see factory constructor above.
  */
  Auth._internal(FirebaseAuth? firebaseAuth) {
    _auth = firebaseAuth ?? FirebaseAuth.instance;
  }

  // Getter methods
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Type get authType => _auth.runtimeType; // mostly for debugging purposes

  /*
  * Method to allow sign-in with email and password. Returns UserCredential object
  * for just-logged user if no error occurs, otherwise throws AuthenticationException.
  * */
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      var credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (fae) {
      throw AuthenticationException(fae.message);
    }
  }

  /*
  * Method to allow user creation with email and password. Returns UserCredential
  * object for just-logged user if no error occurs, otherwise throws
  * AuthenticationException.
  * */
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (fae) {
      throw AuthenticationException(fae.message);
    }
  }

  /*
  * Method to delete the current user.
  */
  Future<void> deleteUser() async {
    try {
      return await _auth.currentUser?.delete();
    } on FirebaseAuthException catch(fae){
      throw AuthenticationException(fae.message);
    }
  }

  /*
  * Method for user sign-out. Cannot throw exceptions.
  * */
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
