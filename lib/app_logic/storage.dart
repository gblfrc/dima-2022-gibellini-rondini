import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';

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

  static FutureBuilder profilePictureOrAccountIcon(User user) {
    return FutureBuilder(
        future: downloadURL(user.uid),
        builder: (context, snaphsot) {
          if (snaphsot.hasError) {
            return const Icon(Icons.account_circle);
          } else if (snaphsot.hasData) {
            return Image.network(snaphsot.data);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
