import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:inventory/shared pref.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Utility.dart';
import 'package:inventory/Model/polygon.dart';
import 'package:inventory/Getx/maps.dart';
import 'package:inventory/Widget/jktdirection.dart';

class CountdownController extends GetxController {
  Rx<Duration> remainingTime = Duration(minutes: 0).obs;
  Timer? _timer;
  final LocationController _locationController =   Get.find<LocationController>(); // Use Get.find instead of Get.put
  final FlagController _flagController = Get.find<FlagController>();

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (remainingTime.value.inSeconds > 0) {
        remainingTime.value = remainingTime.value - Duration(seconds: 1);
        remainingTime.refresh(); // This replaces setState
      } else {
        _timer?.cancel();
        var check = await isDataStored();
        if (check && _flagController.flag.value) {
          _showNextStepDialog();
        }
      }
    });
  }


  void _showNextStepDialog() {
    Get.dialog(AlertDialog(
      title: Text('Time’s up!'),
      content: Text('Would you like to add 10 more minutes?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            List<Map<String, dynamic>> retrievedData = await retrieveData();
            retrievedData.removeAt(0);
            PolygonModel firstPolygon = PolygonModel.fromJson(retrievedData[0]);
            webOpenMapWithDirections(_locationController.currentLocation.value.latitude,_locationController.currentLocation.value.longitude,firstPolygon.navigatingCoordinateEnd.longitude,firstPolygon.navigatingCoordinateEnd.latitude);
            //openMapWithDirections(_locationController.currentLocation.value.latitude,_locationController.currentLocation.value.longitude,firstPolygon.navigatingCoordinateEnd.latitude,firstPolygon.navigatingCoordinateEnd.latitude);
            streetBloc.fetchStreetsByPolygon(firstPolygon.polygonId);
            await storeData(retrievedData);
            remainingTime.value = Duration(minutes: firstPolygon.timer);
            startTimer();
            Get.back();
            },
          child: Text('Next Village'),
        ),
        TextButton(
          onPressed: () {
            remainingTime.value = Duration(minutes: 10);
            startTimer();
            Get.back();
          },
          child: Text('Add 10 minutes'),
        ),
      ],
    ));
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
