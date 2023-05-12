import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
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
    // collect hashes for the four corners and for the center
    List<String> hashes = [];
    var northEast = bounds.northEast ?? LatLng(bounds.north, bounds.east);
    var southWest = bounds.southWest ?? LatLng(bounds.south, bounds.west);
    hashes.add(GeoHasher().encode(bounds.northWest.longitude,bounds.northWest.latitude, precision: 6));
    hashes.add(GeoHasher().encode(northEast.longitude,northEast.latitude, precision: 6));
    hashes.add(GeoHasher().encode(southWest.longitude,southWest.latitude, precision: 6));
    hashes.add(GeoHasher().encode(bounds.southEast.longitude,bounds.southEast.latitude, precision: 6));
    hashes.add(GeoHasher().encode(bounds.center.longitude,bounds.center.latitude, precision: 6));
    // sort alphabetically
    hashes.sort();
    List<Proposal> newList = [];
    List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
    // future for public proposals
    futures.add(FirebaseFirestore.instance
        .collection("proposals")
        .where('place.geohash', isGreaterThanOrEqualTo: hashes[0])
        .where('place.geohash', isLessThanOrEqualTo: hashes[hashes.length-1])
        .where('type', isEqualTo: 'Public')
        .get());
    for (var future in futures) {
      await future.then((snapshot) async {
      for (var doc in snapshot.docs) {
        // extract content of documents as json
        Map<String, dynamic> json = doc.data();
        // check on position insider map boundaries
        var placeGeoPoint = json['place']['coords'] as GeoPoint;
        if (!bounds.contains(LatLng(placeGeoPoint.latitude, placeGeoPoint.longitude))){
          continue;
        }
        // build actual proposal object
        var ownerRef = json['owner'] as DocumentReference;
        var dateTime = (json['dateTime'] as Timestamp).toDate().toString();
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
    }
    return newList;
  }
}

//{owner: DocumentReference<Map<String, dynamic>>(users/SjM8IQQiqbV3q60PlSTr9qnZpI92),
//dateTime: Timestamp(seconds=1683652518, nanoseconds=35000000),
//place: {name: Parco Suardi, id: 11694848, coords: Instance of 'GeoPoint'},
//type: Friends}
