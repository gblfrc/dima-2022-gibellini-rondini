import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:http/http.dart';
import 'package:progetto/app_logic/exceptions.dart';

import '../model/place.dart';
import '../model/user.dart';

class SearchEngine {
  static late SearchEngine _instance;
  late Algolia _algolia;
  late Client _httpClient;
  static const String _locationIqKey = "pk.cc162333c0bbf1f37e63d8df39a2a776";

  factory SearchEngine({Algolia? algolia, Client? httpClient}) {
    try {
      return _instance;
    } on Error {
      _instance = SearchEngine._internal(algolia: algolia, httpClient: httpClient);
      return _instance;
    }
  }

  SearchEngine._internal({Algolia? algolia, Client? httpClient}) {
    _algolia = algolia ??
        const Algolia.init(
          applicationId: "U8ISIP6A8A",
          apiKey: "3e6304937e09fc28e6567662fe6ae65d",
        );
    _httpClient = httpClient ?? Client();
  }

  Future<List<User>> getUsersByName(String name, {required String excludeUid}) async {
    // search for users if name query string is not empty
    if (name != "") {
      // obtain algolia snapshot (excluding provided uid)
      AlgoliaQuerySnapshot snapshot;
      try {
        snapshot = await _algolia.instance
            .index('users')
            .filters('NOT objectID:$excludeUid') // excludes active user from results
            .query(name)
            .getObjects();
      } on AlgoliaError {
        throw SearchEngineException('An error occurred in the communication with the server');
      }
      // create list from returned snapshot
      List<User> users = [];
      for (var object in snapshot.hits) {
        User? user;
        try {
          Map<String, dynamic> json = object.toMap();
          json['uid'] = json['objectID'];
          user = User.fromJson(json);
        } on Error {
          user = null;
        }
        if (user != null) users.add(user);
      }
      return users;
      // return empty list if query string is empty
    } else {
      return List.empty();
    }
  }

  Future<List<Place>> getPlacesByName(String name) async {
    if (name != "") {
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
      var response = await _httpClient.get(url);
      // extract places from http response and return list
      List<Place> places = [];
      for (Map<String, dynamic> json in jsonDecode(response.body)) {
        Place? place;
        try {
          json['id'] = json['osm_id'];
          json['lat'] = double.parse(json['lat']);
          json['lon'] = double.parse(json['lon']);
          json['name'] = json['display_place'] ?? json['display_name'];
          json['city'] = json['address']['city'];
          json['state'] = json['address']['state'];
          json['country'] = json['address']['country'];
          place = Place.fromJson(json);
        } on Exception {
          place = null;
        }
        if (place != null) places.add(place);
      }
      return places;
    } else {
      return List.empty();
    }
  }
}
