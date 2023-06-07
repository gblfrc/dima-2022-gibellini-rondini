import 'package:latlong2/latlong.dart';

import 'user.dart';

class Session {
  String id;
  double distance;
  double duration;
  List<List<LatLng>> positions;
  DateTime start;
  User? owner;

  // constructor; throws exception if 'positions' array is empty or contains
  // no positions.
  Session(
      {required this.id,
      required this.distance,
      required this.duration,
      required this.positions,
      required this.start,
      this.owner});

  /*
  * Function to create a Session object from a json map
  * Required json structure: {
  *   String id,
  *   double distance,
  *   double duration,
  *   List<List<LatLng>> positions,
  *   DateTime start,
  *   User? owner
  * }
  * Function returns a null element if a Session object couldn't be created.
  * */
  static fromJson(Map<String, dynamic> json) {
    try {
      return Session(
        id: json['id'],
        distance: json['distance'],
        duration: json['duration'],
        positions: json['positions'],
        start: json['start'],
        owner: json['owner'],
      );
    } on Error {
      // if the list of positions doesn't include at least one position, an error
      // is thrown because no List<List<LatLng>> can be inferred
      return null;
    }
  }
}
