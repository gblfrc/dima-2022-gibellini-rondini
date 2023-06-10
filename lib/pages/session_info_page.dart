import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../components/session_map.dart';
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
    String formattedDate = DateFormat("d MMM y").add_Hm().format(session.start);
    String time = "";
    Duration duration = Duration(seconds: session.duration.round());
    String hours = duration.inHours.toString();
    String minutes =
    duration.inMinutes.remainder(60).toString().padLeft(2, "0");
    String seconds =
    duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    if (session.duration < Duration.secondsPerHour) {
      time = "$minutes:$seconds";
    } else {
      time = "$hours:$minutes:$seconds";
    }
    String length = "";
    if (session.distance < 1000) {
      length = "${session.distance.round()} m";
    } else {
      length = "${(session.distance / 1000).toStringAsFixed(2)} km";
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session info"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: SessionMap(session: session),
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
                          time,
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
                          length,
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
