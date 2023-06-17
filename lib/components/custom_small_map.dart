import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../constants.dart';
import '../model/proposal.dart';

class CustomSmallMap extends StatelessWidget {
  final MapOptions options;
  final List<Widget> children;
  final List<Proposal> proposalsForMarkers;
  final MapController? mapController;

  const CustomSmallMap(
      {super.key,
      required this.options,
      this.mapController,
      this.children = const [],
      this.proposalsForMarkers = const []});

  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.shortestSide / 30;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.all(
          Radius.circular(padding),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(padding)),
        child: FlutterMap(
          key: const Key('CustomSmallMapFlutterMap'),
          mapController: mapController,
          options: options,
          children: List.from([
            TileLayer(
              key: const Key('CustomSmallMapTileLayer'),
              urlTemplate: mapUrl,
              subdomains: const ['a', 'b', 'c'],
            ),
            if (proposalsForMarkers.isNotEmpty)
            MarkerLayer(
              key: const Key('CustomSmallMapMarkerLayer'),
              markers: proposalsForMarkers.map((proposal) {
                return _markerFromProposal(proposal);
              }).toList(),
            ),
          ])
            ..addAll(children),
        ),
      ),
    );
  }

  Marker _markerFromProposal(Proposal proposal) {
    return Marker(
      key: Key('MarkerFromProposal_${proposal.id}'),
      point: proposal.place.coords,
      builder: (ctx) => Icon(
        key: Key('MarkerFromProposal_${proposal.id}_Icon'),
        Icons.place,
        color:
            proposal.type == 'Public' ? Colors.green : Colors.yellow.shade600,
        size: 30,
      ),
    );
  }
}
