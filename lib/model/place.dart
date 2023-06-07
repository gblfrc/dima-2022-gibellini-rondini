import 'package:latlong2/latlong.dart';

class Place {
  String id;
  String name;
  String? city;
  String? state;
  String? country;
  LatLng coords;
  String? type;

  Place(
      {required this.id,
      required this.name,
      this.city,
      this.state,
      this.country,
      required this.coords,
      this.type});

  /*
  * Function to create a User object from a json map
  * Required json structure: {
  *   String id,
  *   String name,
  *   String? city,
  *   String? state,
  *   String? country
  *   double lat,
  *   double lon
  *   String? type
  * }
  * */
  static Place fromJson(Map<String, dynamic> json) => Place(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      coords: LatLng(json['lat'].toDouble(), json['lon'].toDouble()), // cast to double if numbers passed are integers
      type: json['type']);
}
