import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:progetto/app_logic/location_handler.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/pages/create_proposal_page.dart';
import 'package:progetto/pages/session_page.dart';
import '../app_logic/database.dart';
import '../app_logic/storage.dart';
import '../components/cards.dart';
import '../app_logic/auth.dart';
import '../components/forms/create_goal_form.dart';
import 'create_goal_page.dart';

class HomePage extends StatefulWidget {
  final Database database;
  final Auth auth;
  final Storage storage;

  const HomePage(
      {super.key,
      required this.database,
      required this.auth,
      required this.storage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // variables for usage in multiple occasions
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    // define number of columns based on device orientation
    int columns;
    (isTablet || MediaQuery.of(context).orientation == Orientation.landscape)
        ? columns = 2
        : columns = 1;
    TextStyle sectionTitleStyle = TextStyle(
        fontSize: MediaQuery.of(context).textScaleFactor * 18,
        fontWeight: FontWeight.bold);
    Color buttonBackgroundColor = Theme.of(context).primaryColor;
    Color buttonForegroundColor = Colors.white;
    // main return statement
    return Scaffold(
      key: const Key('HomeScaffold'),
      appBar: AppBar(
        title: const Text("Home page"),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 30),
        child: ListView(
          key: const Key('HomeListView'),
          children: [
            StreamBuilder(
                stream: widget.database.getProposalsWithinInterval(
                  widget.auth.currentUser!.uid,
                  after: DateTime.now().add(const Duration(hours: -2)),
                  before: DateTime.now().add(const Duration(hours: 2)),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'An error occurred while loading trainings.')));
                    });
                    return Container();
                  }
                  if (snapshot.hasData) {
                    // This returns true even if there are no elements in the list
                    if (snapshot.data!.isEmpty) {
                      // If there are no upcoming proposals, don't show anything
                      return Container(key: const Key('NoProposalsContainer'));
                    } else {
                      List<Widget> proposalList = [];
                      for (var proposal in snapshot.data!) {
                        // For each session, we create a card and append it to the array of children
                        proposalList.add(ProposalTile.fromProposal(
                          proposal,
                          context,
                          startable: true,
                          auth: widget.auth,
                          database: widget.database,
                          storage: widget.storage,
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
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.shortestSide / 50),
              child: StreamBuilder(
                  stream: widget.database.getLatestSessionsByUser(
                      widget.auth.currentUser!.uid,
                      limit: 2),
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
                      return GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: columns,
                        childAspectRatio: 2.75,
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
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.shortestSide / 40),
              child: StreamBuilder(
                  stream: widget.database.getGoals(widget.auth.currentUser!.uid,
                      inProgressOnly: true),
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
                        goalList.add(GoalCard(
                          goal,
                          database: widget.database,
                        ));
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
              key: const Key("GoalColumn"),
              // Wrapping the button with a Column avoids the button to take 100% width
              children: [
                FilledButton(
                  key: const Key('CreateGoalButton'),
                  /*onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateGoalPage(
                          database: widget.database, auth: widget.auth),
                    ),
                  ),*/
                  onPressed: isTablet
                      ? () async {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return _CreateGoalDialog(
                                  auth: widget.auth,
                                  database: widget.database,
                                );
                              });
                        }
                      : () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateGoalPage(
                                database: widget.database,
                                auth: widget.auth,
                              ),
                            ),
                          );
                        },
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
        key: const Key('FAB'),
        foregroundColor: buttonForegroundColor,
        backgroundColor: buttonBackgroundColor,
        closeButtonStyle: ExpandableFabCloseButtonStyle(
          foregroundColor: buttonForegroundColor,
          backgroundColor: buttonBackgroundColor,
        ),
        distance: 70,
        type: ExpandableFabType.left,
        child: const Icon(
          Icons.add,
          key: Key('FABIcon'),
        ),
        children: [
          FloatingActionButton(
            key: const Key('NewSessionFAB'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SessionPage(
                      locationHandler: LocationHandler(),
                      auth: widget.auth,
                      database: widget.database,
                    ))),
            tooltip: 'New session',
            heroTag: 'new-proposal-button',
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonForegroundColor,
            child: const Icon(Icons.directions_run),
          ),
          FloatingActionButton(
            key: const Key('CreateProposalFAB'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateProposalPage(
                      auth: widget.auth,
                      database: widget.database,
                      searchEngine: SearchEngine(),
                    ))),
            tooltip: 'New proposal',
            heroTag: 'new-session-button',
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonForegroundColor,
            child: const Icon(Icons.calendar_month),
          ),
        ],
      ),
    );
  }
}

class _CreateGoalDialog extends StatefulWidget {
  final Auth auth;
  final Database database;

  const _CreateGoalDialog({
    required this.auth,
    required this.database,
  });

  @override
  State<_CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<_CreateGoalDialog> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 2;
    var width = MediaQuery.of(context).size.width / 2;
    MediaQuery.of(context).orientation == Orientation.portrait
        ? height *= 0.7
        : width *= 1.2;
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.shortestSide / 40),
        ),
        height: height,
        width: width,
        child: ListView(
          children: [
            CreateGoalForm(
              width: width,
              auth: widget.auth,
              database: widget.database,
            ),
          ],
        ),
      ),
    );
  }
}
