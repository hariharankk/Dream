import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:inventory/Getx/cart screen.dart';
import 'package:inventory/screens/Payment screen.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.find();

  Future<void> _generateInvoicePdf(var transaction) async {
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
              pw.Text('Qotation',
                  style: pw.TextStyle(
                      fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                DateFormat('yyyy-MM-dd').format(DateTime.now()),
                // Assuming you want the current date
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('JKT HITECH RICE INDUSTRIES'),
                  // Add address, phone number, etc. if needed
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('To:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Cash Sales'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontSize: 15),
            headers: ['Item', 'Price', 'Stock', 'Discount'],
            data: <List<dynamic>>[
              ...transaction.map((item) => [
                    item.name,
                    item.price.toString(),
                    item.quantity.toString(),
                    item.flatdiscount.toString() ?? '0'
                  ]),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Checkout'),
        centerTitle: true,
        elevation: 5.0,
        leading: TextButton(
          child: Icon(
            MdiIcons.arrowLeft,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _generateInvoicePdf(cartController.cartItems.value);
              },
              icon: Icon(Icons.print)),
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
                                padding:
                                    const EdgeInsets.only(top: 20, right: 11.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                  scrollDirection: Axis.vertical,
                                  itemCount: cartController.cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        cartController.cartItems[index];
                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.name}',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Rs.${item.price}',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Rs.${item.flatdiscount}',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      trailing: TextButton(
                                        child: Icon(
                                          MdiIcons.delete,
                                          color: Colors.redAccent,
                                          size: 30,
                                        ),
                                        onPressed: () =>
                                            cartController.removeItem(item),
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
                  Obx(
                        () => Text(
                      'Flat Discount: - Rs.${cartController.DiscountValue}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),
                  Obx(
                    () => Text(
                      'SGST of 2.5%: Rs.${cartController.CGSTValue}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => Text(
                      'CGST of 2.5%: Rs.${cartController.CGSTValue}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
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
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'abandon the cart',
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Icon(MdiIcons.closeCircle, size: 10)
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ), // button shape,
                        onPressed: () {
                          cartController.clearCart();
                          Get.back();
                        }),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ), // button shape
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 26.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Checkout',
                            style: TextStyle(fontSize: 10.0),
                          ),
                          Icon(
                            MdiIcons.logoutVariant,
                            size: 10,
                          )
                        ],
                      ),
                    ),
                    onPressed: () => Get.to(
                        PaymentHomePage()), // replace NextPage() with your Checkout Page
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
