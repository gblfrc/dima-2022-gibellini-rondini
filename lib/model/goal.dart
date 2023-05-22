import 'package:progetto/model/user.dart';

class Goal {
  String? id;
  User? owner;
  String type;
  double targetValue;
  double? currentValue;
  bool completed;

  Goal(
      {this.id,
      this.owner,
      required this.type,
      required this.targetValue,
      this.currentValue,
      required this.completed});

  static fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      owner: json['owner'],
      type: json['type'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'].toDouble(),
      completed: json['completed'],
    );
  }
}
