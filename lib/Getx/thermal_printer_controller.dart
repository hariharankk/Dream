import 'dart:math';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ThermalPrinterController extends GetxController {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  final RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> _selectedDevice = Rx<BluetoothDevice?>(null);
  final RxBool isBusy = false.obs;
  final RxString lastError = ''.obs;

  BluetoothDevice? get selectedDevice => _selectedDevice.value;

  void setSelectedDevice(BluetoothDevice device) {
    _selectedDevice.value = device;
  }

  Future<void> refreshPairedDevices() async {
    try {
      isBusy.value = true;
      final bool? isOn = await _bluetooth.isOn;
      if (isOn != true) {
        throw PlatformException(
          code: 'bluetooth_off',
          message: 'Turn on Bluetooth to find paired printers',
        );
      }
      final bonded = await _bluetooth.getBondedDevices();
      devices.assignAll(bonded);
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> get isPrinterConnected async {
    final bool? connected = await _bluetooth.isConnected;
    return connected ?? false;
  }

  Future<void> connectToSelectedPrinter() async {
    final device = selectedDevice;
    if (device == null) {
      throw PlatformException(
        code: 'no_printer',
        message: 'No printer selected',
      );
    }

    try {
      isBusy.value = true;
      final bool? alreadyConnected = await _bluetooth.isConnected;
      if (alreadyConnected == true) {
        await _bluetooth.disconnect();
      }
      await _bluetooth.connect(device);
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _ensurePrinterReady() async {
    final bool? isOn = await _bluetooth.isOn;
    if (isOn != true) {
      throw PlatformException(
        code: 'bluetooth_off',
        message: 'Turn on the Bluetooth printer',
      );
    }

    if (!await isPrinterConnected) {
      await connectToSelectedPrinter();
    }
  }

  Future<void> printInvoice({
    required String title,
    String? billNo,
    DateTime? createdAt,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double sgst,
    required double cgst,
    required double total,
  }) async {
    await _ensurePrinterReady();

    final DateTime timestamp = createdAt ?? DateTime.now();

    _bluetooth.printNewLine();
    _bluetooth.printCustom(title, 2, 1);
    _bluetooth.printCustom(DateFormat('yyyy-MM-dd HH:mm').format(timestamp), 1, 1);
    if (billNo != null && billNo.isNotEmpty) {
      _bluetooth.printCustom('Bill No: $billNo', 1, 1);
    }
    _bluetooth.printCustom('------------------------------', 1, 1);

    for (final item in items) {
      final String name = (item['name'] ?? '').toString();
      final num quantityNum = _parseNum(item['quantity']);
      final num priceNum = _parseNum(item['price']);
      final double totalLine = (priceNum * quantityNum).toDouble();

      for (final line in _wrapText(name)) {
        _bluetooth.printCustom(line, 1, 0);
      }
      _bluetooth.printLeftRight(
        'x${quantityNum.toStringAsFixed(quantityNum.truncateToDouble() == quantityNum ? 0 : 2)} @ ${priceNum.toStringAsFixed(2)}',
        'Rs ${totalLine.toStringAsFixed(2)}',
        1,
      );
      _bluetooth.printNewLine();
    }

    _bluetooth.printCustom('------------------------------', 1, 1);
    _bluetooth.printLeftRight('Subtotal', 'Rs ${subtotal.toStringAsFixed(2)}', 1);
    _bluetooth.printLeftRight('SGST (2.5%)', 'Rs ${sgst.toStringAsFixed(2)}', 1);
    _bluetooth.printLeftRight('CGST (2.5%)', 'Rs ${cgst.toStringAsFixed(2)}', 1);
    _bluetooth.printLeftRight('Total', 'Rs ${total.toStringAsFixed(2)}', 2);
    _bluetooth.printNewLine();
    _bluetooth.printCustom('Thank you for your purchase!', 1, 1);
    _bluetooth.printNewLine();
    _bluetooth.printNewLine();
  }

  Future<void> printReturnDetails({
    required String productName,
    required double productPrice,
    required double totalWeight,
    required double usedWeight,
    required double remainingWeight,
    required double refundAmount,
    required String reason,
    String? transactionId,
    String? location,
    DateTime? createdAt,
  }) async {
    await _ensurePrinterReady();

    final DateTime timestamp = createdAt ?? DateTime.now();

    _bluetooth.printNewLine();
    _bluetooth.printCustom('RETURN DETAILS', 2, 1);
    _bluetooth.printCustom(DateFormat('yyyy-MM-dd HH:mm').format(timestamp), 1, 1);
    if (transactionId != null && transactionId.isNotEmpty) {
      _bluetooth.printCustom('Transaction ID: $transactionId', 1, 1);
    }
    _bluetooth.printCustom('------------------------------', 1, 1);

    _printLabelValue('Product', productName);
    _printLabelValue('Price', 'Rs ${productPrice.toStringAsFixed(2)}');
    _printLabelValue('Total Weight', '${totalWeight.toStringAsFixed(2)} kg');
    _printLabelValue('Used Weight', '${usedWeight.toStringAsFixed(2)} kg');
    _printLabelValue('Remaining', '${remainingWeight.toStringAsFixed(2)} kg');
    _printLabelValue('Refund', 'Rs ${refundAmount.toStringAsFixed(2)}');
    if (location != null && location.isNotEmpty) {
      _printLabelValue('Location', location);
    }
    if (reason.isNotEmpty) {
      _bluetooth.printCustom('Reason:', 1, 0);
      for (final line in _wrapText(reason)) {
        _bluetooth.printCustom(line, 1, 0);
      }
    }

    _bluetooth.printNewLine();
    _bluetooth.printCustom('Processed with Dream Inventory', 1, 1);
    _bluetooth.printNewLine();
    _bluetooth.printNewLine();
  }

  void _printLabelValue(String label, String value) {
    _bluetooth.printCustom('$label:', 1, 0);
    for (final line in _wrapText(value)) {
      _bluetooth.printCustom(line, 1, 0);
    }
  }

  Iterable<String> _wrapText(String text, {int maxChars = 32}) sync* {
    if (text.isEmpty) {
      yield '';
      return;
    }

    for (int start = 0; start < text.length; start += maxChars) {
      yield text.substring(start, min(start + maxChars, text.length));
    }
  }

  num _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}