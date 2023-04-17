import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_logic/auth.dart';
import '../components/tiles.dart';
import '../components/cards.dart';
import '../model/user.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).size.width / 40;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Friends"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Trainings"),
              Tab(text: "Friend list"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                Padding(padding: EdgeInsets.all(padding)),
                FutureBuilder(
                    future: getProposals(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          "Something went wrong. Please try again later.",
                          textAlign: TextAlign.center,
                        );
                      }
                      if (snapshot.hasData) {
                        // This returns true even if there are no documents in the list
                        if (snapshot.data!.isEmpty) {
                          return const Text(
                            "There are no proposals made by people that have added you to their friends.",
                            textAlign: TextAlign.center,
                          );
                        }
                        List<Widget> sessionList = [];
                        for (var proposal in snapshot.data!) {
                          sessionList.add(TrainingProposalCard(proposal));
                        }
                        return Column(
                          children: sessionList,
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
                //TrainingProposalCard("Parco Suardi", "Shared", "2023-03-21T15:30:00Z"),
              ],
            ),
            Center(
              child: ListView(
                children: [
                  Padding(padding: EdgeInsets.all(padding)),
                  FutureBuilder(
                      future: getFriends(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            "Something went wrong. Please try again later.",
                            textAlign: TextAlign.center,
                          );
                        }
                        if (snapshot.hasData) {
                          // This returns true even if there are no documents in the list
                          if (snapshot.data!.isEmpty) {
                            return const Text(
                              "You haven't added any friends yet.",
                              textAlign: TextAlign.center,
                            );
                          }
                          List<Widget> friendList = [];
                          for (var friend in snapshot.data!) {
                            friendList.add(UserTile.fromUser(User(
                                name: friend.get("name"),
                                surname: friend.get("surname"))));
                          }
                          return Column(
                            children: friendList,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  const Text(
                    "Use the Search section to find friends to add.",
                    textAlign: TextAlign.center,
                  ),
                ],
                // children: <Widget>[
                //   const Padding(padding: EdgeInsets.all(10)),
                //   Tile(
                //       icon: Icons.account_circle,
                //       title: "Luca Rondini",
                //       subtitle: "",
                //       callback: print),
                //   Tile(
                //       icon: Icons.account_circle,
                //       title: "Federico Gibellini",
                //       subtitle: "",
                //       callback: print),
                // ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getProposals() async {
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
            whereIn: friendOfDocRefs) // TODO: Split friendOfDocRefs if the length is > 10 because of whereIn limit
        .where("dateTime", isGreaterThanOrEqualTo: Timestamp.now());
    final querySnapshot = await docProposals.get(); // This get returns QuerySnapshot
    return querySnapshot.docs; // Return the list of DocumentSnapshot
  }

  Future<List<DocumentSnapshot>> getFriends() async {
    final userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(Auth().currentUser?.uid);

    final userSnapshot = await userDocRef.get();
    final friendRefs = userSnapshot.get("friends");
    List<DocumentSnapshot> friendDocs = [];
    for (var friend in friendRefs) {
      friendDocs.add(await friend.get());
    }
    return friendDocs; // Return the list of DocumentSnapshot
  }
}
