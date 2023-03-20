import 'package:flutter/material.dart';
import '../components/cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            // Widget that allows to insert a title and (optionally) a sub-title
            title: Text("Latest sessions"),
          ),
          SessionCard("Private", "2023-03-14T16:00:00Z", 83, 5.98),
          SessionCard("Private", "2023-03-15T18:30:00Z", 49, 4.20),
          SessionCard("Shared", "2023-03-20T13:00:00Z", 70, 5.43),
          ListTile(
            title: Text("My goals"),
          ),
          Card(
            child: InkWell(
              onTap: () => print("Card tap"),
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 1),
                  ListTile(
                    title: Text("Run for at least 20 km"),
                    subtitle: Text("In progress"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: 10.18 / 20,
                      backgroundColor: Theme.of(context).focusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
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