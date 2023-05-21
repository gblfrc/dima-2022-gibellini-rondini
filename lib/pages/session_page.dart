import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/model/proposal.dart';

import '../app_logic/auth.dart';

class SessionPage extends StatefulWidget {
  final Proposal? proposal;

  const SessionPage({this.proposal, super.key});

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
  double distance = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  List<List<LatLng>> _arrays = [];
  List<LatLng> _positions = [];
  DateTime? startDT;
  final MapController _mapController = MapController();
  Stream<Position>? positionStream;
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
                      if (_positionUpdater == null) {
                        positionStream = Geolocator.getPositionStream(
                            locationSettings: AndroidSettings(
                                accuracy: LocationAccuracy.best,
                                distanceFilter: 5,
                                foregroundNotificationConfig:
                                    const ForegroundNotificationConfig(
                                        notificationTitle:
                                            "Tracking in progress",
                                        notificationText:
                                            "Your position is being tracked.",
                                        notificationIcon: AndroidResource(
                                            name: 'launch_background',
                                            defType: 'drawable'))));
                        _positionUpdater = positionStream!.listen(
                          (Position position) {
                            if (mounted) {
                              setState(() {
                                _currentPosition = LatLng(
                                    position.latitude, position.longitude);
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
                              for (List<LatLng> posArray in _arrays)
                                Polyline(
                                  points: posArray,
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
                      "${(distance / 1000).toStringAsFixed(2)} km",
                      // toStringAsFixed sets the number of decimal positions
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
                      stopwatch.elapsed.toString().split('.').first,
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
              onStart: () async {
                _positions = [];
                _arrays = [];
                _arrays.add(_positions);
                updateButtons(false, true, true, false);
                distance = 0;
                //TrackingService.positions = _positions;
                //TrackingService.distance = distance;
                //await TrackingService.start();
                //FlutterBackgroundService().invoke("setAsForeground");
                _positionTracker = positionStream!.listen((Position position) {
                  LatLng pos = LatLng(position.latitude, position.longitude);
                  if (_positions.isNotEmpty) {
                    LatLng last = _positions.last;
                    distance += Geolocator.distanceBetween(last.latitude,
                        last.longitude, pos.latitude, pos.longitude);
                  }
                  _positions.add(pos);
                });
                stopwatch.reset();
                stopwatch.start();
                startDT = DateTime.now();
                timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
                  setState(() {
                    print(_positions);
                  });
                });
              },
              onStop: () {
                updateButtons(true, false, false, false);
                stopwatch.stop();
                timer?.cancel();
                _positionTracker?.cancel();
                //FlutterBackgroundService().invoke("stopService");
                saveSession();
              },
              onPause: () {
                updateButtons(false, false, true, true);
                stopwatch.stop();
                timer?.cancel();
                _positionTracker?.cancel();
              },
              onResume: () {
                updateButtons(false, true, true, false);
                _positions = [];
                _arrays.add(_positions);
                stopwatch.start();
                timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
                  setState(() {});
                });
                _positionTracker = positionStream?.listen((Position position) {
                  setState(() {
                    LatLng pos = LatLng(position.latitude, position.longitude);
                    if (_positions.isNotEmpty) {
                      LatLng last = _positions.last;
                      distance += Geolocator.distanceBetween(last.latitude,
                          last.longitude, pos.latitude, pos.longitude);
                    }
                    _positions.add(pos);
                  });
                });
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

  Future<void> saveSession() async {
    try {
      List<Map<String, List<GeoPoint>>> maps = [];
      for (List<LatLng> array in _arrays) {
        List<GeoPoint> geopoints = [];
        for (LatLng position in array) {
          geopoints.add(GeoPoint(position.latitude, position.longitude));
        }
        Map<String, List<GeoPoint>> map = {"values": geopoints};
        maps.add(map);
      }
      final docUser = FirebaseFirestore.instance
          .collection("users")
          .doc(Auth().currentUser!.uid);
      await FirebaseFirestore.instance.collection('sessions').doc().set({
        "userID": docUser,
        "distance": distance,
        "startDT": Timestamp.fromDate(startDT!),
        "duration": stopwatch.elapsedMilliseconds / 1000,
        "positions": maps,
        "proposal": widget.proposal != null
            ? FirebaseFirestore.instance
                .collection("proposals")
                .doc(widget.proposal!.id)
            : null
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Session saved!')));
        Navigator.of(context).pop();
      }
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Something went wrong when saving the session.')));
    }
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
  final Function onPause;
  final Function onResume;

  const _LowerButtonBar({
    required this.start,
    required this.pause,
    required this.stop,
    required this.resume,
    required this.changeButtons,
    required this.onStart,
    required this.onStop,
    required this.onPause,
    required this.onResume,
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
                  onPause();
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
                  onResume();
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
