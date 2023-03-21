import 'package:flutter/material.dart';

import '../components/search_bar.dart';
import '../components/tiles.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  // TODO: search bar --> make more intelligent, showing suggestions...
  // TODO:            --> fix, do not let it move with the tabs
  // TODO: introduce function to de-select search bar

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery
        .of(context)
        .size
        .width / 20;

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
                Padding(padding: EdgeInsets.all(padding),
                  child: Column(
                    // TODO: make this column a reusable element
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0,0,0,padding),
                              child: const SearchBar(),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Tile(Icons.account_circle, "Antonio", "ciao",
                                print),
                            // TODO: find a finer way to implement the list without dividers, maybe with space between objects
                            Tile(Icons.account_circle, "Roberto", "ciao2",
                                print),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(padding),
                  child: Column(
                    // TODO: make this column a reusable element
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0,0,0,padding),
                              child: const SearchBar(),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Tile(Icons.place, "A place", "", print),
                            // TODO: find a finer way to implement the list without dividers, maybe with space between objects
                            Tile(Icons.place, "Another place", "", print),
                          ],
                        ),
                      )
                    ],
                  ),
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
                        )),
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
            )));
  }
}
