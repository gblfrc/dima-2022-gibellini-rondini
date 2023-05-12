import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
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
    List<Proposal> newList = [];
    await FirebaseFirestore.instance.collection("proposals").get().then(
        (snapshot) async {
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLatestSessions({int? limit}) {
    final userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(Auth().currentUser?.uid);
    Query<Map<String, dynamic>> docSession = FirebaseFirestore.instance
        .collection("sessions")
        .where("userID", isEqualTo: userDocRef)
        .orderBy("startDT", descending: true);
    if(limit != null) {
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
}

//{owner: DocumentReference<Map<String, dynamic>>(users/SjM8IQQiqbV3q60PlSTr9qnZpI92),
//dateTime: Timestamp(seconds=1683652518, nanoseconds=35000000),
//place: {name: Parco Suardi, id: 11694848, coords: Instance of 'GeoPoint'},
//type: Friends}
