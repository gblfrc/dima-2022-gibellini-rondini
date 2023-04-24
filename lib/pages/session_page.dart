import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  bool start = false;
  bool pause = false;
  bool stop = false;
  bool resume = false;
  LatLng startingPoint = LatLng(45.694215, 9.670753);
  LatLng? _currentPosition;
  final List<LatLng> _positions = [];
  final MapController _mapController = MapController();
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionUpdater;
  StreamSubscription<Position>? _positionTracker;

  void updateButtons(bool start, bool pause, bool stop, bool resume) {
    setState(() {
      this.start = start;
      this.pause = pause;
      this.stop = stop;
      this.resume = resume;
    });
  }

  @override
  void dispose() {
    _positionUpdater?.cancel();
    _positionTracker?.cancel();
    super.dispose();
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
              child: FutureBuilder(
                  future: _initPosition(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Position position = snapshot.data!;
                      _currentPosition =
                          LatLng(position.latitude, position.longitude);
                      if(_positionUpdater == null) {
                        _positionStream = Geolocator.getPositionStream(
                            locationSettings: const LocationSettings(
                              accuracy: LocationAccuracy.best,
                              distanceFilter: 5,
                            ));
                        _positionUpdater = _positionStream!.listen(
                              (Position position) {
                            if (mounted) {
                              setState(() {
                                _currentPosition =
                                    LatLng(position.latitude, position.longitude);
                                _mapController.move(_currentPosition!, 18);
                              });
                            }
                          },
                        );
                        start = true;
                      }
                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _currentPosition,
                          zoom: 18,
                          maxZoom: 18.4,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          PolylineLayer(
                            polylineCulling: true,
                            polylines: [
                              Polyline(
                                points: _positions,
                                color: Colors.blue,
                                strokeWidth: 7,
                              )
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                // width: 50.0,
                                // height: 50.0,
                                point: _currentPosition!,
                                builder: (ctx) => const Icon(
                                  Icons.circle,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        "Something went wrong. Please try again later.",
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })),
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
                        fontSize: 30 * MediaQuery.of(context).textScaleFactor,
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
                        fontSize: 30 * MediaQuery.of(context).textScaleFactor,
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
              onStart: () {
                updateButtons(false, true, true, false);
                _positionTracker = _positionStream?.listen((Position position) {
                  _positions.add(LatLng(position.latitude, position.longitude));
                });
              },
              onStop: () {
                updateButtons(true, false, false, false);
                _positionTracker?.cancel();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position> _initPosition(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return Future.error(Exception('Missing permissions'));
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}

class _LowerButtonBar extends StatelessWidget {
  final bool start;
  final bool pause;
  final bool stop;
  final bool resume;
  final Function changeButtons;
  final Function onStart;
  final Function onStop;

  const _LowerButtonBar({
    required this.start,
    required this.pause,
    required this.stop,
    required this.resume,
    required this.changeButtons,
    required this.onStart,
    required this.onStop,
  });

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
                  onStart();
                },
                child: Text(
                  'START',
                  style: TextStyle(
                    fontSize: 20 * MediaQuery.of(context).textScaleFactor,
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
                    fontSize: 20 * MediaQuery.of(context).textScaleFactor,
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
                    fontSize: 20 * MediaQuery.of(context).textScaleFactor,
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
                  onStop();
                },
                child: Text(
                  'STOP',
                  style: TextStyle(
                    fontSize: 20 * MediaQuery.of(context).textScaleFactor,
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
