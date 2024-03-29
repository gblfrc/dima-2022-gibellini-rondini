import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/location_handler.dart';
import 'package:progetto/app_logic/search_engine.dart';

import '../app_logic/storage.dart';
import '../components/custom_small_map.dart';
import '../components/search_bar.dart';
import '../components/tiles.dart';
import '../model/place.dart';
import '../model/proposal.dart';
import '../model/user.dart';

class SearchPage extends StatefulWidget {
  final Database database;
  final Auth auth;
  final Storage storage;
  final SearchEngine searchEngine;
  final LocationHandler locationHandler;

  const SearchPage({super.key, required this.database, required this.auth, required this.storage, required this.searchEngine, required this.locationHandler});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<User> userList = List.empty();
  List<Place> placeList = List.empty();
  List<Proposal> proposalList = List.empty();
  LatLng? _initialPosition;
  final MapController _mapController = MapController();

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
            tabs: [Tab(text: 'Users'), Tab(key: Key('PlaceTab'), text: 'Places'), Tab(key: Key('MapTab'), text: 'Map')],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, padding),
                          child: SearchBar(
                            key: const Key('UserSearchBar'),
                            onChanged: _updateUserList,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return UserTile.fromUser(userList[index], context, widget.storage, widget.database, widget.auth);
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: userList.length,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, padding),
                          child: SearchBar(
                            // Place searchbar
                            key: const Key('PlaceSearchBar'),
                            onChanged: _updatePlaceList,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return PlaceTile.fromPlace(
                            place: placeList[index], context: context, auth: widget.auth, database: widget.database, storage: widget.storage);
                      },
                      separatorBuilder: (context, index) {
                        // return const SizedBox(height: 10,);
                        return const SizedBox(
                          height: 0,
                        );
                      },
                      itemCount: placeList.length,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Flexible(
                    flex: 2,
                    child: FutureBuilder(
                        future: widget.locationHandler.getCurrentPosition(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Position position = snapshot.data!;
                            _initialPosition = LatLng(position.latitude, position.longitude);
                            return CustomSmallMap(
                              mapController: _mapController,
                              options: MapOptions(
                                center: _initialPosition,
                                zoom: 15,
                                maxZoom: 18.4,
                                onMapEvent: (e) {
                                  if (e is MapEventDoubleTapZoomEnd ||
                                      e is MapEventFlingAnimationEnd ||
                                      e is MapEventMoveEnd ||
                                      e is MapEventRotateEnd) {
                                    _updateProposalList(_mapController.bounds!, widget.auth.currentUser!.uid);
                                  }
                                },
                              ),
                              proposalsForMarkers: proposalList,
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Something went wrong. Please try again later.",
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  ),
                  Flexible(
                    flex: 3,
                    child: ListView(
                      children: proposalList
                          .map((proposal) => ProposalTile.fromProposal(
                                proposal,
                                context,
                                auth: widget.auth,
                                database: widget.database,
                                storage: widget.storage,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
  * Function to update list of users shown in user search tab
  */
  void _updateUserList(String name) async {
    // get uid of currently logged user
    String? uid = widget.auth.currentUser?.uid;
    // get all users except the logged one
    List<User> newList = await widget.searchEngine.getUsersByName(name, excludeUid: uid!);
    // call setState to update widget
    setState(() {
      userList = newList;
    });
  }

  /*
  * Function to update list of places shown in place search tab
  */
  void _updatePlaceList(String name) async {
    // get all places given place name
    List<Place> newList = await widget.searchEngine.getPlacesByName(name);
    // call setState to update widget
    setState(() {
      placeList = newList;
    });
  }

  /*
  * Function to update list of places shown in place search tab
  */
  void _updateProposalList(LatLngBounds bounds, String uid) async {
    // get all proposals for logged user within boundaries of the map
    List<Proposal> newList = await widget.database.getProposalsWithinBounds(bounds, uid, after: DateTime.now());
    // call setState to update widget
    setState(() {
      proposalList = newList;
    });
  }

  /*Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position> _initPosition(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return Future.error(Exception('Missing permissions'));
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }*/
}
