import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:progetto/pages/proposal_page.dart';
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
          FutureBuilder(
            future: Database.getUpcomingProposals(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Something went wrong while getting upcoming sessions. Please try again later.",
                  textAlign: TextAlign.center,
                );
              }
              if (snapshot.hasData) {
                // This returns true even if there are no elements in the list
                if (snapshot.data!.isEmpty) {
                  // If there are no upcoming proposals, we don't display anything
                  return Container();
                }
                List<Widget> proposalList = [];
                for (var proposal in snapshot.data!) {
                  // For each session, we create a card and append it to the array of children
                  proposalList.add(TrainingProposalCard(proposal: proposal, startButton: true,));
                }
                return Column(
                  children: List.from([const ListTile(title: Text("Upcoming sessions"),)])..addAll(proposalList),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
          const ListTile(
            // Widget that allows to insert a title and (optionally) a sub-title
            title: Text("Latest sessions"),
          ),
          FutureBuilder(
              future: Database.getLatestSessionsByUser(Auth().currentUser!.uid, limit: 2),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('entering error section');
                  return const Text(
                    "Something went wrong. Please try again later.",
                    textAlign: TextAlign.center,
                  );
                }
                if (snapshot.hasData) {
                  print('entering correct section');
                  // This returns true even if the list of sessions is empty
                  if (snapshot.data!.isEmpty) {
                    // If there are no sessions, we print a message
                    return const Text(
                      "You do not have any completed session yet.",
                      textAlign: TextAlign.center,
                    );
                  }
                  List<Widget> sessionCards = [];
                  for (var session in snapshot.data!) {
                    // For each session, we create a card and append it to the array of children
                    sessionCards.add(SessionCard(session: session!));
                  }
                  return Column(
                    children: sessionCards,
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
        type: ExpandableFabType.left,
        child: const Icon(Icons.add),
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SessionPage())),
            tooltip: 'New session',
            heroTag: 'new-proposal-button',
            child: const Icon(Icons.directions_run),
          ),
          FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProposalPage())),
            tooltip: 'New proposal',
            heroTag: 'new-session-button',
            child: const Icon(Icons.calendar_month),
          ),
        ],
      ),
    );
  }
}
