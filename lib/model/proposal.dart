import 'package:progetto/model/place.dart';
import 'user.dart';

class Proposal {
  String? id;
  DateTime dateTime;
  User owner;
  Place place;
  String type;

  Proposal(
      {this.id,
      required this.dateTime,
      required this.owner,
      required this.place,
      required this.type});


  /*
  * Function to create a Proposal object from a json map
  * Required json structure: {
  *   String id,
  *   String dateTime,
  *   // json to obtain a user model object,
  *   // json to obtain a place model object,
  *   String type
  * }
  * */
  static fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['pid'],
      dateTime: DateTime.parse(json['dateTime']),
      owner: User.fromJson(json['owner']),
      place: Place.fromJson(json['place']),
      type: json['type'],
    );
  }
}
