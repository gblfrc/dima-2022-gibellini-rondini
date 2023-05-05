import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFile(String path, String filename) async {
    File file = File(path);
    try {
      await storage.ref('profile-pictures/$filename').putFile(file);
    } on FirebaseException catch (e){
      print(e);
    }
  }

  Future<String> downloadURL (String filename) async {
    return await storage.ref('profile-pictures/$filename').getDownloadURL();
  }


}
