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
  void createUser({required String uid, required String name, required String surname, DateTime? birthday}) async {
    try {
      await _database.collection("users").doc(uid).set(
        {
          "name": name,
          "surname": surname,
          "birthday": birthday != null ? DateFormat('yyyy-MM-dd').format(birthday) : null,
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
  Future<List<Proposal?>> getFriendProposalsAfterTimestamp(String currentUserUid, {required DateTime after}) async {
    try {
      // Get the list of users that have added the current user to their friends
      final friendOfSnapshot =
          await _database.collection("users").where("friends", arrayContains: currentUserUid).get();
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
            Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: currentUserUid);
            if (proposal != null) proposals.add(proposal);
          }
        });
      }
      return proposals;
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Future<List<Proposal>> getProposalsWithinBounds(LatLngBounds bounds, String uid, {DateTime? after}) async {
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
                (after != null && dateTime.isBefore(after))) {
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
    newList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return newList;
  }

  Future<bool> isFriendOf({required String currentUserUid, required String friendUid}) async {
    try {
      var snapshot = await _database
          .collection('users')
          .where('__name__', isEqualTo: currentUserUid)
          .where('friends', arrayContains: friendUid)
          .get();
      if (snapshot.docs.isEmpty) {
        return false;
      } else {
        return true;
      }
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Stream<List<User>> getFriends(String uid) async* {
    try {
      final userDocRef = _database.collection("users").doc(uid);
      await for (DocumentSnapshot<Map<String, dynamic>> snapshot in userDocRef.snapshots()) {
        List<User> friends = [];
        for(String fuid in snapshot.get("friends")) {
          DocumentReference friendRef = _database.collection("users").doc(fuid);
          DocumentSnapshot friendDoc = await friendRef.get();
          friends.add(
            User(
              name: friendDoc.get('name'),
              surname: friendDoc.get('surname'),
              uid: friendDoc.id,
            ),
          );
        }
        yield friends;
      }
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  void addFriend({required String currentUserUid, required String friendUid}) async {
    try {
      final docUser = _database.collection("users").doc(currentUserUid);
      await docUser.update(
        {
          'friends': FieldValue.arrayUnion([friendUid]),
        },
      );
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  void removeFriend({required String currentUserUid, required String friendUid}) async {
    try {
      final docUser = _database.collection("users").doc(currentUserUid);
      await docUser.update(
        {
          'friends': FieldValue.arrayRemove([friendUid]),
        },
      );
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Stream<List<Session?>> getLatestSessionsByUser(String uid, {int? limit}) async* {
    List<Session?> sessions = [];
    Query<Map<String, dynamic>> sessionQuery;
    try {
      final userDocRef = _database.collection("users").doc(uid);
      sessionQuery = _database
          .collection("sessions")
          .where("userID", isEqualTo: userDocRef)
          .orderBy("startDT", descending: true)
          // limit query to parameter or to a very high number
          // number could be even higher, but then it causes problems with Firestore
          .limit(limit ?? 10000);
      // process snapshots
      await for (var snapshot in sessionQuery.snapshots()) {
        // clean session array for each snapshot
        sessions = [];
        for (var doc in snapshot.docs) {
          // create a Session object for each document
          Map<String, dynamic> json = doc.data();
          Session? session;
          try {
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
            // ensure duration and distance are double (might be saved as int on the database)
            json['duration'] = json['duration'].toDouble();
            json['distance'] = json['distance'].toDouble();
            session = Session.fromJson(json);
          } on Error {
            continue;
          }
          if (session != null) sessions.add(session);
        }
        yield sessions;
      }
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Stream<List<Goal>> getGoals(String uid, {required bool inProgressOnly}) async* {
    try {
      final userDocRef = _database.collection("users").doc(uid);
      var goalQuery = _database.collection("goals").where("owner", isEqualTo: userDocRef);
      if (inProgressOnly) {
        goalQuery = goalQuery.where("completed", isEqualTo: false);
      }
      goalQuery = goalQuery.orderBy("createdAt", descending: true);
      /*return docUser.snapshots();*/
      await for (QuerySnapshot<Map<String, dynamic>> snapshot in goalQuery.snapshots()) {
        List<Goal> goals = [];
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
          Map<String, dynamic> json = doc.data();
          Goal? goal;
          try {
            // ensure values are double
            json['currentValue'] = json['currentValue'].toDouble();
            json['targetValue'] = json['targetValue'].toDouble();
            json['id'] = doc.id;
            json['owner'] = null; // TODO: Maybe it is better to add the user
            json['createdAt'] = (json['createdAt'] as Timestamp).toDate();
            goal = Goal.fromJson(json);
          } on Error {
            continue;
          }
          if (goal != null) goals.add(goal);
        }
        yield goals;
      }
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Future<void> createGoal(String uid, Goal goal) async {
    try {
      final docUser = _database.collection('users').doc(uid);
      final data = {
        "completed": goal.completed,
        "currentValue": goal.currentValue,
        "targetValue": goal.targetValue,
        "type": goal.type,
        "createdAt": Timestamp.fromDate(goal.creationDate),
        "owner": docUser,
        // TODO: When writing Firestore rules, remember to check that this docUser.id is equal to the actual user
      };
      await _database.collection("goals").add(data);
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Future<void> deleteGoal(Goal goal) async {
    try {
      await _database.collection('goals').doc(goal.id).delete();
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  void createProposal({
    required DateTime dateTime,
    required String ownerId,
    required double placeLatitude,
    required double placeLongitude,
    required String placeId,
    required String placeName,
    String? placeCity,
    String? placeState,
    String? placeCountry,
    String? placeType,
    required String type,
  }) async {
    try {
      await _database.collection("proposals").add(
        {
          "dateTime": Timestamp.fromDate(dateTime),
          "owner": _database.collection('users').doc(ownerId),
          "place": {
            "coords": GeoPoint(placeLatitude, placeLongitude),
            "geohash": GeoHasher().encode(placeLatitude, placeLongitude, precision: 9),
            "id": placeId,
            "latitude": placeLatitude,
            "longitude": placeLongitude,
            "name": placeName,
            "city": placeCity,
            "state": placeState,
            "country": placeCountry,
            "type": placeType
          },
          "participants": [],
          "type": type,
        },
      );
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Stream<List<Proposal>> getProposalsByUser(String uid, {int? limit}) async* {
    List<Proposal> proposals = [];
    Query<Map<String, dynamic>> proposalQuery;
    try {
      final ownerRef = _database.collection("users").doc(uid);
      proposalQuery = _database
          .collection("proposals")
          .where("owner", isEqualTo: ownerRef)
          .orderBy("dateTime", descending: false)
      // limit query to parameter or to a very high number
      // number could be even higher, but then it causes problems with Firestore
          .limit(limit ?? 10000);
      // process snapshots
      await for (var snapshot in proposalQuery.snapshots()) {
        // clean session array for each snapshot
        proposals = [];
        for (var doc in snapshot.docs) {
          // create a Proposal object for each document
          Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: uid,excludeCurrentUser: false);
          if (proposal != null) proposals.add(proposal);
        }
        yield proposals;
      }
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }
  void addParticipantToProposal(Proposal proposal, String currentUserUid) async {
    try {
      await _database.collection('proposals').doc(proposal.id).update({
        'participants': FieldValue.arrayUnion([currentUserUid])
      });
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  void removeParticipantFromProposal(Proposal proposal, String currentUserUid) async {
    try {
      await _database.collection('proposals').doc(proposal.id).update({
        'participants': FieldValue.arrayRemove([currentUserUid])
      });
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  void deleteProposal(Proposal proposal) {
    try {
      _database.collection('proposals').doc(proposal.id).delete();
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
  }

  Future<List<Proposal?>> getProposalsByPlace(Place place, String uid, {DateTime? after}) async {
    try {
      List<Proposal?> list = [];
      var future = _database.collection("proposals").where('place.id', isEqualTo: place.id).get();
      await future.then((snapshot) async {
        for (var doc in snapshot.docs) {
          try {
            if (after != null && (doc.data()['dateTime'] as Timestamp).toDate().isBefore(after)) continue;
          } on Error {
            continue;
          }
          Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: uid);
          if (proposal != null) list.add(proposal);
        }
      });
      return list;
    } on FirebaseException catch (fe) {
      return Future.error(DatabaseException(fe.message));// DatabaseException(fe.message);
    }
  }

  Stream<List<Proposal>> getProposalsWithinInterval(String currentUserUid,
      {required DateTime after, required DateTime before}) async* {
    // sanity check on incoming parameters: "after" parameter must be before "before" parameter
    if (!after.isBefore(before)) throw ArgumentError("'after' parameter must precede 'before' parameter");
    // initialize lists
    List<Proposal> proposals = [];
    QuerySnapshot<Map<String, dynamic>> proposalsDocs; // Sessions proposed by others
    QuerySnapshot<Map<String, dynamic>> proposalsDocsOwned; // Sessions proposed by the user
    try {
      // get reference to current user document
      final currentUserRef = _database.collection("users").doc(currentUserUid);
      // obtain proposals from the server
      proposalsDocs = await _database
          .collection("proposals")
          .where("participants", arrayContains: currentUserUid)
          .where("dateTime", isLessThanOrEqualTo: before)
          .where("dateTime", isGreaterThanOrEqualTo: after) // TODO: Add filter for completed proposals
          .get();
      proposalsDocsOwned = await _database
          .collection("proposals")
          .where("owner", isEqualTo: currentUserRef)
          .where("dateTime", isLessThanOrEqualTo: before)
          .where("dateTime", isGreaterThanOrEqualTo: after) // TODO: Add filter for completed proposals
          .get();
    } on FirebaseException catch (fe) {
      throw DatabaseException(fe.message);
    }
    // convert data extracted from server into proposal objects
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = proposalsDocs.docs + proposalsDocsOwned.docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in allDocs) {
      Proposal? proposal = await _proposalFromFirestore(doc, currentUserUid: currentUserUid, excludeCurrentUser: false);
      if (proposal != null) proposals.add(proposal);
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
        var ownerData = snapshot.data() as Map<String, dynamic>;
        ownerData['uid'] = ownerRef.id;
        // check if current user is friend of proposal owner
        if (json['type'] == 'Friends' && ownerData['uid'] != currentUserUid) {
          if (!ownerData['friends'].contains(currentUserUid)) {
            return null;
          }
        }
        return ownerData;
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
      // List<DocumentReference> participants =
      //     (json['participants'] as List).map((item) => item as DocumentReference).toList();
      // json['participants'] = participants.map((item) => item.id).toList();
      return Proposal.fromJson(json);
    } on Error {
      return null;
    }
  }
}
