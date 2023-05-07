import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:http/http.dart' as http;

import '../model/place.dart';
import '../model/user.dart';

class SearchEngine {
  static const Algolia _algolia = Algolia.init(
    applicationId: "U8ISIP6A8A",
    apiKey: "3e6304937e09fc28e6567662fe6ae65d",
  );
  static const String _locationIqKey = "pk.cc162333c0bbf1f37e63d8df39a2a776";

  static Future<List<User>> getUsersByName(String name,
      {String? excludeUid}) async {
    // search for users if name query string is not empty
    if (name != "") {
      // obtain algolia snapshot (excluding provided uid)
      AlgoliaQuerySnapshot snapshot = await _algolia.instance
          .index('users')
          .filters(
              'NOT objectID:$excludeUid') // excludes active user from results
          .query(name)
          .getObjects();
      // create list from returned snapshot
      return snapshot.hits.map((object) {
        Map<String, dynamic> json = object.toMap();
        json['uid'] = json['objectId'];
        return User.fromJson(json);
      }).toList();
      // return empty list if query string is empty
    } else {
      return List.empty();
    }
  }

  static Future<List<Place>> getPlacesByName(String name) async {
    // query location iq for places with a given name
    var url = Uri.https(
      "eu1.locationiq.com",
      "v1/autocomplete",
      {
        "key": _locationIqKey,
        "q": name,
        "format": "json",
      },
    );
    var response = await http.get(url);
    // extract places from http response and return list
    List<Place> places = List.empty();
    for (Map<String, dynamic> json in jsonDecode(response.body)) {
      json['id'] = json['osm_id'];
      json['name'] = json['display_place'] ?? json['display_name'];
      json['city'] = json['address']['city'];
      json['state'] = json['address']['state'];
      json['country'] = json['address']['country'];
      places.add(Place.fromJson(json));
    }
    return places;
  }
}
