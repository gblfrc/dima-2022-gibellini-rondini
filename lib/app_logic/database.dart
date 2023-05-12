import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/exceptions.dart';

import '../model/proposal.dart';
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

  static Future<List<Proposal>> getProposalsWithinBoundsGivenUser(
      LatLngBounds bounds, String uid) async {
    List<Proposal> newList = [];
    await FirebaseFirestore.instance
        .collection("proposals")
        .get()
        .then((snapshot) async {
      for (var doc in snapshot.docs) {
        Map<String, dynamic> json = doc.data();
        var ownerRef = json['owner'] as DocumentReference;
        var dateTime = (json['dateTime'] as Timestamp).toDate().toString();
        var placeGeoPoint = json['place']['coords'] as GeoPoint;
        json['pid'] = doc.id;
        json['owner'] = await ownerRef.get().then((snapshot) {
          var userData = snapshot.data() as Map<String, dynamic>;
          userData['uid'] = snapshot.id;
          return userData;
        });
        json['dateTime'] = dateTime;
        json['place']['lat'] = placeGeoPoint.latitude;
        json['place']['lon'] = placeGeoPoint.longitude;
        newList.add(Proposal.fromJson(json));
      }
    }, onError: (e) {
      print("Error completing: $e");
    });
    return newList;
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

//{owner: DocumentReference<Map<String, dynamic>>(users/SjM8IQQiqbV3q60PlSTr9qnZpI92),
//dateTime: Timestamp(seconds=1683652518, nanoseconds=35000000),
//place: {name: Parco Suardi, id: 11694848, coords: Instance of 'GeoPoint'},
//type: Friends}
