import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_logic/auth.dart';
import '../components/tiles.dart';
import '../components/cards.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                FutureBuilder(
                    future: getProposals(),
                    builder: (context, snapshot) {
                      // TODO: Add case to handle error snapshot.hasError
                      if (snapshot.hasData) {
                        // This returns true even if there are no documents in the list
                        if (snapshot.data!.isEmpty) {
                          // If there are no sessions, we print a message
                          return const Text(
                            "There are no proposals made by people that have added you to their friends.",
                            textAlign: TextAlign.center,
                          );
                        }
                        List<Widget> sessionList = [];
                        for (var proposal in snapshot.data!) {
                          // For each session, we create a card and append it to the array of children
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
                children: <Widget>[
                  const Padding(padding: EdgeInsets.all(10)),
                  Tile(
                      icon: Icons.account_circle,
                      title: "Luca Rondini",
                      subtitle: "",
                      callback: print),
                  Tile(
                      icon: Icons.account_circle,
                      title: "Federico Gibellini",
                      subtitle: "",
                      callback: print),
                  const Center(
                      child: Text(
                          "Use the Search section to find friends to add."))
                ],
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
    final friendOfList = FirebaseFirestore.instance.collection("users").where("friends", arrayContains: userDocRef);
    final friendOfSnapshot = await friendOfList.get();
    final friendOfDocs = friendOfSnapshot.docs;
    List<DocumentReference> friendOfDocRefs = [];
    for(var friendDoc in friendOfDocs) {
      friendOfDocRefs.add(friendDoc.reference);
    }

    // Get the proposals made by all the people returned by the previous query that are not expired
    final docProposals = FirebaseFirestore.instance
        .collection("proposals")
        .where("owner", whereIn: friendOfDocRefs)
        .where("dateTime", isGreaterThanOrEqualTo: Timestamp.now());
    final querySnapshot = await docProposals.get(); // This get returns QuerySnapshot
    return querySnapshot.docs; // Return the list of DocumentSnapshot
  }
}
