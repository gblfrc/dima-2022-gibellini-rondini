import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/app_logic/exceptions.dart';

import '../model/proposal.dart';
import '../model/user.dart';
import 'auth.dart';

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

  static Future<List<DocumentSnapshot>> getProposals() async {
    final userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(Auth().currentUser?.uid);

    // Get the list of people that have added the current user to their friends
    final friendOfList = FirebaseFirestore.instance
        .collection("users")
        .where("friends", arrayContains: userDocRef);
    final friendOfSnapshot = await friendOfList.get();
    final friendOfDocs = friendOfSnapshot.docs;
    List<DocumentReference> friendOfDocRefs = [];
    for (var friendDoc in friendOfDocs) {
      friendOfDocRefs.add(friendDoc.reference);
    }

    if (friendOfDocRefs.isEmpty) {
      // We need this check since whereIn doesn't accept an empty array
      List<DocumentSnapshot> emptyList = [];
      return emptyList;
    }
    // Get the proposals made by all the people returned by the previous query that are not expired
    final docProposals = FirebaseFirestore.instance
        .collection("proposals")
        .where("owner",
            whereIn:
                friendOfDocRefs) // TODO: Split friendOfDocRefs if the length is > 10 because of whereIn limit
        .where("dateTime", isGreaterThanOrEqualTo: Timestamp.now());
    final querySnapshot =
        await docProposals.get(); // This get returns QuerySnapshot
    return querySnapshot.docs;
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
        .where('type', isEqualTo: 'Friends')
        .get());
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
        if (ownerRef.id == uid) continue; // discard object if owner is logged user
        json['owner'] = await ownerRef.get().then((snapshot) {
          var userData = snapshot.data() as Map<String, dynamic>;
          // check if current user is friend of proposal owner
          if (json['type'] == 'Friends'){
            var friends = userData['friends'];
            var friendIds = [];
            for (DocumentReference friend in friends) {friendIds.add(friend.id);}
            if (!friendIds.contains(uid)) return null;
          }
          userData['uid'] = snapshot.id;
          return userData;
        });
        if (json['owner'] == null) continue;
        var dateTime = (json['dateTime'] as Timestamp).toDate().toString();
        json['pid'] = doc.id;
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

  static Future<List<User>> getFriends() async {
    final userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(Auth().currentUser?.uid);

    final userSnapshot = await userDocRef.get();
    final friendRefs = userSnapshot.get("friends");
    List<User> friends = [];
    for (var friend in friendRefs) {
      DocumentSnapshot friendDoc = await friend.get();
      friends.add(
        User(
          name: friendDoc.get('name'),
          surname: friendDoc.get('surname'),
          uid: friend.id,
        ),
      );
    }
    return friends;
  }

  static void addFriend(String user, String friend) async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(user);
    final docFriend =
        FirebaseFirestore.instance.collection("users").doc(friend);
    try {
      await docUser.update(
        {
          'friends': FieldValue.arrayUnion([docFriend]),
        },
      );
    } on Exception {
      throw DatabaseException('An error occurred while adding friend.');
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLatestSessions(
      {int? limit}) {
    final userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(Auth().currentUser?.uid);
    Query<Map<String, dynamic>> docSession = FirebaseFirestore.instance
        .collection("sessions")
        .where("userID", isEqualTo: userDocRef)
        .orderBy("startDT", descending: true);
    if (limit != null) {
      docSession = docSession.limit(limit);
    }
    return docSession.snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getGoals() {
    final userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(Auth().currentUser?.uid);
    final docUser = FirebaseFirestore.instance
        .collection("goals")
        .where("userID", isEqualTo: userDocRef);
    return docUser.snapshots();
  }

  static Future<void> createGoal(double targetValue, String type) async {
    try {
      final uid = Auth().currentUser?.uid;
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      final data = {
        "completed": false,
        "currentValue": 0,
        "targetValue": targetValue,
        "type": type,
        "userID": docUser,
        // TODO: When writing Firestore rules, remember to check that this docUser.id is equal to the actual user
      };
      await FirebaseFirestore.instance.collection("goals").add(data);
    } on Error {
      throw DatabaseException("An error occurred while creating goal.");
    } on Exception {
      throw DatabaseException("An error occurred while creating goal.");
    }
  }
}

//{owner: DocumentReference<Map<String, dynamic>>(users/SjM8IQQiqbV3q60PlSTr9qnZpI92),
//dateTime: Timestamp(seconds=1683652518, nanoseconds=35000000),
//place: {name: Parco Suardi, id: 11694848, coords: Instance of 'GeoPoint'},
//type: Friends}
