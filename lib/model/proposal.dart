import 'package:progetto/model/place.dart';

class Proposal {
  String id;
  String ownerId;
  Place place;
  String? type;

  Proposal(
      {required this.id,
      required this.ownerId,
      required this.place,
      this.type});

  static fromJson(Map<String, dynamic> json, String id) {
    json['place']['display_name'] = json['place']['name'];
    json['place']['lat'] = json['place']['coords'].latitude;
    json['place']['lon'] = json['place']['coords'].longitude;
    json['place']['osm_id'] = json['place']['id'].longitude;
    return Proposal(
      id: id,
      ownerId: json['owner'],
      place: Place.fromJson(json['place']),
      type: json['type'],
    );
  }
}
