import 'package:latlong2/latlong.dart';

import 'user.dart';

class Session {
  String id;
  double distance;
  double duration;
  List<List<LatLng>> positions;
  DateTime start;
  User? owner;

  Session(
      {required this.id,
      required this.distance,
      required this.duration,
      required this.positions,
      required this.start,
      this.owner});

  static fromJson(Map<String, dynamic> json) => Session(
        id: json['id'],
        distance: json['distance'],
        duration: json['duration'],
        positions: json['positions'],
        start: json['start'],
        owner: json['owner'],
      );
}
