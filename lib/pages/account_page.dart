import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('My account')),
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  child: const Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const[
                      Text('Federico Gibellini',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )),
                      Text("23 years old"),
                    ]
                )
              ],
            ),
            const ListTile(
              // Widget that allows to insert a title and (optionally) a sub-title
              title: Text("Latest sessions"),
            ),
            Card(
              child: InkWell(
                onTap: () => print("Card tap"),
                child: Column(
                  children: [
                    const FractionallySizedBox(widthFactor: 1),
                    const ListTile(
                      title: Text("Session of Mar 14, 2023"),
                      subtitle: Text("Private"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context).primaryColor,
                              ),
                              const Text("1 h 23 min"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.route,
                                color: Theme.of(context).primaryColor,
                              ),
                              const Text("12 km"),
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
                    const FractionallySizedBox(widthFactor: 1),
                    const ListTile(
                      title: Text("Session of Mar 17, 2023"),
                      subtitle: Text("Public"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context).primaryColor,
                              ),
                              const Text("24 min"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.route,
                                color: Theme.of(context).primaryColor,
                              ),
                              const Text("4.25 km"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}