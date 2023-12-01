import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:inventory/Getx/Transaction.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoiceScreen extends StatelessWidget {
  final TransactionController cartController = Get.put(TransactionController());
  Transaction transaction;
  InvoiceScreen({required this.transaction});

  Future<void> _generateInvoicePdf(Transaction transaction) async {
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.all(32.0),
        ),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('INVOICE', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end, // To align text to the right side
                children: [
                  pw.Text(
                    DateFormat('yyyy-MM-dd').format(transaction.transaction_time), // Displaying date
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),  // Spacing between date and bill no.
                  pw.Text(
                    'Bill No: ${transaction.id}', // Displaying bill number
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.normal),
                  ),
                ],
              )
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('JKT HITECH RICE INDUSTRIES'),
                  // Add address, phone number, etc. if needed
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Cash Sales'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontSize: 15),
            headers: ['Item', 'Price', 'Stock', 'Discount'],
            data: <List<String>>[
              ...transaction.products.map(
                      (item) => [item['name'], item['price'].toString(), item['quantity'].toString(), item['flatdiscount'].toString() ?? '0']
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(text: 'Subtotal: ${cartController.subtotalValue}'),
          pw.Paragraph(text: 'SGST (2.5%): ${cartController.SGSTValue}'),
          pw.Paragraph(text: 'CGST (2.5%): ${cartController.CGSTValue}'),
          pw.Paragraph(text: 'Discount: ${cartController.DiscountValue}'),
          pw.Paragraph(text: 'Total: ${cartController.totalValue}'),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
            _generateInvoicePdf(transaction);
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
                            borderRadius: BorderRadius.circular(6))),
                    child: Container(
                      height: 100,
                      child: Obx(() => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, right: 11.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Items',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartController.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartController.cartItems[index];
                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible( // Wrapping the first Text widget with Flexible
                                        child: Text(
                                          '${item['name']}',
                                          overflow: TextOverflow.ellipsis, // Using ellipsis in case text is too long
                                          style: TextStyle(
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        'Rs.${item['price']}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        '${item['quantity']}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        'Rs.${item['flatdiscount']}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ],
                                  ),

                                );
                              },
                            ),
                          ),
                        ],
                      )),
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
                    'Subtotal: Rs.${cartController.subtotalValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  SizedBox(height: 8),
                  Text(
                    'Flat Discount: - Rs.${cartController.DiscountValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SGST of 2.5%: Rs.${cartController.CGSTValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CGST of 2.5%: Rs.${cartController.CGSTValue}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() => Text(
                    'Total: Rs.${cartController.totalValue}',
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