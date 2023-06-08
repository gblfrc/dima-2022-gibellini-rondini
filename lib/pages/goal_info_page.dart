import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_logic/database.dart';
import '../model/goal.dart';

class GoalInfoPage extends StatefulWidget {
  Goal goal;

  GoalInfoPage(this.goal, {super.key});

  @override
  State<GoalInfoPage> createState() => _GoalInfoPageState();
}

class _GoalInfoPageState extends State<GoalInfoPage> {
  @override
  Widget build(BuildContext context) {
    Goal goal = widget.goal;
    String target;
    String current;
    if (goal.type == "distanceGoal") {
      target = "${goal.targetValue} km";
      current = "${goal.currentValue?.toStringAsFixed(1)} km";
    } else if (goal.type == "timeGoal") {
      target = "${goal.targetValue.toStringAsFixed(0)} min";
      current = "${goal.currentValue?.toStringAsFixed(0)} min";
    } else {
      target = "${goal.targetValue} km/h";
      current = "N/A";
    }
    String formattedDate = DateFormat("d MMM y").add_Hm().format(goal.creationDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Goal info"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        goal.type != "speedGoal"
                            ? LinearProgressIndicator(
                                value:
                                    (goal.currentValue ?? 0) / goal.targetValue,
                                backgroundColor: Theme.of(context).focusColor,
                              )
                            : Container(),
                        const SizedBox(
                          height: 16,
                        ),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  current,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Current"),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  target,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Target"),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Created"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Column(
                          children: [
                            FilledButton(
                                onPressed: deleteGoal,
                                child: const Text("Delete goal"))
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteGoal() async {
    Goal goal = widget.goal;
    try {
      await Database.deleteGoal(goal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goal deleted!"),
        ),
      );
      Navigator.of(context).pop();
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }
}
