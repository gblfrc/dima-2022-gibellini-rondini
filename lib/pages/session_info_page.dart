import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../model/session.dart';

class SessionInfoPage extends StatelessWidget {
  Session session;

  SessionInfoPage(this.session, {super.key});

  @override
  Widget build(BuildContext context) {
    // List<List<LatLng>> segments = [];
    // for (Map<String, dynamic> m in sessionData["positions"]) {
    //   List<LatLng> points = [];
    //   for (GeoPoint p in m["values"] ?? []) {
    //     points.add(LatLng(p.latitude, p.longitude));
    //   }
    //   segments.add(points);
    // }
    //String formattedDate =
    //"${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    String formattedDate = DateFormat("d MMM y").add_Hms().format(session.start);
    String formattedDuration = "${session.duration ~/ (60 * 60)}";
    formattedDuration +=
        ":${(session.duration ~/ 60).toString().padLeft(2, "0")}";
    formattedDuration +=
        ":${(session.duration % 60).toStringAsFixed(0).padLeft(2, "0")}";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session info"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: FlutterMap(
              options: MapOptions(
                //center: segments.first.first,
                //zoom: 18,
                maxZoom: 18.4,
                bounds: getBoundCorner(session.positions),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylineCulling: true,
                  polylines: [
                    for (List<LatLng> posArray in session.positions)
                      Polyline(
                        points: posArray,
                        color: Colors.blue,
                        strokeWidth: 7,
                      )
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      // width: 50.0,
                      // height: 50.0,
                      point: session.positions.first.first, // First point of the first segment
                      builder: (ctx) => Icon(
                        Icons.assistant_direction,
                        color: Theme.of(context).primaryColor,
                        shadows: const [Shadow(color:Colors.white, blurRadius: 30)],
                        size: 30,
                      ),
                    ),
                    Marker(
                      // width: 50.0,
                      // height: 50.0,
                      //
                      point: session.positions.last.last, // Final destination
                      builder: (ctx) => Icon(
                        Icons.flag_circle_rounded,
                        color: Theme.of(context).primaryColor,
                        shadows: const [Shadow(color:Colors.white, blurRadius: 30)],
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 40,
                  runSpacing: 20,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Start"),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          formattedDuration,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Duration"),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "${(session.distance / 1000).toStringAsFixed(2)} km",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Distance"),
                      ],
                    ),
                  ],
                ),
                /*child: Column(
                  children: [
                    //const FractionallySizedBox(widthFactor: 1),
                    ListTile(
                      minLeadingWidth: 0,
                      horizontalTitleGap: 5,
                      leading: SizedBox(
                        width: 30,
                        child: Center(
                          child: Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      title: Text("1 h 40 min"),
                      subtitle: Text("Duration"),
                    ),
                  ],
                ), */
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLngBounds getBoundCorner(List<List<LatLng>> segments) {
    // TODO: Add a safe area when calculating the boundaries
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
    LatLng corner1 = LatLng(latitudes.reduce(max), longitudes.reduce(max));
    LatLng corner2 = LatLng(latitudes.reduce(min), longitudes.reduce(min));
    return LatLngBounds(corner1, corner2);
  }
}
