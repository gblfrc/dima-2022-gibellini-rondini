import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/model/session.dart';

import '../model/goal.dart';
import '../model/place.dart';
import '../model/proposal.dart';
import '../model/user.dart';
import 'auth.dart';

/*
* This class aims at being a singleton interface for the interaction with the
* database, currently provided by the Firebase Firestore service.
*/
class Database {
  static late Database _instance;
  late FirebaseFirestore _database;

  /*
  * Factory method to create the instance of the singleton.
  * If parameter firebaseFirestore is not passed, the singleton will work with
  * usual Firebase Firestore services. Setting a different parameter to the
  * constructor is mainly needed in testing phases.
  */
  factory Database({FirebaseFirestore? firebaseFirestore}) {
    try {
      return _instance;
    } on Error {
      _instance = Database._internal(firebaseFirestore: firebaseFirestore);
      return _instance;
    }
  }

  /*
  * Internal constructor; follows common naming convention for dart singletons.
  * For parameter meaning, see factory constructor above.
  */
  Database._internal({FirebaseFirestore? firebaseFirestore}) {
    _database = firebaseFirestore ?? FirebaseFirestore.instance;
  }

  // Getter for the type of database, mainly needed for testing and debugging.
  Type get databaseType => _database.runtimeType;

  /*
  * Method to save on the database the instance of a user which is not already
  * present on the database.
  * Throws a database exception if something wrong happens in the communication
  * with the database.
  */
  void createUser(User user) async {
    try {
      await _database.collection("users").doc(user.uid).set(
        {
          "name": user.name,
          "surname": user.surname,
          "birthday": user.birthday != null ? DateFormat('yyyy-MM-dd').format(user.birthday!) : null,
        },
      );
    } on FirebaseException {
      throw DatabaseException("Couldn't create user");
    }
  }

  /*
  * Method to update the information on the database for a user which is already
  * present on the database.
  * Throws a database exception if something wrong happens in the communication
  * with the database.
  */
  void updateUser(User user) async {
    try {
      final docUser = _database.collection('users').doc(user.uid);
      await docUser.update(
        {
          'name': user.name,
          'surname': user.surname,
          'birthday': user.birthday != null ? DateFormat('yyyy-MM-dd').format(user.birthday!) : null,
        },
      );
    } on FirebaseException {
      throw DatabaseException('An error occurred while updating user information.');
    }
  }

