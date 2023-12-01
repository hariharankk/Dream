import 'package:inventory/shared pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Utility.dart';
import 'package:inventory/Model/polygon.dart';
import 'package:inventory/Getx/maps.dart';
import 'package:inventory/Getx/timer.dart';


class FlagController extends GetxController {
  var flag = true.obs;

  void toggleFlag() {
    flag.toggle();
  }

  // Function to load flag value from SharedPreferences
  Future<void> loadFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    flag.value = prefs.getBool('flag') ?? true; // Default to true if not found
    print(prefs.getBool('flag'));
  }

  // Function to save flag value to SharedPreferences
  Future<void> saveFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flag', flag.value);
  }
}

class FlagActionButton extends StatelessWidget {
  final FlagController _flagController = Get.find<FlagController>();
  final LocationController _locationController = Get.find<LocationController>();
  final CountdownController _countdownController = Get.find<CountdownController>();


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FloatingActionButton(
        onPressed: () async {
          await _flagController.loadFlag();
          if (_flagController.flag.value) {
            // If flag is true, open map
            try {

              _countdownController.remainingTime.value = Duration(minutes: 0);
              double startLat = _locationController.currentLocation.value.latitude;
              double startLng = _locationController.currentLocation.value.longitude;
              double destLat = COMPANY_LOCATION.latitude;
              double destLng = COMPANY_LOCATION.longitude;
              await openMapWithDirections(startLat, startLng, destLat, destLng);
              await webOpenMapWithDirections(startLat, startLng, destLat, destLng);
               // Save the updated flag value to SharedPreferences
              _flagController.toggleFlag();

              await _flagController.saveFlag();


            } catch (e) {
              print(e);
            }
          } else {
            // If flag is false, execute your custom action
            List<Map<String, dynamic>> retrievedData = await retrieveData();
            PolygonModel firstPolygon = PolygonModel.fromJson(retrievedData[0]);
            double startLat = _locationController.currentLocation.value.latitude;
            double startLng = _locationController.currentLocation.value.longitude;
            double destLat = firstPolygon.navigatingCoordinateStart.longitude;
            double destLng = firstPolygon.navigatingCoordinateStart.latitude;

            try {
              await openMapWithDirections(startLat, startLng, destLat, destLng);
              await webOpenMapWithDirections(startLat, startLng, destLat, destLng);
            } catch (e) {
              // Handle any errors for map-related actions
            }



            _flagController.toggleFlag();

            // Save the updated flag value to SharedPreferences
            await _flagController.saveFlag();
            _countdownController.remainingTime.value = Duration(minutes: firstPolygon.timer);
            _countdownController.startTimer();
            // Your custom action when flag is false
          }

          // Toggle the state of flag using GetX controller
        },
        child: _flagController.flag.value
            ? Icon(Icons.home)  // Use this icon when flag is true
            : Icon(Icons.food_bank_outlined),  // Use this icon when flag is false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    });
  }
}
