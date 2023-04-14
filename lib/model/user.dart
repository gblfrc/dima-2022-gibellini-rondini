import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String surname;
  DateTime? birthday;

  User({required this.name, required this.surname, this.birthday});

  static User fromJson(Map<String, dynamic> json) => User(
  name: json['name'],
  surname: json['surname'],
  birthday: json['birthday'] != null ? (json['birthday'] as Timestamp).toDate() : null
  );

}