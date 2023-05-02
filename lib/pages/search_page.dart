import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/location_iq.dart';

import '../app_logic/algolia_app.dart';
import '../components/search_bar.dart';
import '../components/tiles.dart';
import '../model/place.dart';
import '../model/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<User> userList = List.empty();
  List<Place> placeList = List.empty();

  // TODO: introduce function to de-select search bar

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).size.width / 20;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Users'), Tab(text: 'Places'), Tab(text: 'Map')],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
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
                          padding: EdgeInsets.fromLTRB(0, 0, 0, padding),
                          child: SearchBar(
                            onChanged: _updateUserList,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: userList
                          .map((user) => UserTile.fromUser(user))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
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
                          padding: EdgeInsets.fromLTRB(0, 0, 0, padding),
                          child: SearchBar(
                            // Place searchbar
                            onChanged: _updatePlaceList,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: placeList
                          .map((place) => Tile(
                                icon: Icons.place,
                                title: place.name,
                                subtitle: "${place.city}, ${place.state}, ${place.country}",
                                callback: print,
                              ))
                          .toList(),
                      // TODO: find a finer way to implement the list without dividers, maybe with space between object
                    ),
                  ),
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
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                const ListTile(
                  leading: Icon(Icons.place, size: 60),
                  title: Text("A training"),
                  trailing: Text('2 km'),
                  onTap: null,
                ),
                const Divider(),
                // TODO: find a finer way to implement the list without dividers, maybe with space between objects
                const ListTile(
                  leading: Icon(Icons.place, size: 60),
                  title: Text("Another training"),
                  trailing: Text('5 km'),
                  onTap: null,
                ),
                const Divider(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateUserList(String name) async {
    String? uid = Auth().currentUser?.uid;
    List<User> newList = List.empty();
    if (name != "") {
      AlgoliaQuerySnapshot snapshot = await AlgoliaApp.algolia.instance
          .index('users')
          .filters('NOT objectID:$uid') // excludes active user from results
          .query(name)
          .getObjects();
      newList =
          snapshot.hits.map((object) => User.fromJson(object.toMap())).toList();
    }
    setState(() {
      userList = newList;
    });
  }

  void _updatePlaceList(String name) async {
    List<Place> newList = [];
    var places = await LocationIq.get(name);
    for (Map<String, dynamic> m in places) {
      newList.add(Place.fromJson(m));
    }
    setState(() {
      placeList = newList;
    });
  }
}
