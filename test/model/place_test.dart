import 'package:flutter_test/flutter_test.dart';
import 'package:progetto/model/place.dart';

main() {
  late Map<String, dynamic> json;
  late Map<String, dynamic> jsonIntegerCoords;

  setUp(() {
    json = {
      'id': 'testPlaceID',
      'name': 'Parco Suardi',
      'city': 'Bergamo',
      'lat': 45.4029422,
      'lon': 9.20194914,
      'state': null,
      'country': 'Italy',
      'type': 'park'
    };

    jsonIntegerCoords = {
      'id': 'testPlaceID',
      'name': 'Parco Suardi',
      'city': 'Bergamo',
      'lat': 45,
      'lon': 9,
      'state': null,
      'country': 'Italy',
      'type': 'park'
    };
  });

  test('fromJson, state null', () {
    Place place = Place.fromJson(json);
    expect(place.id, 'testPlaceID');
    expect(place.type, 'park');
    expect(place.name, 'Parco Suardi');
    expect(place.city, 'Bergamo');
    expect(place.state, null);
    expect(place.coords.latitude, 45.4029422);
    expect(place.coords.longitude, 9.20194914);
    expect(place.country, 'Italy');
  });

  test('fromJson, coords as integers', () {
    Place place = Place.fromJson(jsonIntegerCoords);
    expect(place.id, 'testPlaceID');
    expect(place.type, 'park');
    expect(place.name, 'Parco Suardi');
    expect(place.city, 'Bergamo');
    expect(place.state, null);
    expect(place.coords.latitude, 45.0);
    expect(place.coords.longitude, 9.0);
    expect(place.country, 'Italy');
  });
}
