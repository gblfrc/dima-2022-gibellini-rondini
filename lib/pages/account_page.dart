import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/components/contact_card.dart';
import 'package:progetto/pages/edit_profile_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
        actions: widget.uid == Auth().currentUser!.uid
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
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
      body: StreamBuilder(
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
    );
  }
}
