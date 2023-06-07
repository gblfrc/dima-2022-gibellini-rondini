import 'package:flutter_test/flutter_test.dart';
import 'package:progetto/model/user.dart';

main() {
  late Map<String, dynamic> json;

  setUp(() {
    json = {
      'name': 'Mario',
      'surname': 'Rossi',
      'uid': 'mario_rossi',
      'birthday': '1999-04-03'
    };
  });

  group('correct outputs', () {

    test('all fields', () {
      User user = User.fromJson(json);
      expect(user.name, 'Mario');
      expect(user.surname, 'Rossi');
      expect(user.uid, 'mario_rossi');
      expect(user.birthday, isNot(null));
    });

    test('no birthday', () {
      json.remove('birthday');
      User user = User.fromJson(json);
      expect(user.name, 'Mario');
      expect(user.surname, 'Rossi');
      expect(user.uid, 'mario_rossi');
      expect(user.birthday, null);
    });

  });
}
