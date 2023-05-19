import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:progetto/components/cards.dart';

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
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: (MediaQuery.of(context).size.width / 20),
                horizontal: (MediaQuery.of(context).size.width / 20),
              ),
              child: FlutterMap(
                // mapController: _mapController,
                options: MapOptions(
                  center: place.coords,
                  zoom: 15,
                  maxZoom: 18.4,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: place.coords,
                        builder: (ctx) => Icon(
                          Icons.place,
                          color: Colors.red.shade600,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: (MediaQuery.of(context).size.width / 20),
                horizontal: (MediaQuery.of(context).size.width / 20),
              ),
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
                      List<TrainingProposalCard> cards = [];
                      for (int i = 0; i < snapshot.data!.length; i++) {
                        Proposal? current = snapshot.data![i];
                        cards.add(
                          TrainingProposalCard(
                            proposal: current!,
                          ),
                        );
                      }
                      return ListView(
                        children: cards,
                      );
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
