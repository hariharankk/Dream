import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/navigation.dart'; // Import your NavigationController

class NavigationInstructionWidget extends StatelessWidget {
  // Access the controller
  final NavigationController navigationController = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Align(
        alignment: Alignment.topCenter,
        child: Card(
          color: Colors.green, // Set the background color to green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
          child: Container(
            width: MediaQuery.of(context).size.width / 5, // Set the width to 1/3 of screen width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    _getDirectionIcon(navigationController.direction.value),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getDirectionText(navigationController.direction.value),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8), // Spacing between direction text and street name
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    navigationController.streetName.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${navigationController.distance.value}', // Short for meters
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  IconData _getDirectionIcon(String direction) {
    switch (direction) {
      case 'left':
        return Icons.turn_left_sharp;
      case 'right':
        return Icons.turn_right_sharp;
      case 'straight':
        return Icons.arrow_upward;
      case 'uturn':
        return Icons.u_turn_left; // Assuming you have an icon for U-turn
      default:
        return Icons.error_outline; // Default case for an unrecognized direction
    }
  }

  String _getDirectionText(String direction) {
    switch (direction) {
      case 'left':
        return 'Turn Left';
      case 'right':
        return 'Turn Right';
      case 'straight':
        return 'Go Straight';
      case 'uturn':
        return 'Make U-Turn';
      default:
        return 'Unknown'; // Default case for an unrecognized direction
    }
  }

}
