import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inventory/Getx/cart screen.dart';
import 'package:inventory/Model/Product.dart';
import 'package:inventory/Service/pdf_invoice_service.dart';
import 'package:inventory/screens/Payment screen.dart';
import 'package:inventory/Service/pdf_invoice_service.dart';

class CartScreen extends StatefulWidget {
  CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find();
  final TextEditingController _phoneController = TextEditingController();
  final PdfInvoiceService _pdfInvoiceService = PdfInvoiceService();
  bool _isGenerating = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showEmptyCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cart is empty'),
        content: const Text('Please enter cart items'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildCartItems() {
    return cartController.cartItems.map<Map<String, dynamic>>((dynamic entry) {
      if (entry is Product) {
        return {
          'name': entry.name,
          'price': entry.price,
          'quantity': entry.quantity ?? 1,
        };
      }
      if (entry is Map) {
        return {
          'name': entry['name'],
          'price': entry['price'],
          'quantity': entry['quantity'] ?? 1,
        };
      }
      return {'name': entry.toString(), 'price': 0, 'quantity': 0};
    }).toList();}

  double _parseDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<File?> _generateQuotationPdf() async {
    if (cartController.cartItems.isEmpty) {
      _showEmptyCartDialog();
      return null;
    }
    final List<Map<String, dynamic>> items = _buildCartItems();
    try {
      setState(() {
        _isGenerating = true;
      });
      return await _pdfInvoiceService.generateInvoice(
        title: 'QUOTATION',
        createdAt: DateTime.now(),
        items: items,
        subtotal: cartController.subtotalValue.value,
        sgst: cartController.SGSTValue.value,
        cgst: cartController.CGSTValue.value,
        total: cartController.totalValue.value,
      );  } catch (error) {
      Get.snackbar(
        'Quotation',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  String _buildSummaryMessage() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Quotation generated on ${formatter.format(DateTime.now())}');
    for (final Map<String, dynamic> item in _buildCartItems()) {
      final double price = _parseDouble(item['price']);
      final double quantity = _parseDouble(item['quantity']);
      buffer.writeln(
        "${item['name']} x${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} - Rs ${price.toStringAsFixed(2)}",
      );
    }
    buffer.writeln(
        'Subtotal: Rs ${cartController.subtotalValue.value.toStringAsFixed(2)}');
    buffer.writeln(
        'SGST: Rs ${cartController.SGSTValue.value.toStringAsFixed(2)}');
    buffer.writeln(
        'CGST: Rs ${cartController.CGSTValue.value.toStringAsFixed(2)}');
    buffer.writeln(
        'Total: Rs ${cartController.totalValue.value.toStringAsFixed(2)}');

    final List<String> words = buffer
        .toString()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length <= 160) {
      return buffer.toString().trim();
    }
    return words.take(160).join(' ');
  }

  Future<void> _sharePdfViaWhatsApp() async {
    final String phone = _phoneController.text.trim();
    if (phone.isEmpty) {

      Get.snackbar(
        'WhatsApp',
        'Enter the customer\'s phone number to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final File? pdfFile = await _generateQuotationPdf();
    if (pdfFile == null) {
      return;
    }

    final String message = _buildSummaryMessage();

    try {
      final ShareResult result = await Share.shareXFiles(
        <XFile>[XFile(pdfFile.path, mimeType: 'application/pdf')],
        text: message,
        subject: 'Quotation',
      );

      if (result.status == ShareResultStatus.success) {
        final Uri whatsappUri = Uri.parse(
          'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9+]'), '')}?text=${Uri.encodeComponent(message)}',
        );
        if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
          Get.snackbar(
            'WhatsApp',
            'Quotation shared. Unable to open WhatsApp automatically.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (error) {
      Get.snackbar(
        'whatsapp',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendSms() async {
    final String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'SMS',
        'Enter the customer\'s phone number to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String message = _buildSummaryMessage();
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: <String, String>{'body': message},
    );

    if (!await launchUrl(smsUri)) {
      Get.snackbar(
        'SMS',
        'Unable to open the SMS application.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Checkout'),
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
            onPressed: _isGenerating ? null : _sharePdfViaWhatsApp,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Share quotation via WhatsApp',
          ),
          IconButton(
            onPressed: _sendSms,
            icon: const Icon(Icons.sms),
            tooltip: 'Send quotation via SMS',
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Customer phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_isGenerating)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
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
                                        4: FlexColumnWidth(5), // Increased width for Quantity
                                        5: FlexColumnWidth(5), // Increased width for Total
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
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Reduce',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Delete',
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
                                                '${item.name}',
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
                                                '${item.price}',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${(item.price * item.quantity).toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextButton(
                                                child: Icon(
                                                  MdiIcons.minusCircle,
                                                  color: Colors.redAccent,
                                                  size: 15,
                                                ),
                                                onPressed: () => cartController.reduceProductQuantity(item),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextButton(
                                                child: Icon(
                                                  MdiIcons.delete,
                                                  color: Colors.redAccent,
                                                  size: 15,
                                                ),
                                                onPressed: () => cartController.removeItem(item),
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
                  Obx(() => Text(
                    'SGST of 2.5%: Rs.${cartController.SGSTValue.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  SizedBox(height: 8),
                  Obx(() => Text(
                    'CGST of 2.5%: Rs.${cartController.CGSTValue.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
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
                              'Abandon the cart',
                              style: TextStyle(fontSize: 10.0),
                            ),
                            Icon(MdiIcons.closeCircle, size: 10),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ), // button shape,
                      ),
                      onPressed: () {
                        cartController.clearCart();
                        Get.back();
                      },
                    ),
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
                        vertical: 16.0,
                        horizontal: 26.0,
                      ),
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
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (cartController.cartItems.isEmpty) {
                        _showEmptyCartDialog();
                      } else {
                        Get.to(PaymentHomePage());
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
