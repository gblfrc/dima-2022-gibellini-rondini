import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/exceptions.dart';

import '../model/user.dart';

class Database {
  static void createUser(User user) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
        {
          "name": user.name,
          "surname": user.surname,
          "birthday": DateFormat('yyyy-MM-dd').format(user.birthday!),
        },
      );
    } on FirebaseException {
      throw DatabaseException("Couldn't create user");
    }
  }

  static void updateUser(User user) async {
    try {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docUser.update(
        {
          'name': user.name,
          'surname': user.surname,
          'birthday': DateFormat('yyyy-MM-dd').format(user.birthday!),
        },
      );
    } on Exception {
      throw DatabaseException(
          'An error occurred while updating user information.');
    }
  }

  static Stream<User?> getUser(String uid) {
    final docUser = FirebaseFirestore.instance.collection("users").doc(uid);
    return docUser.snapshots().map((doc) {
      Map<String, dynamic> json = doc.data()!;
      json['uid'] = uid;
      return User.fromJson(json);
    });
  }

  static void addFriend(String user, String friend) async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(user);
    final docFriend = FirebaseFirestore.instance.collection("users").doc(friend);
    try {
      await docUser.update(
        {
          'friends': FieldValue.arrayUnion([docFriend]),
        },
      );
    } on Exception {
      throw DatabaseException(
          'An error occurred while adding friend.');
    }
  }
}
