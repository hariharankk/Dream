import 'dart:math' as math;

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/thermal_printer_controller.dart';

Future<bool?> showPrinterSelector(
    BuildContext context,
    ThermalPrinterController controller,
    ) async {
  try {
    await controller.refreshPairedDevices();
  } catch (error) {
    Get.snackbar(
      'Printer',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  final List<BluetoothDevice> devices = controller.devices.toList();
  if (devices.isEmpty) {
    Get.snackbar(
      'Printer',
      'No paired thermal printers found. Pair your printer first.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  return showModalBottomSheet<bool>(
    context: context,
    builder: (context) {
      final double listHeight = math.min(devices.length * 72.0, 360.0);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Select a printer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: listHeight,
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(device.name ?? 'Unknown'),
                    subtitle: Text(device.address ?? ''),
                    onTap: () {
                      controller.setSelectedDevice(device);
                      Navigator.of(context).pop(true);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
    },
  );
}