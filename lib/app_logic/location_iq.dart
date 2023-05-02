import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationIq {
  static const String key = "pk.cc162333c0bbf1f37e63d8df39a2a776";

  static Future<List<Map<String, dynamic>>> get(String name) async {
    var url = Uri.https("eu1.locationiq.com", "v1/autocomplete", {
      "key": key,
      "q": name,
      "format": "json"
    });
    var response = await http.get(url);
    List<Map<String, dynamic>> newList = [];
    for (Map<String, dynamic> m in jsonDecode(response.body)) {
      newList.add(m);
    }
    return newList;
  }
}