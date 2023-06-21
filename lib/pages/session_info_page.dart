import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/session_map.dart';
import '../model/session.dart';

class SessionInfoPage extends StatelessWidget {
  Session session;

  SessionInfoPage(this.session, {super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("d MMM y").add_Hm().format(session.start);
    String time = "";
    Duration duration = Duration(seconds: session.duration.round());
    String hours = duration.inHours.toString();
    String minutes =
    duration.inMinutes.remainder(60).toString().padLeft(2, "0");
    String seconds =
    duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    if (session.duration < Duration.secondsPerHour) {
      time = "$minutes:$seconds";
    } else {
      time = "$hours:$minutes:$seconds";
    }
    String length = "";
    if (session.distance < 1000) {
      length = "${session.distance.round()} m";
    } else {
      length = "${(session.distance / 1000).toStringAsFixed(2)} km";
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session info"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: SessionMap(session: session),
          ),
          Flexible(
            flex: 1,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
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
                          time,
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
                          length,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
