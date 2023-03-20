import 'package:flutter/material.dart';

import '../components/tiles.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});


  // TODO: search bar --> make more intelligent, showing suggestions...
  // TODO:            --> fix, do not let it move with the tabs

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Search'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Users'),
                  Tab(text: 'Places'),
                  Tab(text: 'Map')
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ListView( // TODO: make this column a reusable element
                  children: [
                    Center(
                        child: Container(
                            color: const Color(0xffd6d6d6),
                            width: 380, //TODO: make relative
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              //TODO: make beautiful
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.search),
                                Text('Search'),
                                Icon(Icons.close),
                              ],
                            ))),
                    const Padding(padding: EdgeInsets.all(10)),
                    Tile(Icons.account_circle, "Antonio", "ciao", print("Ok")),
                    // TODO: find a finer way to implement the list without dividers, maybe with space between objects
                    Tile(Icons.account_circle, "Roberto", "ciao2", print("Ok2")),
                  ],
                ),
                Column(
                  children: [
                    Center(
                        child: Container(
                            color: const Color(0xffd6d6d6),
                            width: 380, //TODO: make relative
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              //TODO: make beautiful
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.search),
                                Text('Search'),
                                Icon(Icons.close),
                              ],
                            ))),
                    const Padding(padding: EdgeInsets.all(10)),
                    Tile(Icons.place, "A place", "", print("Place1")),
                    // TODO: find a finer way to implement the list without dividers, maybe with space between objects
                    Tile(Icons.place, "Another place", "", print("Place2")),
                  ],
                ),
                Column(
                  children: [
                    Center(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                          padding: const EdgeInsets.all(110),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: const Text('THIS IS NOT A MAP'),
                        )
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    ListTile(
                      leading: const Icon(Icons.place, size: 60),
                      title: const Text("A training"),
                      trailing: const Text('2 km'),
                      onTap: () => print("Ciao"),
                    ),
                    const Divider(),
                    // TODO: find a finer way to implement the list without dividers, maybe with space between objects
                    ListTile(
                      leading: const Icon(Icons.place, size: 60),
                      title: const Text("Another training"),
                      trailing: const Text('5 km'),
                      onTap: () => print("Ciaone"),
                    ),
                    const Divider(),
                  ],
                )
              ],
            )
        )
    );
  }
}