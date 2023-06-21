import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/components/tiles.dart';

import '../app_logic/database.dart';
import '../model/place.dart';
import '../model/proposal.dart';

class PlacePage extends StatelessWidget {
  final Place place;
  final Auth auth;
  final Database database;

  const PlacePage({
    super.key,
    required this.place,
    required this.auth,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    Axis direction = MediaQuery.of(context).orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical;
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 20),
        child: Flex(
          direction: direction,
          children: [
            Flexible(
              key: const Key('MapSection'),
              flex: (isTablet || direction == Axis.horizontal) ? 5 : 3,
              child: CustomSmallMap(
                key: const Key('PlacePageMap'),
                mapController: MapController(),
                options: MapOptions(
                  center: place.coords,
                  zoom: 15,
                  maxZoom: 18.4,
                ),
                children: [
                  MarkerLayer(
                    markers: [
                      Marker(
                        key: const Key('PlacePageMarker'),
                        point: place.coords,
                        builder: (context) => const Icon(
                          Icons.place,
                          size: 30,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Flexible(
              key: const Key('NonMapSection'),
              flex: ((isTablet && direction == Axis.horizontal) || (!isTablet && direction != Axis.horizontal)) ? 5 : 6,
              child: LayoutBuilder(
                builder: (context, constraint) {
                  return FutureBuilder(
                    future: database.getProposalsByPlace(place, auth.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Padding(
                              padding: EdgeInsets.all(constraint.maxWidth / 20),
                              child: Text(
                                key: const Key('PlacePageNoAvailableProposalText'),
                                'There are no proposals for the requested location',
                                style: TextStyle(fontSize: MediaQuery.of(context).textScaleFactor * 18),
                              ));
                        } else {
                          List<ProposalTile> tiles = [];
                          for (int i = 0; i < snapshot.data!.length; i++) {
                            Proposal? current = snapshot.data![i];
                            tiles.add(
                              ProposalTile.fromProposal(current!, context, key: Key('PlacePageProposalTile_$i')),
                            );
                          }
                          return ListView(
                            key: const Key('PlacePageProposalList'),
                            children: tiles,
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Padding(
                            padding: EdgeInsets.all(constraint.maxWidth / 20),
                            child: Text(
                              key: const Key('PlacePageErrorInFetchingProposalText'),
                              'An error occurred when fetching proposals. Retry later.',
                              style: TextStyle(fontSize: MediaQuery.of(context).textScaleFactor * 18),
                            ));
                      } else {
                        return const Center(
                          key: Key('PlacePageProposalCircularProgressIndicator'),
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
