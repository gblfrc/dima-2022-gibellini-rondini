import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    }
    on StateError catch (_) {
      type = "Private";
    }
    String formattedDuration = "${sessionData["duration"] ~/ (60 * 60)} h ";
    formattedDuration +=
    "${(sessionData["duration"] ~/ 60)} min";
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
                      Text("${(sessionData["distance"] / 1000).toStringAsFixed(2)} km"),
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
    String title = "Run for ";
    if(goalData["completed"]) {
      status = "Completed";
    } else {
      status = "In progress";
    }
    if(goalData["isMin"]) {
      title += "at least ";
    }
    else {
      title += "no more than ";
    }
    if(goalData["type"] == "distanceGoal") {
      title += "${goalData["targetValue"]} km";
    }
    else {
      title += "${goalData["targetValue"]} min";
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: goalData["currentValue"] / goalData["targetValue"],
                backgroundColor: Theme.of(context).focusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainingProposalCard extends StatelessWidget {
  DocumentSnapshot proposalData;

  TrainingProposalCard(this.proposalData, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = proposalData["dateTime"].toDate().toLocal();
    String formattedDate = DateFormat("MMM d, y ").add_Hm().format(dateTime);
        //"${dateTime.month}/${dateTime.day}, ${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    return Card(
      child: InkWell(
        onTap: () => print("Card tap"),
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            ListTile(
              title: FutureBuilder( // We need to fetch asynchronously the place name
                future: getPlaceName(proposalData["place"]),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Text("Proposed session at ${snapshot.data}");
                  }
                  else {
                    return const Text("Loading...");
                  }
                },

              ),
              subtitle: Text(proposalData["type"]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                    onPressed: () => print("Pressed"),
                    child: const Text("Join training"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getPlaceName(DocumentReference place) async {
    final placeDoc = await place.get();
    return placeDoc.get("name");
  }
}
