import 'package:latlong2/latlong.dart';

class Place {
  String id;
  String name;
  String? city;
  String? state;
  String? country;
  LatLng? coords;

  Place({required this.id, required this.name, this.city, this.state, this.country, this.coords});

  static Place fromJson(Map<String, dynamic> json) => Place(
        id: json['osm_id'],
        name: json['display_place'] ?? json['display_name'],
        city: json['address']['city'],
        state: json['address']['state'],
        country: json['address']['country'],
        coords: LatLng(double.parse(json['lat']), double.parse(json['lon'])),
      );
}