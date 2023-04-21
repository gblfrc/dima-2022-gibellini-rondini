import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  bool start = true;
  bool pause = false;
  bool stop = false;
  bool resume = false;
  LatLng startingPoint = LatLng(45.694215, 9.670753);

  void updateButtons(bool start, bool pause, bool stop, bool resume) {
    setState(() {
      this.start = start;
      this.pause = pause;
      this.stop = stop;
      this.resume = resume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 5,
            child: FlutterMap(
                options: MapOptions(
                  center: startingPoint,
                  zoom: 18.0,
                ),
                children: [
                  TileLayer(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        // width: 50.0,
                        // height: 50.0,
                        point: startingPoint,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
          Flexible(
            flex: 1,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                // TODO: make these fields updatable
                // These field should be continuously updated when running
                Flexible(
                  child: Center(
                    child: Text(
                      '5 km',
                      style: TextStyle(
                        fontSize: 30 * MediaQuery
                            .of(context)
                            .textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Center(
                    child: Text(
                      '25:16',
                      style: TextStyle(
                        fontSize: 30 * MediaQuery
                            .of(context)
                            .textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: _LowerButtonBar(
              start: start,
              pause: pause,
              stop: stop,
              resume: resume,
              changeButtons: updateButtons,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowerButtonBar extends StatelessWidget {
  final bool start;
  final bool pause;
  final bool stop;
  final bool resume;
  final Function changeButtons;

  const _LowerButtonBar({required this.start,
    required this.pause,
    required this.stop,
    required this.resume,
    required this.changeButtons});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        if (start)
          Flexible(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  changeButtons(false, true, true, false);
                },
                child: Text(
                  'START',
                  style: TextStyle(
                    fontSize: 20 * MediaQuery
                        .of(context)
                        .textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (pause)
          Flexible(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  changeButtons(false, false, true, true);
                },
                child: Text(
                  'PAUSE',
                  style: TextStyle(
                    fontSize: 20 * MediaQuery
                        .of(context)
                        .textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (resume)
          Flexible(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  changeButtons(false, true, true, false);
                },
                child: Text(
                  'RESUME',
                  style: TextStyle(
                    fontSize: 20 * MediaQuery
                        .of(context)
                        .textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (stop)
          Flexible(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  changeButtons(true, false, false, false);
                },
                child: Text(
                  'STOP',
                  style: TextStyle(
                    fontSize: 20 * MediaQuery
                        .of(context)
                        .textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
