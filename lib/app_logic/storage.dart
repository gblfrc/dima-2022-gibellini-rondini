import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  static Future<void> uploadFile(String path, String filename) async {
    File file = File(path);
    try {
      await FirebaseStorage.instance
          .ref('profile-pictures/$filename')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  static Future<String> downloadURL(String filename) async {
    return await FirebaseStorage.instance
        .ref('profile-pictures/$filename')
        .getDownloadURL();
  }

}
