import 'package:flutter/material.dart';
import 'package:progetto/pages/session_info_page.dart';

class SessionCard extends StatelessWidget {
  String type;
  String dateString;
  int duration;
  double distance;

  // TODO: Add callback or info about session ID

  SessionCard(this.type, this.dateString, this.duration, this.distance, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    String formattedDate =
        "${dateTime.month}/${dateTime.day}, ${dateTime.year}"; // TODO: Print month name instead of number
    return Card(
      child: InkWell(
        // This widget creates a feedback animation when the user taps on the card
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SessionInfoPage("dkcsmfkak24"),
          ),
        ),
        // TODO: The callback should show details about the session
        child: Column(
          children: [
            const FractionallySizedBox(widthFactor: 1), // The box should take the entire width of the screen
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
                      Text("${duration ~/ 60} h ${duration % 60} min"),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text("$distance km"),
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

  GoalCard(this.title, this.isCompleted, this.targetValue, this.currentValue, {super.key});

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
        onTap: () => print("Card tap"),
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

  TrainingProposalCard(this.locationName, this.type, this.dateString, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    String formattedDate =
        "${dateTime.month}/${dateTime.day}, ${dateTime.year} ${dateTime.hour}:${dateTime.minute}"; // TODO: Print month name instead of number
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
