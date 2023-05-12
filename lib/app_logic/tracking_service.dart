import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TrackingService {
  static List<LatLng> positions = [];
  static double distance = 0;
  static Stream<Position>? positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ));

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration:
            AndroidConfiguration(onStart: onStart, isForegroundMode: true));
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    print("ON START ${positionStream}");
    DartPluginRegistrant.ensureInitialized();
    if (service is AndroidServiceInstance) {
      service.on("setAsForeground").listen((event) {
        print("SET AS FOREGROUND");
        service.setAsForegroundService();
      });

      service.on("stopService").listen((event) {
        service.stopSelf();
      });

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          print("Sono qui");
          service.setForegroundNotificationInfo(
              title: "Tracking session",
              content: "Ongoing session is being tracked.");
        }
      }
      // Stream<Position> positionStream = Geolocator.getPositionStream(
      //     locationSettings: const LocationSettings(
      //   accuracy: LocationAccuracy.best,
      //   distanceFilter: 5,
      // ));
      StreamSubscription<Position>? positionTracker =
          positionStream!.listen((Position position) {
        LatLng pos = LatLng(position.latitude, position.longitude);
        if (positions.isNotEmpty) {
          LatLng last = positions.last;
          distance += Geolocator.distanceBetween(
              last.latitude, last.longitude, pos.latitude, pos.longitude);
        }
        positions.add(pos);
        print("POSITIONS: $positions");
      });

      print("\n\n\n\n\n\n\n\n $positionStream");

      Timer.periodic(const Duration(seconds: 1), (timer) async {
        print("Foreground service running");
        service.invoke("update");
      });
    }
  }
}