  /*
  * Method to obtain the instance of a User from the database having the uid
  * which can be specified as parameter. Throws a Database exception if something
  * wrong happens in the communication with the database. Returns a null object
  * instead of a User if some of the extracted data are illegal.
  */
  Stream<User?> getUser(String uid) {
    try {
      final docUser = _database.collection("users").doc(uid);
      return docUser.snapshots().map((doc) {
        try {
          Map<String, dynamic> json = doc.data()!;
          json['uid'] = uid;
          return User.fromJson(json);
        } on Exception {
          return null;
        }
      });
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  /*
  * Function to retrieve the Proposal objects available for a specific user,
  * whose uid must be passed as parameter. The method retrieves all friend-only
  * proposals owned by those users who registered the provided one in their
  * friends. This method throws a DatabaseException in case some error happens
  * in the communication with the database. If some data are illegal in a
  * document obtained from the server and some error occurs while parsing data,
  * a null object is returned.
  */
  Future<List<Proposal?>> getFriendProposalsAfterTimestamp(String uid, {required Timestamp after}) async {
    try {
      // Create document reference for current user
      final currentUserRef = _database.collection("users").doc(uid);
      // Get the list of users that have added the current user to their friends
      final friendOfSnapshot =
          await _database.collection("users").where("friends", arrayContains: currentUserRef).get();
      // Create list of document references for friends
      List<DocumentReference> friendOfDocRefs = [];
      for (var doc in friendOfSnapshot.docs) {
        friendOfDocRefs.add(doc.reference);
      }
      // Return empty list if list of friends is empty
      // Check needed since whereIn clause doesn't accept empty arrays
      if (friendOfDocRefs.isEmpty) {
        return List.empty();
      }
      // Query database on non-passed proposals whose owner is in the list defined above
      List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
      // Split friendOfDocRefs because whereIn clause accepts at most 10 elements
      List<List<DocumentReference>> splitRefs = [];
      for (int i = 0; i < friendOfDocRefs.length; i += 10) {
        splitRefs.add(friendOfDocRefs.sublist(i, min(i + 10, friendOfDocRefs.length)));
      }
      // Create queries for each batch of split references
      for (int i = 0; i < splitRefs.length; i++) {
        futures.add(_database
            .collection("proposals")
            .where("owner", whereIn: splitRefs[i])
            .where("dateTime", isGreaterThanOrEqualTo: after)
            .get());
      }
      // Get proposals from returned documents
      List<Proposal?> proposals = [];
      for (var future in futures) {
        await future.then((snapshot) async {
          for (var doc in snapshot.docs) {
            Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: uid);
            if (proposal != null) proposals.add(proposal);
          }
        });
      }
      return proposals;
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Future<List<Proposal>> getProposalsWithinBounds(LatLngBounds bounds, String uid, {Timestamp? after}) async {
    // collect hashes for the four corners and for the center
    List<String> hashes = [];
    var northEast = bounds.northEast ?? LatLng(bounds.north, bounds.east);
    var southWest = bounds.southWest ?? LatLng(bounds.south, bounds.west);
    hashes.add(GeoHasher().encode(bounds.northWest.longitude, bounds.northWest.latitude, precision: 9));
    hashes.add(GeoHasher().encode(northEast.longitude, northEast.latitude, precision: 9));
    hashes.add(GeoHasher().encode(southWest.longitude, southWest.latitude, precision: 9));
    hashes.add(GeoHasher().encode(bounds.southEast.longitude, bounds.southEast.latitude, precision: 9));
    hashes.add(GeoHasher().encode(bounds.center.longitude, bounds.center.latitude, precision: 9));
    // sort alphabetically
    hashes.sort();
    List<Proposal> newList = [];
    List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
    // future for public proposals
    try {
      futures.add(_database
          .collection("proposals")
          .where('place.geohash', isGreaterThanOrEqualTo: hashes[0].substring(0, 6))
          .where('place.geohash', isLessThanOrEqualTo: hashes[hashes.length - 1])
          .where('type', isEqualTo: 'Friends')
          .get());
      futures.add(_database
          .collection("proposals")
          .where('place.geohash', isGreaterThanOrEqualTo: hashes[0].substring(0, 6))
          .where('place.geohash', isLessThanOrEqualTo: hashes[hashes.length - 1])
          .where('type', isEqualTo: 'Public')
          .get());
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
    for (var future in futures) {
      await future.then((snapshot) async {
        for (var doc in snapshot.docs) {
          // exclude proposals if they are out of bounds or before the timestamp specified in the after parameter
          try {
            var placeGeoPoint = doc.data()['place']['coords'] as GeoPoint;
            var dateTime = (doc.data()['dateTime'] as Timestamp).toDate();
            if (!bounds.contains(LatLng(placeGeoPoint.latitude, placeGeoPoint.longitude)) ||
                (after != null && dateTime.isBefore(after.toDate()))) {
              continue;
            }
          } on Error {
            continue;
          }
          Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: uid);
          if (proposal != null) {
            newList.add(proposal);
          }
        }
      });
    }
    // sort output list to return proposals ordered by date
    newList.sort((a,b) => a.dateTime.compareTo(b.dateTime));
    return newList;
  }

  static Future<List<User>> getFriends() async {
    final userDocRef = FirebaseFirestore.instance.collection("users").doc(Auth().currentUser?.uid);

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

  void addFriend(String friend) async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(Auth().currentUser!.uid);
    final docFriend = FirebaseFirestore.instance.collection("users").doc(friend);
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

  static void removeFriend(String friend) async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(Auth().currentUser!.uid);
    final docFriend = FirebaseFirestore.instance.collection("users").doc(friend);
    try {
      await docUser.update(
        {
          'friends': FieldValue.arrayRemove([docFriend]),
        },
      );
    } on Exception {
      throw DatabaseException('An error occurred while removing friend.');
    }
  }

  Stream<List<Session?>> getLatestSessionsByUser(String uid, {int? limit}) async* {
    List<Session?> sessions = [];
    final userDocRef = FirebaseFirestore.instance.collection("users").doc(uid);
    var sessionDocs = FirebaseFirestore.instance
        .collection("sessions")
        .where("userID", isEqualTo: userDocRef)
        .orderBy("startDT", descending: true)
        // limit query to parameter or to a very high number
        // number could be even higher, but then it causes problems with Firestore
        .limit(limit ?? 10000);
    // process snapshots
    await for (var snapshot in sessionDocs.snapshots()) {
      // clean session array for each snapshot
      sessions = [];
      for (var doc in snapshot.docs) {
        // create a Session object for each document
        Map<String, dynamic> json = doc.data();
        json['id'] = doc.id;
        json['start'] = (json['startDT'] as Timestamp).toDate();
        List<List<LatLng>> positions = [];
        for (var sublist in (json['positions'] as List)) {
          var list = (sublist as Map)['values'] as List;
          var segment = list.map((pos) => LatLng(pos.latitude, pos.longitude)).toList();
          positions.add(segment);
        }
        json['positions'] = positions;
        json['owner'] = null;
        var session = Session.fromJson(json);
        if (session != null) sessions.add(session);
      }
      yield sessions;
    }
  }

  Stream<List<Goal>> getGoals(bool inProgressOnly) async* {
    final userDocRef = FirebaseFirestore.instance.collection("users").doc(Auth().currentUser?.uid);
    var docGoals = FirebaseFirestore.instance.collection("goals").where("owner", isEqualTo: userDocRef);
    if (inProgressOnly) {
      docGoals = docGoals.where("completed", isEqualTo: false);
    }
    docGoals = docGoals.orderBy("createdAt", descending: true);
    /*return docUser.snapshots();*/
    await for (QuerySnapshot<Map<String, dynamic>> snapshot in docGoals.snapshots()) {
      List<Goal> goals = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        Map<String, dynamic> json = doc.data();
        json['id'] = doc.id;
        json['owner'] = null; // TODO: Maybe it is better to add the user
        json['createdAt'] = (json['createdAt'] as Timestamp).toDate();
        goals.add(Goal.fromJson(json));
      }
      yield goals;
    }
  }

  Future<void> createGoal(Goal goal) async {
    try {
      final uid = Auth().currentUser?.uid;
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      final data = {
        "completed": goal.completed,
        "currentValue": goal.currentValue,
        "targetValue": goal.targetValue,
        "type": goal.type,
        "createdAt": Timestamp.fromDate(goal.creationDate),
        "owner": docUser,
        // TODO: When writing Firestore rules, remember to check that this docUser.id is equal to the actual user
      };
      await FirebaseFirestore.instance.collection("goals").add(data);
    } on Error {
      throw DatabaseException("An error occurred while creating goal.");
    } on Exception {
      throw DatabaseException("An error occurred while creating goal.");
    }
  }

  Future<void> deleteGoal(Goal goal) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(goal.id).delete();
    } on Error {
      throw DatabaseException("An error occurred while deleting goal.");
    } on Exception {
      throw DatabaseException("An error occurred while deleting goal.");
    }
  }

