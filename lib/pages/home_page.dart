import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progetto/pages/session_page.dart';
import '../app_logic/database.dart';
import '../components/cards.dart';
import '../app_logic/auth.dart';
import 'create_goal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page"),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(
            // Widget that allows to insert a title and (optionally) a sub-title
            title: Text("Latest sessions"),
          ),
          StreamBuilder(
              stream: Database.getLatestSessions(limit: 2),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong. Please try again later.",
                    textAlign: TextAlign.center,
                  );
                }
                if (snapshot.hasData) {
                  // This returns true even if there are no documents in the list
                  if (snapshot.data!.docs.isEmpty) {
                    // If there are no sessions, we print a message
                    return const Text(
                      "You do not have any completed session yet.",
                      textAlign: TextAlign.center,
                    );
                  }
                  List<Widget> sessionList = [];
                  for (var session in snapshot.data!.docs) {
                    // For each session, we create a card and append it to the array of children
                    sessionList.add(SessionCard(session));
                  }
                  return Column(
                    children: sessionList,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          //SessionCard("Private", "2023-03-14T16:00:00Z", 83, 5.98),
          //SessionCard("Private", "2023-03-15T18:30:00Z", 49, 4.20),
          //SessionCard("Shared", "2023-03-20T13:00:00Z", 70, 5.43),
          const ListTile(
            title: Text("My goals"),
          ),
          StreamBuilder(
              stream: Database.getGoals(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong. Please try again later.",
                    textAlign: TextAlign.center,
                  );
                }
                if (snapshot.hasData) {
                  // This returns true even if there are no documents in the list
                  if (snapshot.data!.docs.isEmpty) {
                    // If there are no goals, we print a message
                    return const Text(
                      "You do not have any goal to reach at the moment...\nTime for a new challenge?",
                      textAlign: TextAlign.center,
                    );
                  }
                  List<Widget> goalList = [];
                  for (var goal in snapshot.data!.docs) {
                    goalList.add(GoalCard(goal));
                  }
                  return Column(
                    children: goalList,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          Column(
            // Wrapping the button with a Column avoids the button to take 100% width
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateGoalPage(),
                  ),
                ),
                child: const Text("New goal"),
              ),
              // GoalCard("Run for at least 20 km", false, 20, 10.18),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // TODO: Change onPressed callback: this is not doing anything at the moment
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SessionPage())),
        tooltip: 'New session',
        child: const Icon(Icons.directions_run),
      ),
    );
  }
}
