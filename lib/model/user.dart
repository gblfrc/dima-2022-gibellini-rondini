class User {
  String name;
  String surname;
  DateTime? birthday;
  String uid;

  User({required this.name, required this.surname, this.birthday, required this.uid});

  static User fromJson(Map<String, dynamic> json, {required uid}) {
    return User(
      name: json['name'],
      surname: json['surname'],
      // dart can parse dates only formatted as yyyy-MM-dd
      birthday: DateTime.parse(json['birthday']),
      uid: uid,
    );
  }
}