  void createProposal(Proposal proposal) async {
    try {
      await FirebaseFirestore.instance.collection("proposals").add(
        {
          "dateTime": Timestamp.fromDate(proposal.dateTime),
          "owner": FirebaseFirestore.instance.collection('users').doc(proposal.owner.uid),
          "place": {
            "coords": GeoPoint(proposal.place.coords.latitude, proposal.place.coords.longitude),
            "geohash":
                GeoHasher().encode(proposal.place.coords.longitude, proposal.place.coords.latitude, precision: 9),
            "id": proposal.place.id,
            "latitude": proposal.place.coords.latitude,
            "longitude": proposal.place.coords.longitude,
            "name": proposal.place.name,
            "city": proposal.place.city,
            "state": proposal.place.state,
            "country": proposal.place.country,
            "type": proposal.place.type
          },
          "participants": [],
          "type": proposal.type,
        },
      );
    } on FirebaseException {
      throw DatabaseException("Couldn't create proposal");
    }
  }

  void addParticipantToProposal(Proposal proposal) async {
    try {
      var uid = Auth().currentUser!.uid;
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await FirebaseFirestore.instance.collection('proposals').doc(proposal.id).update({
        'participants': FieldValue.arrayUnion([userRef])
      });
    } on FirebaseException {
      throw DatabaseException("An error occurred when joining the proposal");
    }
  }

  void removeParticipantFromProposal(Proposal proposal) async {
    try {
      var uid = Auth().currentUser!.uid;
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await FirebaseFirestore.instance.collection('proposals').doc(proposal.id).update({
        'participants': FieldValue.arrayRemove([userRef])
      });
    } on FirebaseException {
      throw DatabaseException("An error occurred when joining the proposal");
    }
  }

