import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/model/session.dart';

main() {
  late Map<String, dynamic> json;

  setUp(() {
    json = {
      'id': 'test',
      'distance': 3419.99,
      'duration': 29514.53,
      'positions': [
        [
          LatLng(45, 9),
          LatLng(45.5, 9),
          LatLng(45.6, 9.1),
          LatLng(45.6, 9.2),
        ],
        [
          LatLng(45.8, 9.3),
          LatLng(46, 9.3),
        ]
      ],
      'start': DateTime(2023, 5, 23, 21, 35, 06),
    };
  });

  test('fromJson, correct output', () {
    Session sut = Session.fromJson(json);
    expect(sut.id, 'test');
    expect(sut.distance, 3419.99);
    expect(sut.duration, 29514.53);
    expect(sut.positions.isEmpty, false);
    expect(sut.start, DateTime(2023, 5, 23, 21, 35, 06));
  });

  test('fromJson, illegal positions', () {
    // empty positions array, list of dynamic
    json['positions'] = [];
    Session? session = Session.fromJson(json);
    expect(session, null);
    // positions array containing only empty lists of dynamic
    json['positions'] = [[], []];
    session = Session.fromJson(json);
    expect(session, null);
    // empty positions array, list of LatLng
    List<List<LatLng>> testList = [];
    json['positions'] = testList;
    session = Session.fromJson(json);
    expect(session, null);
    // positions array containing only empty lists of dynamic
    testList = [[], []];
    json['positions'] = testList;
    session = Session.fromJson(json);
    expect(session, null);
  });

  test('fromJson, list of positions contains one empty list and a legal one', () {
    List<LatLng> testList = [];
    json['positions'][1] = testList;
    Session? session = Session.fromJson(json);
    expect(session!.positions.length, 1);
    expect(session.positions[0].length, 4);
  });

}
