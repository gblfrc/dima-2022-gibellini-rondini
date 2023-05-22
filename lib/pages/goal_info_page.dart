import 'package:flutter/material.dart';

import '../model/goal.dart';

class GoalInfoPage extends StatelessWidget {
  Goal goal;

  GoalInfoPage(this.goal, {super.key});

  @override
  Widget build(BuildContext context) {
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
                                value: (goal.currentValue ?? 0) /
                                    goal.targetValue,
                                backgroundColor: Theme.of(context).focusColor,
                              )
                            : Container(),
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
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
