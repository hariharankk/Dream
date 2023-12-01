import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Observable properties
  var direction = 'straight'.obs;
  var streetName = 'Initial Street'.obs;
  var distance = '100 m'.obs;

  // Update navigation data
  void updateNavigation(String newDirection, String newStreetName, String newDistance) {
    direction.value = newDirection;
    streetName.value = newStreetName;
    distance.value = newDistance;
  }


}
