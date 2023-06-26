import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/forms/edit_profile_form.dart';
import 'package:progetto/components/profile_header.dart';
import 'package:progetto/components/tiles.dart';
import 'package:progetto/pages/edit_profile_page.dart';

import '../components/cards.dart';
import '../model/user.dart';

class AccountPage extends StatefulWidget {
  final String uid;
  final Auth auth;
  final Database database;
  final Storage storage;
  final ImagePicker imagePicker;

  const AccountPage(
      {super.key,
      required this.uid,
      required this.auth,
      required this.database,
      required this.storage,
      required this.imagePicker});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    // define number of columns based on device orientation
    int columns;
    (isTablet || MediaQuery.of(context).orientation == Orientation.landscape) ? columns = 2 : columns = 1;
    // save padding entity for convenience
    double padding = MediaQuery.of(context).size.shortestSide / 30;
    // boolean to determine whether current user is the owner of the account page
    bool isMyAccount = (widget.uid == widget.auth.currentUser!.uid);
    // define tabs
    Tab sessionTab = const Tab(
      text: 'Sessions',
      key: Key('AccountPageSessionTab'),
    );
    Tab proposalTab = const Tab(
      text: 'Proposals',
      key: Key('AccountPageProposalTab'),
    );
    Tab goalTab = const Tab(
      text: 'Goals',
      key: Key('AccountPageGoalTab'),
    );
    List<Tab> tabs = isMyAccount ? [sessionTab, proposalTab, goalTab] : [sessionTab, proposalTab];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          key: const Key('AccountPageAppBar'),
          title: isMyAccount ? const Text('My account') : const Text('Account details'),
          actions: isMyAccount
              ? [
                  IconButton(
                    key: const Key('AccountPageAdditionalActionsButton'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          key: const Key('AccountPageAdditionalActionsSnackBar'),
                          content: Column(
                            children: [
                              StreamBuilder(
                                  stream: widget.database.getUser(widget.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return ListTile(
                                        key: const Key('AccountPageEditProfileButton'),
                                        leading: const Icon(Icons.edit),
                                        title: const Text('Edit profile'),
                                        iconColor: Colors.white,
                                        textColor: Colors.white,
                                        onTap: isTablet
                                            ? () async {
                                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return _EditProfileDialog(
                                                        user: snapshot.data!,
                                                        auth: widget.auth,
                                                        database: widget.database,
                                                        storage: widget.storage,
                                                        imagePicker: widget.imagePicker,
                                                      );
                                                    });
                                              }
                                            : () async {
                                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => EditProfilePage(
                                                      user: snapshot.data!,
                                                      database: widget.database,
                                                      auth: widget.auth,
                                                      storage: widget.storage,
                                                      imagePicker: widget.imagePicker,
                                                    ),
                                                  ),
                                                );
                                              },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                              ListTile(
                                key: const Key('AccountPageLogoutButton'),
                                leading: const Icon(Icons.logout),
                                title: const Text('Logout'),
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                onTap: () async {
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  await widget.auth.signOut();
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
        body: (!isTablet || MediaQuery.of(context).orientation == Orientation.portrait)
            ? _TabSection(
                key: const Key('AccountPageMainCaseBody'),
                uid: widget.uid,
                columns: columns,
                isMyAccount: isMyAccount,
                sliverAppBar: SliverAppBar(
                  automaticallyImplyLeading: false,
                  // if true, another back arrow appears at the top of the page
                  collapsedHeight: MediaQuery.of(context).size.longestSide / 6,
                  expandedHeight: MediaQuery.of(context).size.longestSide / 6,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: _ProfileHeaderWrapper(
                      uid: widget.uid,
                      direction: Axis.horizontal,
                      database: widget.database,
                      auth: widget.auth,
                      storage: widget.storage,
                    ),
                  ),
                ),
                tabs: tabs,
                database: widget.database,
                auth: widget.auth,
                storage: widget.storage,
              )
            : Flex(
                key: const Key('AccountPageHorizontalTabletBody'),
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2.0,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: padding),
                      child: _ProfileHeaderWrapper(
                        uid: widget.uid,
                        direction: Axis.vertical,
                        database: widget.database,
                        auth: widget.auth,
                        storage: widget.storage,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _TabSection(
                      uid: widget.uid,
                      columns: columns,
                      isMyAccount: isMyAccount,
                      tabs: tabs,
                      database: widget.database,
                      auth: widget.auth,
                      storage: widget.storage,
                    ),
                  ),
                ],
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
  final Database database;

  const _SessionTab({required this.uid, required this.columns, required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      key: const Key('AccountPageSessionTabBody'),
      stream: database.getLatestSessionsByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "An error occurred while loading sessions.",
            textAlign: TextAlign.center,
          );
        }
        if (snapshot.hasData) {
          // This returns true even if the list of sessions is empty
          if (snapshot.data!.isEmpty) {
            // If there are no sessions, we print a message
            return const Text(
              "You haven't completed any session yet.",
              textAlign: TextAlign.center,
            );
          }
          List<Widget> sessionCards = [];
          for (var session in snapshot.data!) {
            // For each session, we create a card and append it to the array of children
            sessionCards.add(SessionCard(session: session!));
          }
          return GridView.count(
            key: const Key('AccountPageSessionTabGrid'),
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
  final Database database;
  final Auth auth;
  final Storage storage;
  final  String uid;

  const _ProposalTab({required this.database, required this.auth, required this.storage, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      key: const Key('AccountPageProposalTabBody'),
      stream: database.getProposalsByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "An error occurred while loading proposals.",
            textAlign: TextAlign.center,
          );
        }
        if (snapshot.hasData) {
          print('i have data');
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
            proposalList
                .add(ProposalTile.fromProposal(proposal, context, database: database, auth: auth, storage: storage));
          }
          print(proposalList);
          return ListView(
            key: const Key('AccountPageProposalTabList'),
            shrinkWrap: true,
            children: proposalList,
          );
        } else {
          print('entering the else i should not enter');
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
  final Database database;
  final Auth auth;
  final String uid;

  const _GoalTab({required this.columns, required this.database, required this.auth, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      key: const Key('AccountPageGoalTabBody'),
      stream: database.getGoals(uid, inProgressOnly: false),
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
              database: database,
            ));
          }
          return GridView.count(
            key: const Key('AccountPageGoalTabGrid'),
            shrinkWrap: true,
            crossAxisCount: columns,
            childAspectRatio: 2.25,
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

class _ProfileHeaderWrapper extends StatelessWidget {
  final String uid;
  final Axis direction;
  final Database database;
  final Auth auth;
  final Storage storage;

  const _ProfileHeaderWrapper(
      {required this.uid, required this.direction, required this.database, required this.auth, required this.storage});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: database.getUser(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error has occurred'),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return ProfileHeader(
            key: const Key('AccountPageProfileHeader'),
            user: snapshot.data!,
            storage: storage,
            database: database,
            auth: auth,
            direction: direction,
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

class _TabSection extends StatelessWidget {
  final String uid;
  final int columns;
  final bool isMyAccount;
  final Widget? sliverAppBar;
  final List<Tab> tabs;
  final Database database;
  final Auth auth;
  final Storage storage;

  const _TabSection({
    super.key,
    required this.uid,
    required this.columns,
    required this.isMyAccount,
    this.sliverAppBar,
    required this.tabs,
    required this.database,
    required this.auth,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.shortestSide / 30;
    return NestedScrollView(
      physics: const NeverScrollableScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          if (sliverAppBar != null) sliverAppBar!,
          SliverPersistentHeader(
            delegate: _ScrollDelegate(TabBar(
              key: const Key('AccountPageTabSectionTabBar'),
              tabs: tabs,
            )),
            pinned: true,
            floating: true,
          )
        ];
      },
      body: Padding(
        padding: EdgeInsets.fromLTRB(padding / 2, padding / 3, padding / 2, 0),
        child: TabBarView(
          key: const Key('AccountPageTabSectionTabView'),
          children: [
            _SessionTab(
              uid: uid,
              columns: columns,
              database: database,
            ),
            _ProposalTab(
              database: database,
              auth: auth,
              storage: storage,
              uid: uid,
            ),
            if (isMyAccount)
              _GoalTab(
                columns: columns,
                database: database,
                auth: auth,
                uid: uid,
              )
          ],
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final User user;
  final Auth auth;
  final Storage storage;
  final Database database;
  final ImagePicker imagePicker;

  const _EditProfileDialog(
      {required this.user,
      required this.auth,
      required this.storage,
      required this.database,
      required this.imagePicker});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 2;
    var width = MediaQuery.of(context).size.width / 2;
    MediaQuery.of(context).orientation == Orientation.portrait ? height *= 1.1 : width *= 1.2;
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.shortestSide / 40),
        ),
        height: height,
        width: width,
        child: EditProfileForm(
          user: widget.user,
          auth: widget.auth,
          storage: widget.storage,
          database: widget.database,
          imagePicker: widget.imagePicker,
          direction: MediaQuery.of(context).orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
        ),
      ),
    );
  }
}
