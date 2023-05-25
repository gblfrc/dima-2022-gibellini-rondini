import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/model/session.dart';

class SessionMap extends StatelessWidget {
  final Session session;
  late bool? useMarkers;
  final int? interactiveFlags;

  SessionMap(
      {super.key,
      required this.session,
      this.useMarkers,
      this.interactiveFlags});

  @override
  Widget build(BuildContext context) {
    useMarkers = useMarkers ?? true;
    return FlutterMap(
      options: MapOptions(
          maxZoom: 18.4,
          bounds: getBoundCorner(session.positions),
          interactiveFlags: interactiveFlags ?? InteractiveFlag.all),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        PolylineLayer(
          polylineCulling: true,
          polylines: [
            for (List<LatLng> posArray in session.positions)
              Polyline(
                points: posArray,
                color: Theme.of(context).primaryColor,
                strokeWidth: 7,
              )
          ],
        ),
        MarkerLayer(
          markers: useMarkers!
              ? [
                  Marker(
                    point: session.positions.first.first,
                    // First point of the first segment
                    builder: (ctx) => Icon(
                      Icons.assistant_direction,
                      color: Theme.of(context).primaryColor,
                      shadows: const [
                        Shadow(color: Colors.white, blurRadius: 30)
                      ],
                      size: 30,
                    ),
                  ),
                  Marker(
                    point: session.positions.last.last, // Final destination
                    builder: (ctx) => Icon(
                      Icons.flag_circle_rounded,
                      color: Theme.of(context).primaryColor,
                      shadows: const [
                        Shadow(color: Colors.white, blurRadius: 30)
                      ],
                      size: 30,
                    ),
                  ),
                ]
              : [],
        ),
      ],
    );
  }

  LatLngBounds getBoundCorner(List<List<LatLng>> segments) {
    List<LatLng> positions = segments
        .expand((element) =>
            element) // The list of lists is flattened into a single list
        .toList();
    List<double> latitudes = [];
    List<double> longitudes = [];
    for (LatLng p in positions) {
      latitudes.add(p.latitude);
      longitudes.add(p.longitude);
    }
    double south = latitudes.reduce(min);
    double north = latitudes.reduce(max);
    double east = longitudes.reduce(max);
    double west = longitudes.reduce(min);
    double deltaLatitude = north - south;
    double deltaLongitude = west - east;
    double safeAreaFactor = 1 / 4;

    LatLng corner1 = LatLng(north + safeAreaFactor * deltaLatitude,
        west - safeAreaFactor * deltaLongitude);
    LatLng corner2 = LatLng(south - safeAreaFactor * deltaLatitude,
        east + safeAreaFactor * deltaLongitude);
    return LatLngBounds(corner1, corner2);
  }
}
