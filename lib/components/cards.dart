import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/components/session_map.dart';

import '../app_logic/database.dart';
import '../model/goal.dart';
import '../model/proposal.dart';
import '../model/session.dart';
import '../pages/session_info_page.dart';
import '../pages/goal_info_page.dart';
import '../pages/session_page.dart';

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
                      )
                    )
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

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard(this.goal, {super.key});

  @override
  Widget build(BuildContext context) {
    String status;
    String title = "Run ";
    if (goal.completed) {
      status = "Completed";
    } else {
      status = "In progress";
    }
    if (goal.type == "distanceGoal") {
      title += "for at least ${goal.targetValue} km";
    } else if (goal.type == "timeGoal") {
      title += "for at least ${goal.targetValue.toStringAsFixed(0)} min";
    } else {
      title += "with an average speed of at least ${goal.targetValue} km/h";
    }

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalInfoPage(goal),
          ),
        ),
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            ListTile(
              title: Text(title),
              subtitle: Text(status),
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
          ],
        ),
      ),
    );
  }
}

class TrainingProposalCard extends StatefulWidget {
  final Proposal proposal;
  final bool? startButton;

  const TrainingProposalCard(
      {super.key, required this.proposal, this.startButton});

  @override
  State<TrainingProposalCard> createState() => _TrainingProposalCardState();
}

class _TrainingProposalCardState extends State<TrainingProposalCard> {
  @override
  Widget build(BuildContext context) {
    Proposal proposal = widget.proposal;
    bool? startButton = widget.startButton;
    bool joinable;
    if (!proposal.participants.contains(Auth().currentUser!.uid)) {
      joinable = true;
    } else {
      joinable = false;
    }
    DateTime dateTime = proposal.dateTime.toLocal();
    String formattedDate = DateFormat("MMM d, y ").add_Hm().format(dateTime);
    //"${dateTime.month}/${dateTime.day}, ${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    return Card(
      child: InkWell(
        onTap: () => print("Card tap"),
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            ListTile(
              title: Text("Proposed session at ${proposal.place.name}"),
              subtitle: Text(proposal.type),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                          "Proposed by ${proposal.owner.name} ${proposal.owner.surname}")
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(formattedDate),
                    ],
                  ),
                  startButton ?? false
                      ? FilledButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SessionPage(proposal: proposal))),
                          child: const Text("Start"),
                        )
                      : FilledButton(
                          onPressed: () {
                            if (joinable) {
                              try {
                                Database.addParticipantToProposal(proposal);
                                print('joined');
                                proposal.participants
                                    .add(Auth().currentUser!.uid);
                              } on Exception {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "An error occurred. Couldn't join session"),
                                  ),
                                );
                              }
                            } else {
                              try {
                                Database.removeParticipantFromProposal(
                                    proposal);
                                print('joined');
                                proposal.participants
                                    .remove(Auth().currentUser!.uid);
                              } on Exception {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "An error occurred. Couldn't leave session"),
                                  ),
                                );
                              }
                            }
                            setState(() {});
                          },
                          child: joinable
                              ? const Text("Join")
                              : const Text('Leave'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
