import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:progetto/app_logic/location_handler.dart';
import 'package:progetto/model/proposal.dart';

import '../app_logic/auth.dart';
import '../app_logic/database.dart';
import '../constants.dart';

class SessionPage extends StatefulWidget {
  final Proposal? proposal;
  final LocationHandler locationHandler;
  final Database database;
  final Auth auth;

  const SessionPage(
      {this.proposal, super.key, required this.locationHandler, required this.database, required this.auth});

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
  bool? _isInitialized;

  @override
  void initState() {
    widget.locationHandler.getCurrentPosition().then((value) {
      Position position = value;
      _currentPosition = LatLng(position.latitude, position.longitude);
      if (_positionUpdater == null) {
        positionStream = widget.locationHandler
            .getPositionStream(
                locationSettings: AndroidSettings(
                    accuracy: LocationAccuracy.best,
                    distanceFilter: 5,
                    foregroundNotificationConfig: const ForegroundNotificationConfig(
                        notificationTitle: "Tracking in progress",
                        notificationText: "Your position is being tracked.",
                        notificationIcon: AndroidResource(name: 'launch_background', defType: 'drawable'))))
            .asBroadcastStream();
        _positionUpdater = positionStream!.listen(
          (Position position) {
            if (mounted) {
              setState(() {
                _currentPosition = LatLng(position.latitude, position.longitude);
                try {
                  _mapController.move(_currentPosition!, 18);
                } on Error {
                  // the first time a position is detected, the map controller might incur a
                  // late initialization error
                }
              });
            }
          },
        );
        setState(() {
          _isInitialized = true;
          start = true;
        });
      }
    }, onError: (error, stackTrace) {
      setState(() {
        _isInitialized = false;
      });
    });

    super.initState();
  }

  void updateButtons({bool start = false, bool pause = false, bool stop = false, bool resume = false}) {
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

  Widget map() {
    return _isInitialized != null
        ? (_isInitialized!
            ? FlutterMap(
                key: const Key('SessionPageMap'),
                mapController: _mapController,
                options: MapOptions(
                  center: _currentPosition,
                  zoom: 18,
                  maxZoom: 18.4,
                ),
                children: [
                  TileLayer(
                    urlTemplate: mapUrl,
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylineCulling: true,
                    polylines: [
                      for (List<LatLng> posArray in _arrays)
                        Polyline(
                          points: posArray,
                          color: Theme.of(context).primaryColor,
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
                        builder: (ctx) => Icon(
                          Icons.circle,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : const Center(
                key: Key('SessionPageErrorOnPositionText'),
                child: Text(
                  "Something went wrong when obtaining position information. Please try again later.",
                  textAlign: TextAlign.center,
                ),
              ))
        : const Center(child: CircularProgressIndicator());
  }

  List<Widget> timeAndDistance() {
    return [
      Flexible(
        key: const Key('SessionPageDistanceInfo'),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  distance < 1000 ? "${distance.round()} m" : "${(distance / 1000).toStringAsFixed(2)} km",
                  // toStringAsFixed sets the number of decimal positions
                  style: TextStyle(
                    height: 0,
                    fontSize: 30 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'DISTANCE',
                  style: TextStyle(
                      height: 0,
                      //used to remove default padding
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).textScaleFactor * 13),
                ),
              ),
            ],
          ),
        ),
      ),
      Flexible(
        key: const Key('SessionPageDurationInfo'),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  stopwatch.elapsed < const Duration(hours: 1)
                      ? "${stopwatch.elapsed.inMinutes.remainder(60).toString().padLeft(2, "0")}:${stopwatch.elapsed.inSeconds.remainder(60).toString().padLeft(2, "0")}"
                      : "${stopwatch.elapsed.inHours}:${stopwatch.elapsed.inMinutes.remainder(60).toString().padLeft(2, "0")}:${stopwatch.elapsed.inSeconds.remainder(60).toString().padLeft(2, "0")}",
                  // toStringAsFixed sets the number of decimal positions
                  style: TextStyle(
                    height: 0,
                    fontSize: 30 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'DURATION',
                  style: TextStyle(
                      height: 0,
                      //used to remove default padding
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).textScaleFactor * 13),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> buttons() {
    return [
      if (start)
        Flexible(
          key: const Key('SessionPageStartButton'),
          child: Center(
            child: FilledButton(
              onPressed: () async {
                _positions = [];
                _arrays = [];
                _arrays.add(_positions);
                updateButtons(pause: true, stop: true);
                distance = 0;
                _positionTracker = positionStream!.listen((Position position) {
                  LatLng pos = LatLng(position.latitude, position.longitude);
                  if (_positions.isNotEmpty) {
                    LatLng last = _positions.last;
                    distance += Geolocator.distanceBetween(last.latitude, last.longitude, pos.latitude, pos.longitude);
                  }
                  _positions.add(pos);
                });
                stopwatch.reset();
                stopwatch.start();
                startDT = DateTime.now();
                timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
                  setState(() {});
                });
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
          key: const Key('SessionPagePauseButton'),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                updateButtons(resume: true, stop: true);
                stopwatch.stop();
                timer?.cancel();
                _positionTracker?.cancel();
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
          key: const Key('SessionPageResumeButton'),
          child: Center(
            child: FilledButton(
              onPressed: () {
                updateButtons(stop: true, pause: true);
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
                      distance +=
                          Geolocator.distanceBetween(last.latitude, last.longitude, pos.latitude, pos.longitude);
                    }
                    _positions.add(pos);
                  });
                });
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
          key: const Key('SessionPageStopButton'),
          child: Center(
            child: FilledButton(
              onPressed: () async {
                updateButtons(start: true);
                stopwatch.stop();
                timer?.cancel();
                _positionTracker?.cancel();
                //FlutterBackgroundService().invoke("stopService");
                try {
                  await widget.database.saveSession(
                      uid: widget.auth.currentUser!.uid,
                      positions: _arrays,
                      distance: distance,
                      duration: stopwatch.elapsedMilliseconds / 1000,
                      startDT: startDT!,
                      proposalId: widget.proposal != null ? widget.proposal!.id : null);
                } on Exception {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('An error occurred when saving the session.')));
                }
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Session saved successfully!')));
                }
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    Axis direction = MediaQuery.of(context).orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical;
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    double tabletContainerWidth = MediaQuery.of(context).size.shortestSide / 3.4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
      ),
      body: !isTablet
          ? Column(
              key: const Key('SessionPagePhoneLayout'),
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      map(),
                      if (direction == Axis.vertical)
                        Align(
                          alignment: Alignment.bottomCenter,
                          // child: buttonBar(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width / 6.5,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: buttons(),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                SizedBox(
                  key: const Key('SessionPagePhoneInfoBox'),
                  height: MediaQuery.of(context).size.shortestSide / 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: timeAndDistance()..addAll(direction == Axis.horizontal ? buttons() : []),
                  ),
                ),
              ],
            )
          : Stack(
              key: const Key('SessionPageTabletLayout'),
              children: [
                map(),
                Align(
                  key: const Key('SessionPageTabletInfoBox'),
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: EdgeInsets.all(tabletContainerWidth / 8),
                    height: tabletContainerWidth,
                    width: tabletContainerWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(tabletContainerWidth / 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: const Offset(2.0, 2.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: Column(
                      children: timeAndDistance()..addAll(buttons()),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
