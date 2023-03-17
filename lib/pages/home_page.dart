import 'package:flutter/material.dart';

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
          Card(
            child: InkWell(
              // This widget creates a feedback animation when the user taps on the card
              onTap: () => print("Card tap"),
              // TODO: The callback should show details about the session
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 1),
                  // The box should take the entire width of the screen
                  ListTile(
                    title: Text("Session of Mar 14, 2023"),
                    subtitle: Text("Private"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("1 h 23 min"),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("5.98 km"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () => print("Card tap"),
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 1),
                  ListTile(
                    title: Text("Session of Mar 15, 2023"),
                    subtitle: Text("Private"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("0 h 49 min"),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text("4.20 km"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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