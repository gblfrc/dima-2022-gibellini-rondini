import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'exceptions.dart';

/*
* This class is meant to be a singleton to handle a storage of content needed in
* the application. It handles the interaction with the Firebase Storage services.
*/
class Storage {
  static late Storage _instance;
  late FirebaseStorage _storage;

  // Getter for the type of storage, mainly needed for testing and debugging.
  Type get storageType => _storage.runtimeType;

  /*
  * Factory method to create the instance of the singleton.
  * If parameter firebaseStorage is not passed, the singleton will work with usual
  * Firebase Storage services. Setting a different parameter to the constructor
  * is mainly needed in testing phases.
  */
  factory Storage({FirebaseStorage? firebaseStorage}) {
    try {
      return _instance;
    } on Error {
      _instance = Storage._internal(firebaseStorage);
      return _instance;
    }
  }

  /*
  * Internal constructor; follows common naming convention for dart singletons.
  * For parameter meaning, see factory constructor above.
  */
  Storage._internal(FirebaseStorage? firebaseStorage) {
    _storage = firebaseStorage ?? FirebaseStorage.instance;
  }

  /*
  * Method to upload a file to the storage. It requires two parameters:
  * - the local path to the file to upload (localPath),
  * - the destination path on the server, including the name of the file (remotePath).
  * If no error occurs during the upload, the method returns smoothly, otherwise
  * it throws a StorageException.
  */
  Future<void> uploadFile(File file, String remotePath) async {
    try {
      await _storage.ref(remotePath).putFile(file);
    } on FirebaseException catch (fe) {
      throw StorageException(fe.message);
    }
  }

  /*
  * Method to obtain the URL of a file given its name, which should be passed in
  * parameter filename. It returns the URL String if no error occurs, otherwise
  * it returns a Future with error.
  */
  Future<String> downloadURL(String remotePath) async {
    try {
      return await _storage.ref(remotePath).getDownloadURL();
    } on FirebaseException catch (fe) {
      return Future.error(StorageException(fe.message));
    }
  }
}
