import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/Transaction.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:inventory/Getx/thermal_printer_controller.dart';
import 'package:inventory/Widget/printer_selector.dart';

class InvoiceScreen extends StatelessWidget {
  final TransactionController cartController = Get.put(TransactionController());
  Transaction transaction;

  final ThermalPrinterController printerController =
  Get.isRegistered<ThermalPrinterController>()
      ? Get.find<ThermalPrinterController>()
      : Get.put(ThermalPrinterController(), permanent: true);
  InvoiceScreen({required this.transaction});

  DateTime? _parseTransactionDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _printInvoice(BuildContext context) async {
    final List<Map<String, dynamic>> items = transaction.products
        .map<Map<String, dynamic>>((dynamic item) {
      if (item is Map) {
        return {
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
        };
      }
      return {'name': item.toString(), 'price': 0, 'quantity': 0};
    }).toList();
    try {
      if (!await printerController.isPrinterConnected) {
        final bool? selected = await showPrinterSelector(context, printerController);
        if (selected != true) {
          return;
        }
      }

      await printerController.printInvoice(
        title: 'INVOICE',
        billNo: transaction.id?.toString(),
        createdAt: _parseTransactionDate(transaction.transaction_time),
        items: items,
        subtotal: cartController.subtotalValue.value,
        sgst: cartController.SGSTValue.value,
        cgst: cartController.CGSTValue.value,
        total: cartController.totalValue.value,
      );

      Get.snackbar(
        'Printer',
        'Invoice sent to printer',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Printer',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    cartController.setCartItems(transaction.products as List<dynamic>);
    return Scaffold(
      appBar: AppBar(
        title: Text('INVOICE'),
        centerTitle: true,
        elevation: 5.0,
        leading: TextButton(
          child: Icon(
            MdiIcons.arrowLeft,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(onPressed: (){
            _printInvoice(context);
          }, icon: Icon(Icons.print))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Cart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Card(
                  elevation: 4.0,
                  color: Colors.grey[100],
                  child: ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Container(
                      height: 100,
                      child: Column(
                        children: [
                          Obx(() => Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: IntrinsicWidth(
                                    child: Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(6), // Increased width for Name
                                        1: FlexColumnWidth(5), // Increased width for Price
                                        2: FlexColumnWidth(5), // Increased width for Discount
                                        3: FlexColumnWidth(5), // Increased width for Discount Price
                                       },
                                      border: TableBorder.all(),
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Name',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Price',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Quantity',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        for (var item in cartController.cartItems) TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['name']}',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['price']}',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item['quantity']}',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${((item['price']) * item['quantity']).toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() => Text(
                    'Subtotal: Rs.${cartController.subtotalValue.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  SizedBox(height: 8),
                  Text(
                    'SGST of 2.5%: Rs.${cartController.SGSTValue.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CGST of 2.5%: Rs.${cartController.CGSTValue.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() => Text(
                    'Total: Rs.${cartController.totalValue.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
