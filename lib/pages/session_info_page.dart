import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionInfoPage extends StatelessWidget {
  DocumentSnapshot sessionData;

  SessionInfoPage(this.sessionData, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = sessionData["startDT"].toDate().toLocal();
    //String formattedDate =
        //"${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    String formattedDate = DateFormat("d MMM y").add_Hms().format(dateTime);
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
                    spacing: 40,
                    runSpacing: 20,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Start"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${sessionData["duration"] ~/ 60}:${sessionData["duration"] % 60}", // TODO: Maybe is better to also add seconds?
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Duration"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${sessionData["distance"]} km",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Distance"),
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
