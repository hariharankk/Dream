import 'package:flutter/material.dart';
import 'package:inventory/Model/Streets.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/euler.dart';

class StreetreviewController extends GetxController {
  var selectedStreetIndex = RxInt(-1); // -1 indicates no selection
  var streets = RxList<StreetModel>(); // List of all streets
  final EulerCircuit _eulerCircuit = Get.find<EulerCircuit>(); // Access EulerCircuit controller

  void setSelectedStreetIndex(int index) {
    print('lavada dei ${index}');
    selectedStreetIndex.value = index;
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
    if (currentSegmentIndex < 0 || currentSegmentIndex >= _eulerCircuit.eulerCircuit.length) return [];

    List<StreetModel> visibleStreets = [];

    // Loop through the Euler circuit starting from the current segment
    for (int i = currentSegmentIndex; i < currentSegmentIndex + 5 && i < _eulerCircuit.eulerCircuit.length; i++) {
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

  StreetItemWidget({
    Key? key,
    required this.street,
    required this.onDelete,
    required this.onNavigate,
    this.isSelected = false,
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
            style: TextStyle(fontSize: 12), // Smaller font size for ID text
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.directions, size: 20), // Smaller icon size
                onPressed: onNavigate,
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 20), // Smaller icon size
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
              return Container(
                color: Colors.white,
                child: ListTile(
                  title: Text('Reset Selection'),
                  leading: Icon(Icons.refresh),
                  onTap: () => _controller.resetSelectedStreetIndex(),
                ),
              );
            } else {
              final street = streets[index - 1];
              bool isSelected = (index - 1) == _controller.selectedStreetIndex.value;
              return StreetItemWidget(
                street: street,
                onDelete: () => deleteStreet(street),
                onNavigate: () => navigateToStreet(street),
                isSelected: isSelected,
              );
            }
          },
        ),
      );
    });
  }

  void deleteStreet(StreetModel street) {
    // Implement the deletion logic for a street
    // Example: Make API call to delete the street and refresh the data
  }

  void navigateToStreet(StreetModel street) {
    // Implement the navigation logic to a street
    // Example: Open Google Maps with the street coordinates
  }
}
