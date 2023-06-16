import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/model/place.dart';
import 'package:progetto/model/user.dart';

@GenerateNiceMocks([
  MockSpec<Algolia>(),
  MockSpec<AlgoliaIndexReference>(),
  MockSpec<AlgoliaQuery>(),
  MockSpec<AlgoliaQuerySnapshot>(),
  MockSpec<AlgoliaObjectSnapshot>(),
  MockSpec<AlgoliaError>(),
])
import 'search_engine_test.mocks.dart';

main() {
  late SearchEngine searchEngine;
  late Algolia mockAlgolia;
  late Client mockHttpClient;
  late Response testResponse;
  late Map<String, dynamic> mockUserJson0;
  late Map<String, dynamic> mockUserJson1;
  late Map<String, dynamic> mockPlaceJson0;
  late Map<String, dynamic> mockPlaceJson1;
  final AlgoliaQuery mockQuery = MockAlgoliaQuery();
  final AlgoliaIndexReference mockIndex = MockAlgoliaIndexReference();
  final AlgoliaQuerySnapshot mockQuerySnapshot = MockAlgoliaQuerySnapshot();
  final AlgoliaObjectSnapshot mockObjectSnapshot0 = MockAlgoliaObjectSnapshot();
  final AlgoliaObjectSnapshot mockObjectSnapshot1 = MockAlgoliaObjectSnapshot();

  setUpAll(() {
    testResponse = Response('test', 200);
    mockAlgolia = MockAlgolia();
    mockHttpClient = MockClient((request) => Future.value(testResponse));
    searchEngine = SearchEngine(algolia: mockAlgolia, httpClient: mockHttpClient);
  });

  setUp(() {
    mockUserJson0 = {
      'name': 'Mario',
      'surname': 'Rossi',
      'uid': 'mario_rossi',
      'objectID': 'mario_rossi',
      'friends': [],
    };
    mockUserJson1 = {
      'name': 'Luigi',
      'surname': 'Verdi',
      'uid': 'luigi_verdi',
      'objectID': 'luigi_verdi',
      'birthday': '1999-04-03',
      'friends': [mockUserJson0['uid']],
    };
    mockPlaceJson0 = {
      'place_id': '321172780204',
      'osm_id': '11694848',
      'osm_type': 'relation',
      'licence': 'https://locationiq.com/attribution',
      'lat': '45.70170195',
      'lon': '9.67717354',
      'class': 'leisure',
      'type': 'park',
      'display_name': 'Parco Suardi, Italy',
      'display_place': 'Parco Suardi',
      'display_address': 'Italy',
      'address': {'name': 'Parco Suardi', 'country': 'Italy', 'country_code': 'it'}
    };
    mockPlaceJson1 = {
      'place_id': '323598804122',
      'osm_id': '1069916216',
      'osm_type': 'way',
      'licence': 'https://locationiq.com/attribution',
      'lat': '45.70200105',
      'lon': '9.67633982',
      'class': 'leisure',
      'type': 'playground',
      'display_name':
          'Parco Giochi Suardi, Via Luigi Brignoli, Borgo Santa Caterina, Bergamo, Bergamo, Lombardy, 24124, Italy',
      'display_place': 'Parco Giochi Suardi',
      'display_address': 'Via Luigi Brignoli, Borgo Santa Caterina, Bergamo, Bergamo, Lombardy, 24124, Italy',
      'address': {
        'name': 'Parco Giochi Suardi',
        'road': 'Via Luigi Brignoli',
        'suburb': 'Borgo Santa Caterina',
        'city': 'Bergamo',
        'county': 'Bergamo',
        'state': 'Lombardy',
        'postcode': 24124,
        'country': 'Italy',
        'country_code': 'it'
      }
    };
    testResponse = Response(jsonEncode([mockPlaceJson0, mockPlaceJson1]), 200);
  });

  test('singleton properties', () {
    SearchEngine searchEngineNew = SearchEngine();
    expect(searchEngine, searchEngineNew);
    expect(searchEngine.algoliaType, mockAlgolia.runtimeType);
    expect(searchEngine.httpClientType, mockHttpClient.runtimeType);
  });


  void algoliaInit() {
    when(mockAlgolia.instance).thenReturn(mockAlgolia);
    when(mockAlgolia.index('users')).thenReturn(mockIndex);
    when(mockIndex.filters('NOT objectID:test')).thenReturn(mockQuery);
    when(mockQuery.query('ri')).thenReturn(mockQuery);
    when(mockQuery.getObjects()).thenAnswer((realInvocation) => Future.value(mockQuerySnapshot));
    when(mockQuerySnapshot.hits).thenReturn([mockObjectSnapshot0, mockObjectSnapshot1]);
    when(mockObjectSnapshot0.toMap()).thenReturn(mockUserJson0);
    when(mockObjectSnapshot1.toMap()).thenReturn(mockUserJson1);
  }

  group('algolia', () {
    test('returns normally with non-null query string', () async {
      algoliaInit();
      List<User?> users = await searchEngine.getUsersByName('ri', excludeUid: 'test');
      expect(users.length, 2);
    });

    test('returns normally with empty query string', () async {
      List<User?> users = await searchEngine.getUsersByName("", excludeUid: 'test');
      expect(users.isEmpty, true);
    });

    test("illegal parameter in received map doesn't allow user creation", () async {
      mockUserJson0['name'] = 10;
      algoliaInit();
      List<User?> users = await searchEngine.getUsersByName('ri', excludeUid: 'test');
      expect(users.length, 1);
    });

    test('throws exception', () {
      algoliaInit();
      when(mockAlgolia.index('users')).thenThrow(MockAlgoliaError());
      expect(() => searchEngine.getUsersByName('test', excludeUid: 'test'), throwsA(isA<SearchEngineException>()));
    });
  });

  group('get places', () {
    test('correct output with non-empty query string', () async {
      searchEngine.getPlacesByName('test');
      List<Place> places = await searchEngine.getPlacesByName('test');
      expect(places.length, 2);
    });

    test('correct output with empty query string', () async {
      List<Place> places = await searchEngine.getPlacesByName('');
      expect(places.isEmpty, true);
    });

    test('exception occurs while parsing json', () async {
      mockPlaceJson0['lat'] = 'test';
      testResponse = Response(jsonEncode([mockPlaceJson0, mockPlaceJson1]), 200);
      List<Place> places = await searchEngine.getPlacesByName('test');
      expect(places.length, 1);
    });

  });
}
