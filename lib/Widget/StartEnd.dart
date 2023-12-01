import 'package:inventory/shared pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:inventory/Model/polygon.dart';
import 'package:inventory/Getx/maps.dart';
import 'package:inventory/Getx/timer.dart';
import 'package:inventory/Service/Repository.dart';


class StartController extends GetxController {
  var start = true.obs;

  void toggleStart() {
    start.toggle();
  }

  // Function to load start value from SharedPreferences
  Future<void> loadStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    start.value = prefs.getBool('start') ?? true; // Default to true if not found
    print(prefs.getBool('start'));
  }

  // Function to save start value to SharedPreferences
  Future<void> saveStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('start', start.value);
  }
}

class StartActionButton extends StatelessWidget {
  final StartController _startController = Get.find<StartController>();
  final CountdownController _countdownController = Get.find<CountdownController>();


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0,bottom: 24), // Increase padding for a larger button
        child: ElevatedButton.icon(
          onPressed: () async {
            await _startController.loadStart();
            if (_startController.start.value) {
              // If start is true, open map
              try {
                List<PolygonModel> varia = await repository.fetchPolygons();
                await storeData(varia.map((polygon) => polygon.toJson()).toList());
                streetBloc.fetchStreetsByPolygon(varia[0].polygonId);
                _countdownController.remainingTime.value = Duration(minutes: varia[0].timer);
                _countdownController.startTimer();

                _startController.toggleStart();
                // Save the updated start value to SharedPreferences
                await _startController.saveStart();
              } catch (e) {
                print(e);
              }
            } else {
              _startController.toggleStart();
               await deleteStoredData();

              // Save the updated start value to SharedPreferences
              await _startController.saveStart();
               _countdownController.remainingTime.value = Duration(minutes: 0);

              // Your custom action when start is false
            }

            // Toggle the state of start using GetX controller
          },
          icon: _startController.start.value
              ? Icon(Icons.location_on, size: 36.0)  // Use this icon when start is true, increase size to 36.0
              : Icon(Icons.location_off, size: 36.0),  // Use this icon when start is false, increase size to 36.0
          label: Text(
            _startController.start.value ? "Start" : "End",
            style: TextStyle(fontSize: 18.0), // Increase text size
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Increase border radius for rounded corners
            ),
          ),
        ),
      );
    });
  }
}
