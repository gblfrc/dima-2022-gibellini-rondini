import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progetto/pages/edit_profile_page.dart';
import '../app_logic/auth.dart';
import '../components/contact_card.dart';
import '../model/user.dart';

class AccountPage extends StatelessWidget {
  final String uid;

  const AccountPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: getUser(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _ErrorPage();
        } else if (snapshot.hasData) {
          final user = snapshot.data;
          if (user == null) {
            return const _UserNotFoundPage();
          } else {
            return _LoggedUserPage(user: user);
          }
        } else {
          return const _LoadingPage();
        }
      },
    );
  }

  Stream<User?> getUser(String uid) {
    final docUser = FirebaseFirestore.instance.collection("users").doc(uid);
    return docUser.snapshots().map((doc) => User.fromJson(doc.data()!, uid: uid));
  }
}

class _LoggedUserPage extends StatelessWidget {
  final User user;

  const _LoggedUserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My account'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  EditProfilePage.routeName,
                  arguments:
                      ProfileArguments(user.name, user.surname, user.birthday),
                );
              },
              icon: const Icon(
                Icons.edit,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () async {
                await Auth().signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            ContactCard(
                'https://cdn.vox-cdn.com/thumbor/s0kqMLJlv5TMYQpSe3DAr0KUFBU=/1400x1400/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/24422421/1245495880.jpg',
                "${user.name} ${user.surname}",
                // "Professional basketball player for the Minnesota T'Wolves according to my Wikipedia page."),
                DateFormat.yMd().format(user.birthday!))
          ],
        ));
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
      ),
      body: const Center(
        child: Text('An error occurred'),
      ),
    );
  }
}

class _UserNotFoundPage extends StatelessWidget {
  const _UserNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    var containerWidth = MediaQuery.of(context).size.width / 3;
    var padding = containerWidth / 8;
    containerWidth = containerWidth - 2 * padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Text(
            'Account not found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).textScaleFactor * 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    var containerWidth = MediaQuery.of(context).size.width / 3;
    var padding = containerWidth / 8;
    containerWidth = containerWidth - 2 * padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await Auth().signOut();
            },
          ),
        ],
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
