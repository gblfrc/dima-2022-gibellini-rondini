import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/components/tiles.dart';

import '../app_logic/database.dart';
import '../model/place.dart';
import '../model/proposal.dart';

class PlacePage extends StatelessWidget {
  final Place place;

  const PlacePage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 20),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
              flex: 3,
              child: CustomSmallMap(
                // mapController: _mapController,
                options: MapOptions(
                  center: place.coords,
                  zoom: 15,
                  maxZoom: 18.4,
                ),
                children: [
                  MarkerLayer(
                    markers: [
                      Marker(
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
              flex: 5,
              child: FutureBuilder(
                future: Database.getProposalsByPlace(place),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                      ),
                      child: const Text('An error occurred'),
                    );
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Text(
                          'There are no proposals for the requested location');
                    } else {
                      List<ProposalTile> tiles = [];
                      for (int i = 0; i < snapshot.data!.length; i++) {
                        Proposal? current = snapshot.data![i];
                        tiles.add(
                          ProposalTile.fromProposal(current!, context),
                        );
                      }
                      return ListView(
                        children: tiles,
                      );
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
