class User {
  String name;
  String surname;
  DateTime? birthday;

  User({required this.name, required this.surname, this.birthday});

  static User fromJson(Map<String, dynamic> json) => User(
        name: json['name'],
        surname: json['surname'],
        // dart can parse dates only formatted as yyyy-MM-dd
        birthday: DateTime.parse(json['birthday']),
      );
}
