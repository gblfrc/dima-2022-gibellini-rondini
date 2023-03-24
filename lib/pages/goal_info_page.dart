import 'package:flutter/material.dart';

class GoalInfoPage extends StatelessWidget {
  String goalID;

  GoalInfoPage(this.goalID, {super.key});

  @override
  Widget build(BuildContext context) {
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
                        LinearProgressIndicator(
                          value: 10.18 / 20,
                          backgroundColor: Theme.of(context).focusColor,
                        ),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "10.18 km",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Current"),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "20 km",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Target"),
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
