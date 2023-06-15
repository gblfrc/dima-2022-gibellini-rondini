import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/pages/create_proposal_page.dart';
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
    // variables for usage in multiple occasions
    TextStyle sectionTitleStyle =
        TextStyle(fontSize: MediaQuery.of(context).textScaleFactor * 18, fontWeight: FontWeight.bold);
    Color buttonBackgroundColor = Theme.of(context).primaryColor;
    Color buttonForegroundColor = Colors.white;
    // main return statement
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page"),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 30),
        child: ListView(
          children: [
            StreamBuilder(
                stream: Database().getProposalsWithinInterval(
                  Auth().currentUser!.uid,
                  after: DateTime.now().add(const Duration(hours: -2)),
                  before: DateTime.now().add(const Duration(hours: 2)),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('An error occurred while loading trainings.')));
                  }
                  if (snapshot.hasData) {
                    // This returns true even if there are no elements in the list
                    if (snapshot.data!.isEmpty) {
                      // If there are no upcoming proposals, don't show anything
                      return Container();
                    } else {
                      List<Widget> proposalList = [];
                      for (var proposal in snapshot.data!) {
                        // For each session, we create a card and append it to the array of children
                        proposalList.add(ProposalTile.fromProposal(
                          proposal,
                          context,
                          startable: true,
                        ));
                      }
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'Upcoming trainings',
                          style: sectionTitleStyle,
                        ),
                        ...proposalList,
                      ]);
                    }
                  }
                  return Container();
                }),
            Text(
              "Recent sessions",
              style: sectionTitleStyle,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.shortestSide / 50),
              child: StreamBuilder(
                  stream: Database().getLatestSessionsByUser(Auth().currentUser!.uid, limit: 2),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        "Something went wrong. Please try again later.",
                        textAlign: TextAlign.center,
                      );
                    }
                    if (snapshot.hasData) {
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
            ),
            Text(
              "My goals",
              style: sectionTitleStyle,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.shortestSide / 40),
              child: StreamBuilder(
                  stream: Database().getGoals(true),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        "An error occurred while loading goals.",
                        textAlign: TextAlign.center,
                      );
                    }
                    if (snapshot.hasData) {
                      // This returns true even if there are no documents in the list
                      if (snapshot.data!.isEmpty) {
                        // If there are no goals, we print a message
                        return const Text(
                          "No goal set at the moment...\nTime for a new challenge?",
                          textAlign: TextAlign.center,
                        );
                      }
                      List<Widget> goalList = [];
                      for (var goal in snapshot.data!) {
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
            ),
            Column(
              // Wrapping the button with a Column avoids the button to take 100% width
              children: [
                FilledButton(
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
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        foregroundColor: buttonForegroundColor,
        backgroundColor: buttonBackgroundColor,
        closeButtonStyle: ExpandableFabCloseButtonStyle(
          foregroundColor: buttonForegroundColor,
          backgroundColor: buttonBackgroundColor,
        ),
        distance: 70,
        type: ExpandableFabType.left,
        child: const Icon(Icons.add),
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SessionPage())),
            tooltip: 'New session',
            heroTag: 'new-proposal-button',
            child: const Icon(Icons.directions_run),
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonForegroundColor,
          ),
          FloatingActionButton(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateProposalPage())),
            tooltip: 'New proposal',
            heroTag: 'new-session-button',
            child: const Icon(Icons.calendar_month),
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonForegroundColor,
          ),
        ],
      ),
    );
  }
}
