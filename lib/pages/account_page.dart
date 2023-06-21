import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/profile_header.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/pages/edit_profile_page.dart';

import '../components/cards.dart';
import '../model/user.dart';

class AccountPage extends StatefulWidget {
  final String uid;

  const AccountPage({super.key, required this.uid});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? user;

  @override
  Widget build(BuildContext context) {
    // define number of columns based on device orientation
    int columns;
    MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? columns = 2 : columns = 1;
    // save padding entity for convenience
    double padding = MediaQuery.of(context).size.shortestSide / 30;
    // boolean to determine whether current user is the owner of the account page
    bool isMyAccount = (widget.uid == Auth().currentUser!.uid);
    // define tabs
    List<Tab> tabs = isMyAccount
        ? const [Tab(text: 'Sessions'), Tab(text: 'Proposals'), Tab(text: 'Goals')]
        : const [Tab(text: 'Sessions'), Tab(text: 'Proposals')];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: isMyAccount ? const Text('My account') : const Text('Account details'),
          actions: isMyAccount
              ? [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit profile'),
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                onTap: () async {
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                        user: user!,
                                        database: Database(),
                                        auth: Auth(),
                                        storage: Storage(),
                                        imagePicker: ImagePicker(),
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text('Logout'),
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                onTap: () async {
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  await Auth().signOut();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.format_size),
                                title: const Text('Size'),
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                onTap: () async {
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(MediaQuery.of(context).size.toString())));
                                },
                              ),
                            ],
                          ),
                          showCloseIcon: true,
                        ),
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ]
              : [],
        ),
        // body: Container(color: Colors.blue.shade100,),
        body: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false, // if true, another back arrow appears at the top of the page
                collapsedHeight: MediaQuery.of(context).size.longestSide / 6,
                expandedHeight: MediaQuery.of(context).size.longestSide / 6,
                flexibleSpace: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: StreamBuilder(
                    stream: Database().getUser(widget.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('An error has occurred'),
                        );
                      } else if (snapshot.hasData) {
                        user = snapshot.data!;
                        return Column(
                          children: [
                            ProfileHeader(
                              user: user!,
                              storage: Storage(),
                              database: Database(),
                              auth: Auth(),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _ScrollDelegate(TabBar(
                  tabs: tabs,
                )),
                pinned: true,
                floating: true,
              )
            ];
          },
          body: Padding(
            padding: EdgeInsets.fromLTRB(padding / 2, padding / 3, padding / 2, 0),
            // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.shortestSide / 60),
            child: TabBarView(
              children: [
                _SessionTab(
                  uid: widget.uid,
                  columns: columns,
                ),
                if (isMyAccount) const _ProposalTab(),
                if (isMyAccount)
                  _GoalTab(
                    columns: columns,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _ScrollDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _SessionTab extends StatelessWidget {
  final String uid;
  final int columns;

  const _SessionTab({required this.uid, required this.columns});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Database().getLatestSessionsByUser(uid),
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
      },
    );
  }
}

class _ProposalTab extends StatelessWidget {
  const _ProposalTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Database().getProposalsByUser(Auth().currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "An error occurred while loading proposals.",
            textAlign: TextAlign.center,
          );
        }
        if (snapshot.hasData) {
          // This returns true even if there are no documents in the list
          if (snapshot.data!.isEmpty) {
            // If there are no goals, we print a message
            return const Text(
              "No proposal made up to now.",
              textAlign: TextAlign.center,
            );
          }
          List<Widget> proposalList = [];
          for (var proposal in snapshot.data!) {
            proposalList.add(ProposalTile.fromProposal(proposal, context));
          }
          return ListView(
            shrinkWrap: true,
            children: proposalList,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _GoalTab extends StatelessWidget {
  final int columns;

  const _GoalTab({required this.columns});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Database().getGoals(Auth().currentUser!.uid, inProgressOnly: false),
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
              "No goal set up to now.",
              textAlign: TextAlign.center,
            );
          }
          List<Widget> goalList = [];
          for (var goal in snapshot.data!) {
            goalList.add(GoalCard(
              goal,
              database: Database(),
            ));
          }
          return GridView.count(
            shrinkWrap: true,
            crossAxisCount: columns,
            children: goalList,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
