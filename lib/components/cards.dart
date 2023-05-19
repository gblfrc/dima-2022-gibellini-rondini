import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/auth.dart';

import '../app_logic/database.dart';
import '../model/proposal.dart';
import '../pages/session_info_page.dart';
import '../pages/goal_info_page.dart';

class SessionCard extends StatelessWidget {
  DocumentSnapshot sessionData;

  SessionCard(this.sessionData, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = sessionData["startDT"].toDate().toLocal();
    String formattedDate = DateFormat("MMM d, y").format(dateTime);
    String type = "";
    try {
      sessionData["proposalID"];
      type = "Shared";
    } on StateError catch (_) {
      type = "Private";
    }
    String formattedDuration = "${sessionData["duration"] ~/ (60 * 60)} h ";
    formattedDuration += "${(sessionData["duration"] ~/ 60)} min";
    return Card(
      child: InkWell(
        // This widget creates a feedback animation when the user taps on the card
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SessionInfoPage(sessionData),
          ),
        ),
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            // The box should take the entire width of the screen
            ListTile(
              title: Text("Session of $formattedDate"),
              subtitle: Text(type),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(formattedDuration),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                          "${(sessionData["distance"] / 1000).toStringAsFixed(2)} km"),
                    ],
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

class GoalCard extends StatelessWidget {
  DocumentSnapshot goalData;

  GoalCard(this.goalData, {super.key});

  @override
  Widget build(BuildContext context) {
    String status;
    String title = "Run ";
    if (goalData["completed"]) {
      status = "Completed";
    } else {
      status = "In progress";
    }
    if (goalData["type"] == "distanceGoal") {
      title += "for at least ${goalData["targetValue"]} km";
    } else if (goalData["type"] == "timeGoal") {
      title += "for at least ${goalData["targetValue"]} min";
    } else {
      title +=
          "with an average speed of at least ${goalData["targetValue"]} km/h";
    }

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalInfoPage(goalData),
          ),
        ),
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            ListTile(
              title: Text(title),
              subtitle: Text(status),
            ),
            goalData["type"] != "speedGoal"
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: goalData["currentValue"] / goalData["targetValue"],
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

  const TrainingProposalCard({super.key, required this.proposal});

  @override
  State<TrainingProposalCard> createState() => _TrainingProposalCardState();
}

class _TrainingProposalCardState extends State<TrainingProposalCard> {
  @override
  Widget build(BuildContext context) {
    Proposal proposal = widget.proposal;
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
                  ElevatedButton(
                    onPressed: () {
                      if (joinable) {
                        try {
                          Database.addParticipantToProposal(proposal);
                          print('joined');
                          proposal.participants.add(Auth().currentUser!.uid);
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
                          Database.removeParticipantFromProposal(proposal);
                          print('joined');
                          proposal.participants.remove(Auth().currentUser!.uid);
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
                    child: joinable ? const Text("Join") : const Text('Leave'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/*Future<String> getPlaceName(DocumentReference place) async {
    final placeDoc = await place.get();
    return placeDoc.get("name");
  }*/
}
