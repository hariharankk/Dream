import 'dart:math';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:inventory/Model/Streets.dart';
import 'package:inventory/Getx/navigation.dart';

class EulerCircuit{
  var currentSegmentIndex = 0;
  var eulerCircuit = [];
  double thresholdDistance = 10.0;
  final NavigationController _navigationController = Get.find<NavigationController>();



  void initializeEulerCircuit(List circuitData) {
    eulerCircuit.addAll(circuitData);

  }

  StreetModel? findStreetById(List<StreetModel> streets, int searchId) {
    for (var street in streets) {
      if (street.streetId == searchId) {
        return street; // Return the street if the id matches
      }
    }
    return null; // Return null if no street with the given id is found
  }

  void updateLocation(LatLng currentLocation) {
    if (currentSegmentIndex >= eulerCircuit.length) {
      print("Euler circuit completed");
      return;
    }

    var currentSegment = eulerCircuit[currentSegmentIndex];

    double distanceToEnd = distanceInMeters(currentLocation, LatLng(currentSegment[1][0], currentSegment[1][1]));

    if (distanceToEnd <= thresholdDistance) {
      currentSegmentIndex++;
    }
  }

  String distanceFromCurrentLocationToPolyline(LatLng currentLocation, LatLng endPoint) {
    double distance = distanceInMeters(currentLocation, endPoint);
    return "${distance.toStringAsFixed(2)} m"; // Format the distance with two decimal places
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

  List<Polyline> generatePolylinesForCurrentAndNextSegments(var euler, List<StreetModel> streets , LatLng currentLocation, var currentbearing) {
    List<Polyline> polylines = [];
    initializeEulerCircuit(euler);
    updateLocation(currentLocation);
    polylines.addAll(streets.map<Polyline>((street) {
      return Polyline(
        points: street.streetCoordinates,
        strokeWidth: 4.0,
        color: Colors.lightBlueAccent,
      );
    }).toList());

    if (currentSegmentIndex < eulerCircuit.length) {
      StreetModel? currentStreet = findStreetById(streets, eulerCircuit[currentSegmentIndex][2]['id']);
      if (currentStreet != null) {
        polylines.add(Polyline(
          points: currentStreet.streetCoordinates,
          strokeWidth: 4.0,
          color: Colors.black,
        ));
      }

      if (currentSegmentIndex < eulerCircuit.length - 1) {
        StreetModel? nextStreet = findStreetById(streets, eulerCircuit[currentSegmentIndex + 1][2]['id']);
        if (nextStreet != null) {
          polylines.add(Polyline(
            points: nextStreet.streetCoordinates,
            strokeWidth: 4.0,
            color: Colors.red,
          ));
        }
      }
    }
    //print(eulerCircuit);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentSegmentIndex < eulerCircuit.length) {
        var currentSegment = eulerCircuit[currentSegmentIndex];
        _navigationController.direction.value = determineStreetDirection(
            currentSegment[2]['bearing'], currentbearing);

        _navigationController.distance.value = distanceFromCurrentLocationToPolyline(
            currentLocation, LatLng(currentSegment[1][0], currentSegment[1][1]));
      }
    });
    return polylines;
  }


  String determineStreetDirection(double streetBearing, double currentHeading) {
    int relativeAngle = ((streetBearing - currentHeading) % 360).round();

    // Normalize the angle to be between -180 and 180
    if (relativeAngle > 180) {
      relativeAngle -= 360;
    } else if (relativeAngle < -180) {
      relativeAngle += 360;
    }

    // Interpret the relative angle
    if (relativeAngle > -30 && relativeAngle < 30) {
      return "straight"; // Matches the case in your switch statement
    } else if (relativeAngle >= 30 && relativeAngle <= 180) {
      return "left";    // Matches the case in your switch statement
    } else if (relativeAngle <= -30 && relativeAngle >= -180) {
      return "right";   // Matches the case in your switch statement
    } else {
      return "uturn";   // Matches the case in your switch statement
    }
  }

}


EulerCircuit eulercircuit = EulerCircuit();