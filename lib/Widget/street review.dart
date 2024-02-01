import 'package:flutter/material.dart';
import 'package:inventory/Model/Streets.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/euler.dart';
import 'package:inventory/Getx/maps.dart';
import 'package:inventory/Utility.dart';
import 'package:inventory/Widget/review.dart';

class StreetreviewController extends GetxController {
  var selectedStreetIndex = RxInt(-1); // -1 indicates no selection
  var streets = RxList<StreetModel>(); // List of all streets
  final EulerCircuit _eulerCircuit =
      Get.find<EulerCircuit>(); // Access EulerCircuit controller

  void setSelectedStreetIndex(int index) {
    selectedStreetIndex.value = index;
  }

  dynamic findSegment() {
    for (List<dynamic> segment in _eulerCircuit.eulerCircuit.value) {
      Map<String, dynamic> segmentInfo = segment[2];
      if (segmentInfo["id"] == selectedStreetIndex.value) {
        return segment[0];
      }
    }
  }

  void ChangeStreetIndex() {
    int currentSegmentIndex = _eulerCircuit.currentSegmentIndex.value;
    for (int i = currentSegmentIndex;
        i < currentSegmentIndex + 5 && i < _eulerCircuit.eulerCircuit.length;
        i++) {
      int streetId = _eulerCircuit.eulerCircuit[i][2]['id'];
      if (streetId == selectedStreetIndex.value) {
        _eulerCircuit.setCurrentSegmentIndex(i);
      }
    }
  }

  StreetModel? findStreetById(int searchId) {
    for (var street in streets) {
      if (street.streetId == searchId) {
        return street;
      }
    }
    return null;
  }

  void initializeStreets(List<StreetModel> streetData) {
    streets.assignAll(streetData);
  }

  void resetSelectedStreetIndex() {
    selectedStreetIndex.value = -1;
  }

  List<StreetModel> getVisibleStreets() {
    int currentSegmentIndex = _eulerCircuit.currentSegmentIndex.value;
    if (currentSegmentIndex < 0 ||
        currentSegmentIndex >= _eulerCircuit.eulerCircuit.length) return [];

    List<StreetModel> visibleStreets = [];

    // Loop through the Euler circuit starting from the current segment
    for (int i = currentSegmentIndex + 1;
        i < currentSegmentIndex + 7 && i < _eulerCircuit.eulerCircuit.length;
        i++) {
      int streetId = _eulerCircuit.eulerCircuit[i][2]['id'];
      StreetModel? street = findStreetById(streetId);
      if (street != null && !visibleStreets.contains(street)) {
        visibleStreets.add(street);
      }
    }
    return visibleStreets;
  }
}

class StreetItemWidget extends StatelessWidget {
  final StreetModel street;
  final VoidCallback onDelete;
  final VoidCallback onNavigate;
  final bool isSelected;
  final IconData deleteIcon; // New parameter for delete icon

  StreetItemWidget({
    Key? key,
    required this.street,
    required this.onDelete,
    required this.onNavigate,
    this.isSelected = false,
    this.deleteIcon = Icons.delete, // Default icon
  }) : super(key: key);

  final StreetreviewController _controller = Get.find<StreetreviewController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _controller.setSelectedStreetIndex(street.streetId!);
      },
      child: Card(
        child: ListTile(
          title: Text(
            "ID: ${street.streetId}",
            style: TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.directions, size: 20),
                onPressed: onNavigate,
              ),
              IconButton(
                icon: Icon(deleteIcon, size: 20), // Use the passed icon data
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class StreetListView extends StatelessWidget {
  final StreetreviewController _controller = Get.find<StreetreviewController>();
  final LocationController _locationController = Get.find<LocationController>();
  final EulerCircuit _eulerCircuit = Get.find<EulerCircuit>(); // Access EulerCircuit controller

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var streets = _controller.getVisibleStreets();
      return Container(
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width * 0.15,
        child: ListView.builder(
          itemCount: streets.length + 1, // +1 for the reset option
          itemBuilder: (context, index) {
            if (index == 0) {
              // Reset tile
              return Container(
                color: Colors.white,
                child: ListTile(
                  title: Text('Reset Selection', style: TextStyle(fontSize: 14)),
                  leading: Icon(Icons.refresh),
                  onTap: () => _controller.resetSelectedStreetIndex(),
                ),
              );
            } else {
              final street = streets[index - 1];
              bool isSelected = (index - 1) == _controller.selectedStreetIndex.value;

              // Determine if it's the second tile
              if (index == 1) {
                // Specific logic for the first street item
                return StreetItemWidget(
                  street: street,
                  onDelete: () => deleteFirstStreet(street),
                  onNavigate: () => navigateToStreet(),
                  isSelected: isSelected,
                  deleteIcon: Icons.delete_forever, // Specific icon for the first street item
                );
              } else {
                // General logic for other street items
                return StreetItemWidget(
                  street: street,
                  onDelete: () => deleteStreet(),
                  onNavigate: () => navigateToStreet(),
                  isSelected: isSelected,
                  deleteIcon: Icons.navigate_next_outlined, // Different icon for other street items
                );
              }
            }
          },
        ),
      );
    });
  }

  void navigateToStreet() {
    _controller.ChangeStreetIndex();
    _controller.resetSelectedStreetIndex();
  }

  void deleteFirstStreet(StreetModel street) {
    showReasonPopup();
    dynamic variable = _controller.findSegment();
    if (variable != null && variable.length > 1) {
      webOpenMapWithDirections(_locationController.currentLocation.value.latitude, _locationController.currentLocation.value.longitude, variable[0], variable[1]);
      _eulerCircuit.addCurrentSegmentIndex();
    } else {
      // Handle the case where variable is null or doesn't have the expected data
      print('Error: Segment data is unavailable.');
    }
  }

  void deleteStreet() {
    dynamic variable = _controller.findSegment();
    if (variable != null && variable.length > 1) {
      webOpenMapWithDirections(
          _locationController.currentLocation.value.latitude,
          _locationController.currentLocation.value.longitude, variable[0],
          variable[1]);
    }
    _controller.ChangeStreetIndex();
    _controller.resetSelectedStreetIndex();
  }
}


