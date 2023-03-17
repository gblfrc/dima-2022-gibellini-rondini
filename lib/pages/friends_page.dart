import 'package:flutter/material.dart';

import '../components/tiles.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Friends"),
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
                Card(
                  child: InkWell(
                    onTap: () => print("Card tap"),
                    child: Column(
                      children: [
                        const FractionallySizedBox(widthFactor: 1),
                        const ListTile(
                          title: Text("Proposed session at Parco Suardi"),
                          subtitle: Text("Shared with friends"),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text("Mar 21, 2023 16:30"),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () => print("Pressed"),
                                child: Text("Join training"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: ListView(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(10)),
                  Tile(Icons.account_circle, "Luca Rondini", "", print("User1")),
                  Tile(Icons.account_circle, "Federico Gibellini", "", print("User2")),
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