  Future<List<Proposal?>> getProposalsByPlace(Place place, String uid) async {
    // future for public proposals
    List<Proposal?> list = [];
    var future = FirebaseFirestore.instance.collection("proposals").where('place.id', isEqualTo: place.id).get();
    await future.then((snapshot) async {
      for (var doc in snapshot.docs) {
        Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: uid);
        if (proposal != null) list.add(proposal);
      }
    }, onError: (e) {
      throw DatabaseException("Couldn't get proposals for the requested place.");
    });
    return list;
  }

  Stream<List<Proposal>> getUpcomingProposals(String uid) async* {
    List<Proposal?> proposalsTemp = [];
    List<Proposal> proposals = [];
    final currentUserRef = FirebaseFirestore.instance.collection("users").doc(uid);
    // Filter session in the range of 2 hours (in the past or in the future)
    DateTime now = DateTime.now();
    DateTime upperBound = now.add(const Duration(hours: 2));
    DateTime lowerBound = now.add(const Duration(hours: -2));
    // Sessions proposed by others
    QuerySnapshot<Map<String, dynamic>> proposalsDocs = await FirebaseFirestore.instance
        .collection("proposals")
        .where("participants", arrayContains: currentUserRef)
        .where("dateTime", isLessThanOrEqualTo: Timestamp.fromDate(upperBound))
        .where("dateTime",
            isGreaterThanOrEqualTo: Timestamp.fromDate(lowerBound)) // TODO: Add filter for completed proposals
        .get();
    // Sessions proposed by the user
    QuerySnapshot<Map<String, dynamic>> proposalsDocsOwned = await FirebaseFirestore.instance
        .collection("proposals")
        .where("owner", isEqualTo: currentUserRef)
        .where("dateTime", isLessThanOrEqualTo: Timestamp.fromDate(upperBound))
        .where("dateTime",
            isGreaterThanOrEqualTo: Timestamp.fromDate(lowerBound)) // TODO: Add filter for completed proposals
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in proposalsDocs.docs) {
      proposalsTemp.add(await _proposalFromFirestore(doc, currentUserUid: uid));
    }
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in proposalsDocsOwned.docs) {
      proposalsTemp.add(await _proposalFromFirestore(doc,
          currentUserUid: uid)); // TODO: Not doing anything: fix this with a new version of _proposalFromFirestore
    }
    for (Proposal? temp in proposalsTemp) {
      // TODO: Fix this with a new version of _proposalFromFirestore
      if (temp != null) {
        proposals.add(temp);
      }
    }
    yield proposals;
  }

  /*
  * Function to create a Proposal object starting from a Document from Firestore.
  * Can be set to exclude proposals from current user by setting parameter
  * excludeUser to true. Returns null if current user is owner or is not friend
  * of the owner of the proposal.
  */
  Future<Proposal?> _proposalFromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc,
      {required String currentUserUid, bool excludeCurrentUser = true}) async {
    try {
      // create convenience variables
      Map<String, dynamic> json = doc.data();
      // discard proposal if current user is owner
      var ownerRef = json['owner'] as DocumentReference;
      if (excludeCurrentUser && ownerRef.id == currentUserUid) {
        return null;
      }
      // obtain information about proposal owner and discard if current user is
      // not friend of the proposal owner
      json['owner'] = await ownerRef.get().then((snapshot) {
        var userData = snapshot.data() as Map<String, dynamic>;
        // check if current user is friend of proposal owner
        if (json['type'] == 'Friends') {
          var friends = userData['friends'];
          var friendIds = [];
          for (DocumentReference friend in friends) {
            friendIds.add(friend.id);
          }
          if (!friendIds.contains(currentUserUid)) {
            return null;
          }
        }
        userData['uid'] = snapshot.id;
        return userData;
      });
      if (json['owner'] == null) {
        return null;
      }
      // build object
      String dateTime = (json['dateTime'] as Timestamp).toDate().toString();
      json['pid'] = doc.id;
      json['dateTime'] = dateTime;
      GeoPoint placeGeoPoint = json['place']['coords'] as GeoPoint;
      json['place']['lat'] = placeGeoPoint.latitude;
      json['place']['lon'] = placeGeoPoint.longitude;
      List<DocumentReference> participants =
          (json['participants'] as List).map((item) => item as DocumentReference).toList();
      json['participants'] = participants.map((item) => item.id).toList();
      return Proposal.fromJson(json);
    } on Error {
      return null;
    }
  }
}
