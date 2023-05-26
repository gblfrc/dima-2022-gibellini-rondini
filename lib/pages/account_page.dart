import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/components/contact_card.dart';
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
    bool isMyAccount = (widget.uid == Auth().currentUser!.uid);
    return Scaffold(
      appBar: AppBar(
        title: isMyAccount ? const Text('My account') : const Text('Account details'),
        actions: isMyAccount
            ? [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        // TODO: the snackbar should go over the bottom navigation bar;
                        // TODO: might want to revise handling of the BNB (our of current scaffold)
                        content: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit profile'),
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              onTap: () async {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfilePage(),
                                    settings: RouteSettings(
                                      arguments: user,
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
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                await Auth().signOut();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ]
            : [],
      ),
      body: ListView(
        children: [
          StreamBuilder(
            stream: Database.getUser(widget.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error has occurred'),
                );
              } else if (snapshot.hasData) {
                user = snapshot.data!;
                return Column(
                  children: [
                    ContactCard(user: user!),
                    // TODO: insert list of sessions
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          isMyAccount
              ? Container()
              : Column(
                  children: [
                    FutureBuilder(
                        future: Database.getFriends(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text(
                              "Something went wrong while checking friend list. Please try again later.",
                              textAlign: TextAlign.center,
                            );
                          }
                          if (snapshot.hasData) {
                            for (User friend in snapshot.data!) {
                              if (friend.uid == widget.uid) {
                                return ElevatedButton(
                                  onPressed: removeFriend,
                                  child: const Text("Remove friend"),
                                );
                              }
                            }
                            return FilledButton(
                              onPressed: addFriend,
                              child: const Text("Add to friends"),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  ],
                ),
          Text(
            'Sessions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23 * MediaQuery.of(context).textScaleFactor,
            ),
          ),
          FutureBuilder(
              future: Database.getLatestSessionsByUser(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('I entered the error section');
                  print(snapshot);
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
        ],
      ),
    );
  }

  void addFriend() {
    try {
      Database.addFriend(widget.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to friends!"),
        ),
      );
      Navigator.of(context).pop();
    } on DatabaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }

  void removeFriend() {
    try {
      Database.removeFriend(widget.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Friend removed."),
        ),
      );
      Navigator.of(context).pop();
    } on DatabaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }
}
