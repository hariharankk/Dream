import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:inventory/Widget/jktdirection.dart';
import 'package:inventory/Getx/maps.dart'; // Import your LocationController
import 'package:inventory/Widget/timer.dart';
import 'package:inventory/Widget/navigation.dart';
import 'package:inventory/Getx/navigation.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Widget/StartEnd.dart';
import 'package:inventory/Getx/euler.dart';
import 'package:inventory/Getx/timer.dart';
// Usage example

class MapScreen extends StatelessWidget {
  final MapController _mapController = MapController();
  final LocationController _locationController =   Get.find<LocationController>(); // Use Get.find instead of Get.put
  final NavigationController _navigationController = Get.put(NavigationController());
  final CountdownController _countdownController = Get.put(CountdownController());

  final FlagController _flagController =
      Get.find<FlagController>(); // Initialize and put the FlagController
  final StartController _startController = Get.find<StartController>();
  void _zoomIn() {
    _mapController.move(
        _mapController.center, (_mapController.zoom ?? 13.0) + 1);
  }

  void _zoomOut() {
    _mapController.move(
        _mapController.center, (_mapController.zoom ?? 13.0) - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Obx(
            () {
              var currentLocation = _locationController.currentLocation.value;
              var currentbearing = _locationController.compassHeading.value;
              return StreamBuilder<dynamic>(
                stream: streetBloc.streetDataStream,
                // Replace with your location stream
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text('Waiting for location data...'));
                  }
                  List<Marker> streetMarkers = [];
                  // Get the current location from the snapshot
                  var streetsData = snapshot.data!['streets'];
                  var euler = snapshot.data!['eulerCircuit'];
                  List<Polyline> polylines = eulercircuit.generatePolylinesForCurrentAndNextSegments(euler, streetsData,currentLocation,currentbearing);




// Create a polyline with the points list
                  // Add the current location marker to the list
                  streetMarkers.add(Marker(
                    width: 80.0,
                    height: 80.0,
                    point: currentLocation,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red, // Color for current location marker
                      size: 30.0, // Size for current location marker
                    ),
                  ));

                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: currentLocation,
                      zoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: streetMarkers,
                      ),
                      PolylineLayer(polylines: polylines),
                    ],
                  );
                },
              );
            },
          ),
          Positioned(
            top: 40, // Distance from the top of the screen.
            left: 20, // Distance from the left side of the screen.
            child: NavigationInstructionWidget(),
          ),
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
            child: Center(child: CountdownTimerWidget()),
          ),
          Positioned(
            right: 20.0,
            top: 310.0,
            child: FloatingActionButton(
              onPressed: () async {
                _locationController.moveToCurrentLocation(_mapController);


// Later, when you need the data
              },
              child: Icon(Icons.my_location),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          Positioned(
            right: 20.0,
            top: 410.0,
            child: FloatingActionButton(
              onPressed: () {
                var streetsData = streetBloc.getstreetsObject()['streets'];
                var eulerCircuit =
                    streetBloc.getstreetsObject()['eulerCircuit'];

                Map<int, List<dynamic>> streetMap = _locationController
                    .createStreetIdToCoordinatesMap(streetsData);
                List<dynamic> fullPath = _locationController
                    .generateFullPathFromEulerCircuit(eulerCircuit, streetMap);

                _locationController.startSimulation(fullPath);

                // When the button is pressed, rotate the map to the current compass heading
              },
              child: Icon(Icons.compass_calibration_rounded),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          Positioned(
            right: 20.0,
            top: 210.0,
            child: FloatingActionButton(
              onPressed: () {
                // When the button is pressed, rotate the map to the current compass heading
                var targetRotation =
                    _locationController.compassHeading.value % 360;
                _mapController.rotate(targetRotation);
              },
              child: Icon(Icons.compass_calibration_rounded),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
/*          Positioned(
            right: 20.0,
            top: 410.0,
            child: FloatingActionButton(
              onPressed: () async{

                List<Map<String, dynamic>> retrievedData = await retrieveData();
                retrievedData.removeAt(0);
                PolygonModel firstPolygon = PolygonModel.fromJson(retrievedData[0]);
                webOpenMapWithDirections(_locationController.currentLocation.value.latitude,_locationController.currentLocation.value.longitude,firstPolygon.navigatingCoordinateEnd.longitude,firstPolygon.navigatingCoordinateEnd.latitude);
                //openMapWithDirections(_locationController.currentLocation.value.latitude,_locationController.currentLocation.value.longitude,firstPolygon.navigatingCoordinateEnd.latitude,firstPolygon.navigatingCoordinateEnd.latitude);
                streetBloc.fetchStreetsByPolygon(firstPolygon.polygonId);
                await storeData(retrievedData);
                _countdownController.remainingTime.value = Duration(minutes: firstPolygon.timer);
                _countdownController.startTimer();

              },
              child: Icon(Icons.navigate_next),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),*/

// Usage in your main widget
          Positioned(right: 20.0, top: 110.0, child: FlagActionButton()),
          Positioned(right: 20.0, top: 10.0, child: StartActionButton()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _zoomIn(),
            mini: true,
            child: Icon(Icons.add),
            heroTag: 'zoom-in',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _zoomOut(),
            mini: true,
            child: Icon(Icons.remove),
            heroTag: 'zoom-out',
          ),
          // Other FABs...
        ],
      ),
    );
  }
}