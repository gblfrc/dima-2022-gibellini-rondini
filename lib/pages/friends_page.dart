import 'package:flutter/material.dart';

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
                TrainingProposalCard(
                    "Parco Suardi", "Shared", "2023-03-21T15:30:00Z"),
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
}
