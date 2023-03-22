import 'package:flutter/material.dart';

class SessionInfoPage extends StatelessWidget {
  String sessionID;

  SessionInfoPage(this.sessionID, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Session $sessionID"),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(110),
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: const Text('Session Map goes here.'),
          ),
        ],
      ),
    );
  }
}
