import 'package:flutter/material.dart';
import '../app_logic/auth.dart';
import '../components/contact_card.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> signOut() async{
    await Auth().signOut();
  }

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
              onPressed: signOut,
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const ContactCard(
                'https://cdn.vox-cdn.com/thumbor/s0kqMLJlv5TMYQpSe3DAr0KUFBU=/1400x1400/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/24422421/1245495880.jpg',
                'Nickeil Alexander-Walker',
                "Professional basketball player for the Minnesota T'Wolves according to my Wikipedia page."),
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
        ));
  }
}
