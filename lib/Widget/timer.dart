import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:inventory/Getx/timer.dart';
import 'package:inventory/Model/polygon.dart';
import 'package:inventory/shared pref.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Getx/euler.dart';
import 'package:inventory/Getx/maps.dart';

class CountdownTimerWidget extends StatelessWidget {
  final CountdownController _controller = Get.find<CountdownController>();
  final CountdownController _countdownController = Get.find<CountdownController>();
  final EulerCircuit _eulerCircuit = Get.find<EulerCircuit>();
  final LocationController _locationController =   Get.find<LocationController>(); // Use Get.find instead of Get.put

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Village done'),
          content: Text('Are you sure you want to move to the next Village?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                List<Map<String, dynamic>> retrievedData = await retrieveData();
                if (retrievedData.isNotEmpty) {
                  retrievedData.removeAt(0);
                  PolygonModel firstPolygon = PolygonModel.fromJson(retrievedData[0]);
                  streetBloc.fetchStreetsByPolygon(firstPolygon.polygonId);
                  //webOpenMapWithDirections(_locationController.currentLocation.value.latitude,_locationController.currentLocation.value.longitude,firstPolygon.navigatingCoordinateEnd.longitude,firstPolygon.navigatingCoordinateEnd.latitude);
                  //openMapWithDirections(_locationController.currentLocation.value.latitude,_locationController.currentLocation.value.longitude,firstPolygon.navigatingCoordinateEnd.latitude,firstPolygon.navigatingCoordinateEnd.latitude);
                  await storeData(retrievedData);
                  _countdownController.remainingTime.value = Duration(minutes: firstPolygon.timer);
                  _countdownController.startTimer();
                  _eulerCircuit.setCurrentSegmentIndex(0);
                }
                Get.back();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDialog(context); // Show the dialog on tap
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.timer, color: Colors.blue),
            SizedBox(width: 10),
            Obx(() {
              final hours = _controller.twoDigits(_controller.remainingTime.value.inHours);
              final minutes = _controller.twoDigits(_controller.remainingTime.value.inMinutes.remainder(60));
              final seconds = _controller.twoDigits(_controller.remainingTime.value.inSeconds.remainder(60));
              return Text(
                '$hours:$minutes:$seconds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
