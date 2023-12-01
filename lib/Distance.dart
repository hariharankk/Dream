import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';




double degreesToRadians(double degrees) {
  return degrees * pi / 180.0;
}

double distanceInMeters(LatLng point1, LatLng point2) {
  var earthRadius = 6371000.0; // Earth's radius in meters
  var dLat = degreesToRadians(point2.latitude - point1.latitude);
  var dLon = degreesToRadians(point2.longitude - point1.longitude);
  var lat1 = degreesToRadians(point1.latitude);
  var lat2 = degreesToRadians(point2.latitude);

  var a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double perpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
  double distStartEnd = distanceInMeters(lineStart, lineEnd);
  if (distStartEnd == 0) return distanceInMeters(point, lineStart);

  var u = ((point.latitude - lineStart.latitude) * (lineEnd.latitude - lineStart.latitude) +
      (point.longitude - lineStart.longitude) * (lineEnd.longitude - lineStart.longitude)) /
      (distStartEnd * distStartEnd);

  LatLng closestPoint;
  if (u < 0) {
    closestPoint = lineStart;
  } else if (u > 1) {
    closestPoint = lineEnd;
  } else {
    closestPoint = LatLng(lineStart.latitude + u * (lineEnd.latitude - lineStart.latitude),
        lineStart.longitude + u * (lineEnd.longitude - lineStart.longitude));
  }

  return distanceInMeters(point, closestPoint);
}

bool isPointNearLineSegment(LatLng point, LatLng start, LatLng end, double threshold) {
  return perpendicularDistance(point, start, end) <= threshold;
}

bool isOnSinglePolyline(LatLng currentPosition, List<LatLng> polylinePoints, double threshold) {
  for (int i = 0; i < polylinePoints.length - 1; i++) {
    if (isPointNearLineSegment(currentPosition, polylinePoints[i], polylinePoints[i + 1], threshold)) {
      return true;
    }
  }
  return false;
}


dynamic findCoordinatesById(dynamic data, int searchId) {
  for (int i = 0; i < data.length; i++) {
    var element = data[i];
    if (element.length > 2 && element[2]['id'] == searchId) {
      // Found the element with the matching id
      if (i + 1 < data.length) {
        // If there is a next element in the list
        var nextElement = data[i + 1];
        if (nextElement.length > 0) {
          // Assuming the next element also has coordinates
          return {'id':nextElement[2]['id'],
            'bearing':nextElement[2]['bearing']};
        }
      }
      break;
    }
  }
  print({'id': searchId, 'bearing': 0});
  return {'id': searchId, 'bearing': 0}; // Return null if no next element is found
}

dynamic findStreetById(List<dynamic> streetsData, int searchId) {
  for (var street in streetsData) {
    if (street.streetId == searchId) {
      return street; // Return the street model if the id matches
    }
  }
  return null; // Return null if no street with the given id is found
}

// Usage example


String distanceFromCurrentLocationToPolyline(LatLng currentLocation, List<LatLng> polylinePoints) {
  double minDistance = double.infinity;

  for (int i = 0; i < polylinePoints.length - 1; i++) {
    double distance = perpendicularDistance(currentLocation, polylinePoints[i], polylinePoints[i + 1]);

    if (distance < minDistance) {
      minDistance = distance;
    }
  }

  return "${minDistance.toStringAsFixed(2)} m";
}


Map<String, dynamic>? getClosestPolyline(LatLng currentPosition, dynamic streetsData, double threshold) {
  List<Map<String, dynamic>> polylinesWithinThreshold = [];

  // Collect polylines within the threshold
  for (var street in streetsData) {
    final List<LatLng> polylinePoints = street.streetCoordinates;
    if (isOnSinglePolyline(currentPosition, polylinePoints, threshold)) {
      polylinesWithinThreshold.add({
        'polylinePoints': polylinePoints,
        'streetId': street.streetId,
      });
    }
  }

  // If there's only one polyline within the threshold, return it
  if (polylinesWithinThreshold.length == 1) {
    return {
      'polyline': Polyline(
        points: polylinesWithinThreshold.first['polylinePoints'],
        strokeWidth: 4.0,
        color: Colors.red,
      ),
      'streetId': polylinesWithinThreshold.first['streetId']
    };
  }
  // If there are two or more polylines within the threshold, find the closest one
  else if (polylinesWithinThreshold.length >= 2) {
    double minDistance = double.infinity;
    Map<String, dynamic>? closestPolylineData;

    for (var polylineData in polylinesWithinThreshold) {
      final List<LatLng> polylinePoints = polylineData['polylinePoints'];
      int id = polylineData['streetId'];

      for (int i = 0; i < polylinePoints.length - 1; i++) {
        double currentDistance = perpendicularDistance(currentPosition, polylinePoints[i], polylinePoints[i + 1]);
        if (currentDistance < minDistance) {
          minDistance = currentDistance;
          closestPolylineData = {
            'polyline': Polyline(
              points: polylinePoints,
              strokeWidth: 4.0,
              color: Colors.black,
            ),
            'streetId': id
          };
        }
      }
    }
    return closestPolylineData;
  }

  // Return null if no polylines are within the threshold
  return null;
}
