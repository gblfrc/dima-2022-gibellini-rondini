import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/auth.dart';

import '../app_logic/database.dart';
import '../model/goal.dart';
import '../model/proposal.dart';
import '../model/session.dart';
import '../pages/session_info_page.dart';
import '../pages/goal_info_page.dart';
import '../pages/session_page.dart';

class SessionCard extends StatelessWidget {
  Session session;

  SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("MMM d, y").format(session.start);
    String type = "";
    // try {
    //   sessionData["proposalID"];
    //   type = "Shared";
    // } on StateError catch (_) {
    //   type = "Private";
    // }
    String formattedDuration = "${session.duration ~/ (60 * 60)} h ";
    formattedDuration += "${(session.duration ~/ 60)} min";
    return Card(
      child: InkWell(
        // This widget creates a feedback animation when the user taps on the card
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SessionInfoPage(session),
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
                          "${(session.distance / 1000).toStringAsFixed(2)} km"),
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
  Goal goal;

  GoalCard(this.goal, {super.key});

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
      title += "for at least ${goal.targetValue} min";
    } else {
      title +=
          "with an average speed of at least ${goal.targetValue} km/h";
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
                      value: goal.currentValue ?? 0 / goal.targetValue,
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
                      ? ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SessionPage(proposal: proposal))),
                          child: const Text("Start"),
                        )
                      : ElevatedButton(
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

/*Future<String> getPlaceName(DocumentReference place) async {
    final placeDoc = await place.get();
    return placeDoc.get("name");
  }*/
}
