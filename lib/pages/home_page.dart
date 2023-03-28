import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/cards.dart';
import '../app_logic/auth.dart';

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
          Text(user?.email ?? 'Something went wrong!!!'),
          const ListTile(
            // Widget that allows to insert a title and (optionally) a sub-title
            title: Text("Latest sessions"),
          ),
          SessionCard("Private", "2023-03-14T16:00:00Z", 83, 5.98),
          SessionCard("Private", "2023-03-15T18:30:00Z", 49, 4.20),
          SessionCard("Shared", "2023-03-20T13:00:00Z", 70, 5.43),
          const ListTile(
            title: Text("My goals"),
          ),
          GoalCard("Run for at least 20 km", false, 20, 10.18),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // TODO: Change onPressed callback: this is not doing anything at the moment
        onPressed: () => print("FAB Pressed"),
        tooltip: 'New session',
        child: const Icon(Icons.directions_run),
      ),
    );
  }
}