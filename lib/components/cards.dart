import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:progetto/components/session_map.dart';

import '../app_logic/database.dart';
import '../model/goal.dart';
import '../model/session.dart';
import '../pages/session_info_page.dart';

class SessionCard extends StatelessWidget {
  final Session session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // initialize date string; print also year if different from current one
    String date = "";
    if (session.start.year < DateTime.now().year) {
      date = DateFormat("MMM d, y").format(session.start).toUpperCase();
    } else {
      date = DateFormat("MMM d").format(session.start).toUpperCase();
    }
    // initialize length string; print length in meters if less than 1 km
    String length = "";
    if (session.distance < 1000) {
      length = "${session.distance.round()} m";
    } else {
      length = "${(session.distance / 1000).toStringAsFixed(1)} km";
    }
    // initialize time string; print hours only if more than an hour was run
    String time = "";
    Duration duration = Duration(seconds: session.duration.round());
    String hours = duration.inHours.toString();
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, "0");
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    if (session.duration < Duration.secondsPerHour) {
      time = "$minutes:$seconds";
    } else {
      time = "$hours:$minutes:$seconds";
    }
    // String type = "";
    // try {
    //   sessionData["proposalID"];
    //   type = "Shared";
    // } on StateError catch (_) {
    //   type = "Private";
    // }
    return Card(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SizedBox(
            width: constraint.maxWidth,
            height: MediaQuery.of(context).size.longestSide / 6.5,
            child: InkWell(
              // This widget creates a feedback animation when the user taps on the card
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SessionInfoPage(session),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    max(MediaQuery.of(context).size.shortestSide / 30, 10)),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                length,
                                style: TextStyle(
                                    height: 0,
                                    // used to remove default padding
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            25),
                              ),
                              Text(
                                date,
                                key: const Key('DateText'),
                                style: TextStyle(
                                    height: 0,
                                    //used to remove default padding
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            15),
                              ),
                            ],
                          ),
                          Text(
                            "TIME: $time",
                            style: TextStyle(
                                height: 0,
                                //used to remove default padding
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        15),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 4,
                        child: LayoutBuilder(
                          builder: (context, constraint) {
                            return SizedBox(
                              width: constraint.maxWidth,
                              height: constraint.maxHeight,
                              child: SessionMap(
                                session: session,
                                useMarkers: false,
                                interactiveFlags: InteractiveFlag.none,
                              ),
                            );
                          },
                        ))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GoalCard extends StatefulWidget {
  final Goal goal;

  const GoalCard(this.goal, {super.key});

  @override
  State<GoalCard> createState() => _GoalCardState();
}
class _GoalCardState extends State<GoalCard> {
  @override
  Widget build(BuildContext context) {
    Goal goal = widget.goal;
    String status;
    String title = "Run ";
    if (goal.completed) {
      status = "Completed";
    } else {
      status = "In progress";
    }
    if (goal.type == "distanceGoal") {
      title += "for at least ${goal.targetValue} km";
      if (!goal.completed) {
        status = "${goal.currentValue?.toStringAsFixed(1)} km already run";
      }
    } else if (goal.type == "timeGoal") {
      title += "for at least ${goal.targetValue.toStringAsFixed(0)} min";
      if (!goal.completed) {
        status = "${goal.currentValue?.toStringAsFixed(0)} min already run";
      }
    } else {
      title += "with an average speed of at least ${goal.targetValue} km/h";
    }
    String date = "";
    if (goal.creationDate.year < DateTime.now().year) {
      date = DateFormat("MMM d, y AT")
          .add_Hm()
          .format(goal.creationDate)
          .toUpperCase();
    } else {
      date = DateFormat("MMM d AT")
          .add_Hm()
          .format(goal.creationDate)
          .toUpperCase();
    }

    return Card(
      child: InkWell(
        onTap: null,
        /*() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalInfoPage(goal),
          ),
        ),*/
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(status),
                  ),
                ),
                Padding(padding: const EdgeInsets.all(16),
                child: FilledButton(onPressed: () => deleteGoal(goal), child: const Text("Delete"))),
              ],
            ),
            goal.type != "speedGoal"
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: (goal.currentValue ?? 0) / goal.targetValue,
                      backgroundColor: Theme.of(context).focusColor,
                    ),
                  )
                : Container(),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(
                      max(MediaQuery.of(context).size.shortestSide / 30, 10)),
                  child: Text(
                    "CREATED ON $date",
                    style: TextStyle(
                        height: 0,
                        //used to remove default padding
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).textScaleFactor * 15),
                  ),
                )
              ],
            )
            /*LinearProgressIndicator(
              value: (goal.currentValue ?? 0) / goal.targetValue,
              backgroundColor: Theme.of(context).focusColor,
            ),*/
          ],
        ),
      ),
    );
  }

  void deleteGoal(Goal goal) async {
    try {
      await Database().deleteGoal(goal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goal deleted!"),
        ),
      );
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }
}
