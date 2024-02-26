import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/street review.dart';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Widget/street review.dart';

final StreetreviewController _controller = Get.find<StreetreviewController>();



void showReasonPopup() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the dialog compact
          children: <Widget>[
            Text(
              'Select Reason',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Custom text color
              ),
            ),
            SizedBox(height: 10), // Spacing
            ListTile(
              leading: Icon(Icons.timer, color: Colors.orange), // Custom icon
              title: Text('Temporary'),
              onTap: () {
                Get.back(); // Close the dialog
                _showOptionsDialog('Temporary');
              },
            ),
            ListTile(
              leading: Icon(Icons.perm_contact_cal, color: Colors.green), // Custom icon
              title: Text('Permanent'),
              onTap: () {
                Get.back(); // Close the dialog
                _showOptionsDialog('Permanent');
              },
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false, // Prevent closing dialog by tapping outside
  );
}


void _showOptionsDialog(String reasonType) {
  final controller = Get.find<ReasonController>(); // Find the controller
  final options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  Get.dialog(
    AlertDialog(
      title: Text('Reason: $reasonType'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...options.map((option) => Obx(() => ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: controller.selectedOption.value,
                onChanged: (value) {
                  controller.setSelectedOption(value!);
                },
              ),
            ))).toList(),

            SizedBox(height: 10), // Spacing

            TextField(
              decoration: InputDecoration(
                labelText: 'Additional feedback',
              ),
              onChanged: (value) => controller.setEnteredReason(value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Get.back(), // Close the dialog
        ),
        TextButton(
          child: Text('Submit'),
          onPressed: () {
           /* updateStreetDetails(_controller.selectedStreetIndex.value,'InActive',reasonType,controller.selectedOption.value).then((response) {
              print("Street updated successfully: $response");
            }).catchError((error) {
              print("Error updating street: $error");
            });
            */
            _controller.resetSelectedStreetIndex();
            Get.back();
            // Close the dialog
          },
        ),
      ],

    ),
  );
}
