import 'dart:math';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:inventory/Model/Streets.dart';
import 'package:inventory/Getx/navigation.dart';

class EulerCircuit extends GetxController {
  var currentSegmentIndex = RxInt(0); // Reactive integer
  var eulerCircuit = RxList<dynamic>(); // Reactive list
  var thresholdDistance = RxDouble(10.0); // Reactive double
  final NavigationController _navigationController = Get.find<NavigationController>();



  void initializeEulerCircuit(List<dynamic> circuitData) {
    eulerCircuit.assignAll(circuitData);
  }

  void setCurrentSegmentIndex(int newIndex) {
    if (newIndex >= 0 && newIndex < eulerCircuit.length) {
      currentSegmentIndex.value = newIndex;
    } else {
      print("Invalid index: $newIndex");
    }
  }



  void addCurrentSegmentIndex() {
    if (currentSegmentIndex.value + 1 < eulerCircuit.length) {
      currentSegmentIndex.value++;
    } else {
      print("out of bounds");
    }
  }


  StreetModel? findStreetById(List<StreetModel> streets, int searchId) {
    for (var street in streets) {
      if (street.streetId == searchId) {
        return street;
      }
    }
    return null;
  }

  void updateLocation(LatLng currentLocation) {
    if (currentSegmentIndex.value >= eulerCircuit.length) {
      print("Euler circuit completed");
      return;
    }

    var currentSegment = eulerCircuit[currentSegmentIndex.value];
    double distanceToEnd = distanceInMeters(currentLocation, LatLng(currentSegment[1][0], currentSegment[1][1]));

    if (distanceToEnd <= thresholdDistance.value) {
      currentSegmentIndex.value++;
    }
  }

  double distanceInMeters(LatLng point1, LatLng point2) {
    var earthRadius = 6371000.0; // Earth's radius in meters
    var dLat = _degreesToRadians(point2.latitude - point1.latitude);
    var dLon = _degreesToRadians(point2.longitude - point1.longitude);
    var lat1 = _degreesToRadians(point1.latitude);
    var lat2 = _degreesToRadians(point2.latitude);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
            sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  List<Polyline> generatePolylinesForCurrentAndNextSegments(List<dynamic> euler, List<StreetModel> streets, LatLng currentLocation, double currentbearing, int neededstreetid) {
    List<Polyline> polylines = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int selectedStreetId = neededstreetid;
      initializeEulerCircuit(euler);
      updateLocation(currentLocation);

      // Map streets to Polylines
      polylines.addAll(_generateStreetPolylines(streets));

      // Handle current and next street segments
      _handleStreetSegments(euler, streets, polylines, currentbearing, currentLocation, selectedStreetId);
    });
    return polylines;
  }

  List<Polyline> _generateStreetPolylines(List<StreetModel> streets) {
    return streets.map<Polyline>((street) => Polyline(
      points: street.streetCoordinates,
      strokeWidth: 4.0,
      color: Colors.lightBlueAccent,
    )).toList();
  }

  void _handleStreetSegments(List<dynamic> euler, List<StreetModel> streets, List<Polyline> polylines, double currentbearing, LatLng currentLocation, int selectedStreetId) {
    if (currentSegmentIndex.value < euler.length) {
      _addStreetPolyline(streets, euler[currentSegmentIndex.value][2]['id'], polylines, Colors.black);

      if (currentSegmentIndex.value < euler.length - 1) {
        _addStreetPolyline(streets, euler[currentSegmentIndex.value + 1][2]['id'], polylines, Colors.red);
      }

      if (currentSegmentIndex.value+1 < euler.length) {
        var currentSegment = euler[currentSegmentIndex.value + 1];
        _navigationController.direction.value = determineStreetDirection(
            currentSegment[2]['bearing'], currentbearing);
        _navigationController.distance.value =
            distanceFromCurrentLocationToPolyline(currentLocation,
                LatLng(currentSegment[1][0], currentSegment[1][1]));
      }
    }

    if (selectedStreetId >= 0) {
      _addStreetPolyline(streets, selectedStreetId, polylines, Colors.green);
    }
  }

  void _addStreetPolyline(List<StreetModel> streets, int streetId, List<Polyline> polylines, Color color) {
    StreetModel? street = findStreetById(streets, streetId);
    if (street != null) {
      polylines.add(Polyline(
        points: street.streetCoordinates,
        strokeWidth: 4.0,
        color: color,
      ));
    }
  }

  String determineStreetDirection(double streetBearing, double currentHeading) {
    int relativeAngle = ((streetBearing - currentHeading) % 360).round();
    if (relativeAngle > 180) {
      relativeAngle -= 360;
    } else if (relativeAngle < -180) {
      relativeAngle += 360;
    }

    // Define the direction based on the relative angle
    if (relativeAngle >= -45 && relativeAngle <= 45) {
      return "straight";
    } else if (relativeAngle > 45 && relativeAngle < 135) {
      return "right";
    } else if (relativeAngle >= 135 || relativeAngle <= -135) {
      return "uturn";
    } else if (relativeAngle < -45 && relativeAngle > -135) {
      return "left";
    } else {
      return "unknown";
    }
  }

  String distanceFromCurrentLocationToPolyline(LatLng currentLocation, LatLng endPoint) {
    double distance = distanceInMeters(currentLocation, endPoint);
    return "${distance.toStringAsFixed(2)} m";
  }
}
