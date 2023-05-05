import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:progetto/components/cards.dart';

import '../model/place.dart';

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
                        point: place.coords!,
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
                future: getProposalsByPlace(place.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                      ),
                      child: const Text('An error occurred'),
                    );
                  } else if (snapshot.hasData) {
                    return ListView(
                      children: snapshot.data!,
                    );
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

  Future<List<TrainingProposalCard>?> getProposalsByPlace(String pid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .where('place.id', isEqualTo: pid)
        .get();
    return snapshot.docs.map((doc) => TrainingProposalCard(doc)).toList();
  }
}
