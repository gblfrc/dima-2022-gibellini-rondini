import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class SessionInfoPage extends StatelessWidget {
  DocumentSnapshot sessionData;

  SessionInfoPage(this.sessionData, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = sessionData["startDT"].toDate().toLocal();
    List<LatLng> positions = [];
    for(GeoPoint p in sessionData["positions"]) {
      positions.add(LatLng(p.latitude, p.longitude));
    }
    //String formattedDate =
    //"${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    String formattedDate = DateFormat("d MMM y").add_Hms().format(dateTime);
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
                center: positions.first,
                //zoom: 18,
                maxZoom: 18.4,
                bounds: getBoundCorner(positions),
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
                    Polyline(
                      points: positions,
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
                      point: positions.first,
                      builder: (ctx) => const Icon(
                        Icons.circle,
                        color: Colors.blue,
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
                          "${sessionData["duration"] ~/ 60}:${sessionData["duration"] % 60}",
                          // TODO: Maybe is better to also add seconds?
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
                          "${sessionData["distance"]} km",
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

  LatLngBounds getBoundCorner(List<LatLng> positions) { // TODO: Add a safe area when calculating the boundaries
    List<double> latitudes = [];
    List<double> longitudes = [];
    for(LatLng p in positions) {
      latitudes.add(p.latitude);
      longitudes.add(p.longitude);
    }
    LatLng corner1 = LatLng(latitudes.reduce(max), longitudes.reduce(max));
    LatLng corner2 = LatLng(latitudes.reduce(min), longitudes.reduce(min));
    return LatLngBounds(corner1, corner2);
  }
}
