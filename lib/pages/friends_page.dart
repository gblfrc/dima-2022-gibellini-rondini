import 'package:flutter/material.dart';

import '../app_logic/database.dart';
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
                    future: Database().getFriendProposals(),
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
                        } else {
                          List<Widget> trainings = [];
                          for (var proposal in snapshot.data!) {
                            trainings.add(
                              TrainingProposalCard(proposal: proposal!),
                            );
                          }
                          return Column(
                            children: trainings,
                          );
                        }
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
                      future: Database.getFriends(),
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
                          List<User> friends = snapshot.data!;
                          return Column(
                              children: friends
                                  .map((friend) =>
                                      UserTile.fromUser(friend, context))
                                  .toList());
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
