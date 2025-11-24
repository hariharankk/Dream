import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:inventory/Getx/Transaction.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:inventory/Service/pdf_invoice_service.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_share_improved/whatsapp_share_improved.dart';



class InvoiceScreen extends StatefulWidget {
  final Transaction transaction;

  const InvoiceScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final TransactionController cartController = Get.put(TransactionController());
  final PdfInvoiceService _pdfInvoiceService = PdfInvoiceService();

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Initialize cart items from transaction once. This becomes our source of truth.
    cartController.setCartItems(widget.transaction.products as List<dynamic>);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- Helpers ---------------------------------------------------------------

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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Build normalized items list from the *current cartController.cartItems*.
  /// This ensures PDF, SMS, and UI all use the same data.
  List<Map<String, dynamic>> _buildInvoiceItems() {
    return cartController.cartItems
        .map<Map<String, dynamic>>((dynamic item) {
      if (item is Map) {
        return {
          'name': item['name'] ?? '',
          'price': _parseDouble(item['price']),
          'quantity': _parseDouble(item['quantity']),
        };
      }
      return {
        'name': item.toString(),
        'price': 0.0,
        'quantity': 0.0,
      };
    }).toList();
  }

  /// Generate the PDF file using the current cart state.
  Future<File?> _generateInvoicePdf() async {
    final List<Map<String, dynamic>> items = _buildInvoiceItems();
    final DateTime? createdAt =
    _parseTransactionDate(widget.transaction.transaction_time);

    try {
      setState(() {
        _isGenerating = true;
      });

      final File file = await _pdfInvoiceService.generateInvoice(
        title: 'INVOICE',
        billNo: widget.transaction.id?.toString(),
        createdAt: createdAt,
        items: items,
        subtotal: cartController.subtotalValue.value,
        sgst: cartController.SGSTValue.value,
        cgst: cartController.CGSTValue.value,
        total: cartController.totalValue.value,

        // ------- COMPANY DETAILS (edit these once) -------
        companyName: 'JKT Hitech Rice Industries',
        companyAddress:
        'Your full address line 1,\nYour area, city, district, PIN',
        companyGst: '33AAUFJ0516G1ZH',
        companyFssai: 'Your FSSAI No here',

        // ------- CUSTOMER DETAILS FROM TRANSACTION -------
        customerName: widget.transaction.customerName,
        customerAddress: widget.transaction.customerAddress,
        customerPhone: widget.transaction.customerPhone,
      );

      return file;
    } catch (error) {
      Get.snackbar(
        'Invoice',
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

  /// Build a human-readable summary (for SMS / share text).
  /// Limited by character count instead of word count.
  String _buildSummaryMessage() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final DateTime timestamp =
        _parseTransactionDate(widget.transaction.transaction_time) ??
            DateTime.now();

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Invoice #${widget.transaction.id ?? '-'}');
    buffer.writeln('Date: ${formatter.format(timestamp)}');

    for (final Map<String, dynamic> item in _buildInvoiceItems()) {
      final double price = _parseDouble(item['price']);
      final double quantity = _parseDouble(item['quantity']);

      // Format quantity: no decimals if whole number, else 2 decimals
      final bool isWhole = quantity.truncateToDouble() == quantity;
      final String qtyStr = quantity.toStringAsFixed(isWhole ? 0 : 2);
      buffer.writeln(
          '${item['name']} x$qtyStr - Rs ${price.toStringAsFixed(2)}');
    }

    buffer.writeln(
        'Subtotal: Rs ${cartController.subtotalValue.value.toStringAsFixed(2)}');
    buffer.writeln(
        'SGST: Rs ${cartController.SGSTValue.value.toStringAsFixed(2)}');
    buffer.writeln(
        'CGST: Rs ${cartController.CGSTValue.value.toStringAsFixed(2)}');
    buffer.writeln(
        'Total: Rs ${cartController.totalValue.value.toStringAsFixed(2)}');
    buffer.writeln('Thank you for shopping with us!');

    // Limit message length by characters (not words) to avoid huge SMS blobs.
    const int maxChars = 480; // ~3 SMS chunks; adjust as you like.
    final String full = buffer.toString().trim();

    if (full.length <= maxChars) {
      return full;
    }
    return full.substring(0, maxChars);
  }
  Widget _buildCustomerDetailsCard() {
    final String phone = widget.transaction.customerPhone ?? 'Not provided';
    final String? name = widget.transaction.customerName;
    final String? address = widget.transaction.customerAddress;

    Widget _buildRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Expanded(child: Text(value.isEmpty ? '-' : value)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer details',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8.0),
              if (name != null && name.isNotEmpty) _buildRow('Name', name),
              _buildRow('Phone', phone),
              if (address != null && address.isNotEmpty)
                _buildRow('Address', address),
            ],
          ),
        ),
      ),
    );
  }

  // --- Actions ---------------------------------------------------------------

  /// Share the generated PDF using the system share sheet (WhatsApp, Gmail, etc.).
  /// No longer forces a separate WhatsApp deeplink after sharing.
  /// Share the generated PDF directly to the customer's WhatsApp chat.
  Future<void> _sharePdf() async {
    final String? rawPhone = widget.transaction.customerPhone;

    if (rawPhone == null || rawPhone.trim().isEmpty) {
      Get.snackbar(
        'WhatsApp',
        'Customer phone number is missing for this transaction.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Clean number: keep only digits
    String phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    // If it’s a 10-digit Indian mobile number, prefix 91
    if (phone.length == 10) {
      phone = '91$phone';
    }

    final File? pdfFile = await _generateInvoicePdf();
    if (pdfFile == null) return;

    final String message = _buildSummaryMessage();

    try {
      await WhatsappShareImproved.shareFile(
        phone: phone,
        text: message,          // optional caption
        filePath: [pdfFile.path],
      );
    } catch (error) {
      print(error);
      Get.snackbar(
        'WhatsApp',
        'Unable to send invoice via WhatsApp.\n$error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
  /// Send SMS with only the text summary.
  Future<void> _sendSms() async {
    final String? phone = widget.transaction.customerPhone;
    if (phone == null || phone.trim().isEmpty) {
      Get.snackbar(
        'SMS',
        'Customer phone number is missing for this transaction.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
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

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INVOICE'),
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
        actions: <Widget>[
          IconButton(
            onPressed: _isGenerating ? null : _sharePdf,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Share PDF',
          ),
          IconButton(
            onPressed: _sendSms,
            icon: const Icon(Icons.sms),
            tooltip: 'Send SMS',
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
            // Phone input (used for SMS only)
            _buildCustomerDetailsCard(),
            if (_isGenerating)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
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
                    child: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Obx(
                                () => Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth:
                                    MediaQuery.of(context).size.width,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: IntrinsicWidth(
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(6), // Name
                                          1: FlexColumnWidth(5), // Price
                                          2: FlexColumnWidth(5), // Quantity
                                          3: FlexColumnWidth(5), // Total
                                        },
                                        border: TableBorder.all(),
                                        children: [
                                          const TableRow(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Name',
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Price',
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Quantity',
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
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
                                          for (final item
                                          in cartController.cartItems)
                                            TableRow(
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${item['name']}',
                                                    maxLines: 3,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    softWrap: true,
                                                    style: const TextStyle(
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _parseDouble(item['price'])
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _parseDouble(
                                                        item['quantity'])
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    (_parseDouble(
                                                        item['price']) *
                                                        _parseDouble(
                                                            item[
                                                            'quantity']))
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
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
                            ),
                          ),
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
                  Obx(
                        () => Text(
                      'Subtotal: Rs.${cartController.subtotalValue.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                        () => Text(
                      'SGST of 2.5%: Rs.${cartController.SGSTValue.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                        () => Text(
                      'CGST of 2.5%: Rs.${cartController.CGSTValue.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                        () => Text(
                      'Total: Rs.${cartController.totalValue.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
