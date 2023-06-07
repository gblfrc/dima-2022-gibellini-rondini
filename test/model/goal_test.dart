import 'package:flutter_test/flutter_test.dart';
import 'package:progetto/model/goal.dart';

main () {
  late Map<String, dynamic> json;
  late Map<String, dynamic> jsonNullOwner;

  setUp(() {
    json = {
      'id': 'test',
      'owner': {
        'name': 'Mario',
        'surname': 'Rossi',
        'uid': 'mario_rossi'},
      'type': 'distanceGoal',
      'targetValue': 8.0,
      'currentValue': 5.3,
      'completed': false,
      'createdAt': DateTime(2023, 5, 23, 21, 35, 06),
    };

    jsonNullOwner = {
      'id': 'test',
      'owner': null,
      'type': 'distanceGoal',
      'targetValue': 8.0,
      'currentValue': 5.3,
      'completed': false,
      'createdAt': DateTime(2023, 5, 23, 21, 35, 06),
    };
  });

  test('fromJson', () {
    Goal goal = Goal.fromJson(json);
    expect(goal.id, 'test');
    expect(goal.type, 'distanceGoal');
    expect(goal.targetValue, 8.0);
    expect(goal.currentValue, 5.3);
    expect(goal.creationDate, DateTime(2023, 5, 23, 21, 35, 06));
    expect(goal.completed, false);
    expect(goal.owner?.name, 'Mario');
    expect(goal.owner?.surname, 'Rossi');
    expect(goal.owner?.uid, 'mario_rossi');
  });

  test('fromJson, null owner', () {
    Goal goal = Goal.fromJson(jsonNullOwner);
    expect(goal.id, 'test');
    expect(goal.type, 'distanceGoal');
    expect(goal.targetValue, 8.0);
    expect(goal.currentValue, 5.3);
    expect(goal.creationDate, DateTime(2023, 5, 23, 21, 35, 06));
    expect(goal.completed, false);
    expect(goal.owner, null);
  });

}

