class User {
  String name;
  String surname;
  DateTime? birthday;
  String uid;

  User({required this.name, required this.surname, this.birthday, required this.uid});

  /*
  * Function to create a User object from a json map
  * Required json structure: {
  *   String name,
  *   String surname,
  *   String birthday,
  *   String uid
  * }
  * */
  static User fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      surname: json['surname'],
      // dart can parse dates only formatted as yyyy-MM-dd
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      uid: json['uid'],
    );
  }
}
