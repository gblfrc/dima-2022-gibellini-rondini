import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/model/proposal.dart';

main() {
  late Map<String, dynamic> json;

  setUp(() {
    json = {
      'pid': 'test_proposal',
      'dateTime': "2023-05-23 21:35:06",
      'owner': {
        'name': 'Mario',
        'surname': 'Rossi',
        'uid': 'mario_rossi'},
      'place': {
        'id': 'a place',
        'name': 'Parco Suardi',
        'lat': 45,
        'lon': 9},
      'participants': ['first_participant', 'second_participant'],
      'type': 'Public'
    };
  });

  group('correct outputs', () {
    test('participant list not empty', () {
      Proposal proposal = Proposal.fromJson(json);
      expect(proposal.id, 'test_proposal');
      expect(proposal.dateTime, DateTime(2023, 5, 23, 21, 35, 06));
      expect(proposal.owner.name, 'Mario');
      expect(proposal.owner.surname, 'Rossi');
      expect(proposal.owner.uid, 'mario_rossi');
      expect(proposal.place.name, 'Parco Suardi');
      expect(proposal.place.coords, LatLng(45, 9));
      expect(proposal.place.id, 'a place');
      expect(proposal.participants.length, 2);
      expect(const ListEquality().equals(proposal.participants, ['first_participant', 'second_participant']), true);
    });

    test('empty participant list', () {
      json['participants'] = [];
      Proposal proposal = Proposal.fromJson(json);
      expect(proposal.id, 'test_proposal');
      expect(proposal.dateTime, DateTime(2023, 5, 23, 21, 35, 06));
      expect(proposal.owner.name, 'Mario');
      expect(proposal.owner.surname, 'Rossi');
      expect(proposal.owner.uid, 'mario_rossi');
      expect(proposal.place.name, 'Parco Suardi');
      expect(proposal.place.coords, LatLng(45, 9));
      expect(proposal.place.id, 'a place');
      expect(proposal.participants.isEmpty, true);
    });
  });



  
}