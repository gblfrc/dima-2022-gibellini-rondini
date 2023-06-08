import 'package:progetto/model/place.dart';
import 'user.dart';

class Proposal {
  String? id;
  DateTime dateTime;
  User owner;
  Place place;
  String type;
  List<String?> participants;

  Proposal(
      {this.id,
      required this.dateTime,
      required this.owner,
      required this.place,
      required this.type,
      required this.participants}) {
    if (type != 'Public' && type != 'Friends') {
      throw ArgumentError('Illegal proposal type');
    }
  }

  /*
  * Function to create a Proposal object from a json map
  * Required json structure: {
  *   String id,
  *   String dateTime,
  *   // json to obtain a user model object,
  *   // json to obtain a place model object,
  *   List<String> participants (can be empty),
  *   String type
  * }
  * */
  static fromJson(Map<String, dynamic> json) {
    // create participants list
    // an empty list is a list of dynamic and cannot be converted to list of String
    // convert list of dynamic to list of String
    try {
      List<String>? participants =
          (json['participants'] as List).map((item) => item as String).toList();
      // create proposal object
      return Proposal(
        id: json['pid'],
        dateTime: DateTime.parse(json['dateTime']),
        owner: User.fromJson(json['owner']),
        place: Place.fromJson(json['place']),
        participants: participants,
        type: json['type'],
      );
    } on Error {
      return null;
    }
  }
}
