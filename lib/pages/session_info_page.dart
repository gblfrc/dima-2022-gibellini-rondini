import 'package:flutter/material.dart';

class SessionInfoPage extends StatelessWidget {
  String sessionID;

  SessionInfoPage(this.sessionID, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session info"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(110),
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: const Text('Session Map goes here.'),
            ),
          ),
          Flexible(
            flex: 1,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "3/14/2023 16:30:21",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Start"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "1:23:36",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Duration"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "5.98 km",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Distance"),
                        ],
                      ),
                    ],
                  ),
                  /*child: Column(
                  children: [
                    //const FractionallySizedBox(widthFactor: 1),
                    ListTile(
                      minLeadingWidth: 0,
                      horizontalTitleGap: 5,
                      leading: SizedBox(
                        width: 30,
                        child: Center(
                          child: Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      title: Text("1 h 40 min"),
                      subtitle: Text("Duration"),
                    ),
                  ],
                ), */
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
