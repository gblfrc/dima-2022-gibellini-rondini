import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GoalInfoPage extends StatelessWidget {
  DocumentSnapshot goalData;

  GoalInfoPage(this.goalData, {super.key});

  @override
  Widget build(BuildContext context) {
    String target;
    String current;
    if (goalData["type"] == "distanceGoal") {
      target = "${goalData["targetValue"]} km";
      current = "${goalData["currentValue"]} km";
    } else if (goalData["type"] == "timeGoal") {
      target = "${goalData["targetValue"]} min";
      current = "${goalData["currentValue"]} min";
    } else {
      target = "${goalData["targetValue"]} km/h";
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
                        goalData["type"] != "speedGoal"
                            ? LinearProgressIndicator(
                                value: goalData["currentValue"] /
                                    goalData["targetValue"],
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
