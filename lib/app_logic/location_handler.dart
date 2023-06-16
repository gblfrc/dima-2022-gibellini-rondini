import 'package:geolocator/geolocator.dart';

/*
* This class aims at being a singleton interface to allow the application to interact with positions.
* It also works as a wrapper for the Geolocator methods to allow their mocking in the testing phase.
*/
class LocationHandler {
  // Instance of the LocationHandler
  static final LocationHandler _instance = LocationHandler._internal();

  // Factory method for the singleton class
  factory LocationHandler() {
    return _instance;
  }

  // Internal constructor of the singleton class; called once to initialize the instance
  LocationHandler._internal();

  /*
  * Function to check if the user has given the application permission to use the location
  * services. If the user hasn't, asks for permission. If the user still denies the permission,
  * return false. If, at any point, permission is given, returns true
  */
  Future<bool> _checkAndObtainPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  /*
  * This method provides the user with the device's current position. It returns such position
  * only in case the location information can be accessed, i.e. the user has given permission to
  * the application to access the location services and the services themselves have been enabled.
  * In case any of these conditions is not satisfied, the user is offered the possibility to solve
  * the issue by either providing permission or enabling the location services. If the user still
  * refuses to give access to the location information, an error Future is returned.
  *
  * Opportunity to enable location services is provided directly by the Geolocator function.
  */
  Future<Position> getCurrentPosition() async {
    // check permissions
    var hasPermission = await _checkAndObtainPermission();
    if (!hasPermission) return Future.error(const PermissionDeniedException('Permission to access location services is denied.'));
    // return current position (location services should be enabled at this point)
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /*
  * Method to obtain the stream of positions. This method is simply a wrapper around the homonym
  * from the Geolocator package. Introduced mostly to allow mocks in testing phases.
  */
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    // return current position (location services should be enabled at this point)
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
