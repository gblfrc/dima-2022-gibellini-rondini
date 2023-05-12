import 'package:latlong2/latlong.dart';

class Place {
  String id;
  String name;
  String? city;
  String? state;
  String? country;
  LatLng? coords;

  Place({required this.id, required this.name, this.city, this.state, this.country, this.coords});

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
  * }
  * */
  static Place fromJson(Map<String, dynamic> json) => Place(
        id: json['id'],
        // name: json['display_place'] ?? json['display_name'],
        name: json['name'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        coords: LatLng((json['lat']), (json['lon'])),
      );
}