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
    DateTime dateTime = DateTime.parse(sessionData["startDT"].toDate().toString()).toLocal();
    String formattedDate = DateFormat("MMM d, y").format(dateTime);
        //"${dateTime.month}/${dateTime.day}, ${dateTime.year}";
    String type = "";
    try {
      sessionData["proposalID"];
      type = "Shared";
    }
    on StateError catch (_) {
      type = "Private";
    }
    return Card(
      child: InkWell(
        // This widget creates a feedback animation when the user taps on the card
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SessionInfoPage(sessionData),
          ),
        ),
        // TODO: The callback should show details about the session
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
                      Text("${sessionData["duration"] ~/ 60} h ${sessionData["duration"] % 60} min"),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text("${sessionData["distance"]} km"),
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
  String title;
  bool isCompleted;
  double targetValue;
  double currentValue;

  // TODO: Add callback or info about goal ID

  GoalCard(this.title, this.isCompleted, this.targetValue, this.currentValue,
      {super.key});

  @override
  Widget build(BuildContext context) {
    String status;
    if (isCompleted) {
      status = "Completed";
    } else {
      status = "In progress";
    }
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalInfoPage("dkcsmfkak24"),
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
                value: currentValue / targetValue,
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
  String locationName;
  String type;
  String dateString;

  // TODO: Add ID or callback

  TrainingProposalCard(this.locationName, this.type, this.dateString,
      {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    String formattedDate = DateFormat("MMM d, y").format(dateTime);
        //"${dateTime.month}/${dateTime.day}, ${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    return Card(
      child: InkWell(
        onTap: () => print("Card tap"),
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1),
            ListTile(
              title: Text("Proposed session at $locationName"),
              subtitle: Text(type),
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
}
