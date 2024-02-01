import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMarker extends StatelessWidget {
  final LatLng currentLocation;

  LocationMarker({Key? key, required this.currentLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Marker marker = Marker(
      width: 80.0,
      height: 80.0,
      point: currentLocation,
      child:  Icon(
        Icons.location_pin,
        color: Colors.red,
        size: 30.0,
      ),
    );

    return MarkerLayer(markers: [marker]);
  }
}
