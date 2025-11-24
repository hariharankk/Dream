import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceService {
  Future<File> generateInvoice({
    required String title,
    String? billNo,
    DateTime? createdAt,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double sgst,
    required double cgst,
    required double total,

    // --------- Company details ----------
    required String companyName,
    required String companyAddress,
    required String companyGst,
    required String companyFssai,

    // --------- Customer details ----------
    String? customerName,
    String? customerAddress,
    String? customerPhone,
  }) async {
    final pw.Document pdf = pw.Document();
    final DateTime timestamp = createdAt ?? DateTime.now();
    final DateFormat dateFormatter = DateFormat('dd-MM-yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => <pw.Widget>[
          // ---------- TITLE (INVOICE at top) ----------
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // ---------- COMPANY + BILL TO (left) | INVOICE META (right) ----------
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // LEFT: JKT + Bill To
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Company block
                    pw.Text(
                      companyName,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      companyAddress,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'GSTIN: $companyGst',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'FSSAI: $companyFssai',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 10),

                    // Bill To block
                    pw.Text(
                      'Bill To:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (customerName != null &&
                        customerName.trim().isNotEmpty)
                      pw.Text(
                        customerName,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    if (customerAddress != null &&
                        customerAddress.trim().isNotEmpty)
                      pw.Text(
                        customerAddress,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    if (customerPhone != null &&
                        customerPhone.trim().isNotEmpty)
                      pw.Text(
                        'Phone: $customerPhone',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),

              // RIGHT: Invoice no + Date
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (billNo != null && billNo.isNotEmpty)
                    pw.Text(
                      'Invoice No: $billNo',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  pw.Text(
                    'Date: ${dateFormatter.format(timestamp)}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // ---------- ITEMS TABLE ----------
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: <int, pw.TableColumnWidth>{
              0: const pw.FlexColumnWidth(4),   // Item
              1: const pw.FlexColumnWidth(1.5), // Qty
              2: const pw.FlexColumnWidth(2),   // Rate
              3: const pw.FlexColumnWidth(2.5), // Amount
            },
            children: [
              // Header row
              pw.TableRow(
                children: [
                  _tableHeaderCell('Item'),
                  _tableHeaderCell('Qty'),
                  _tableHeaderCell('Rate (Rs)'),
                  _tableHeaderCell('Amount (Rs)'),
                ],
              ),
              // Data rows
              ...items.map((Map<String, dynamic> item) {
                final double price = _toDouble(item['price']);
                final double quantity = _toDouble(item['quantity']);
                final double amount = price * quantity;

                return pw.TableRow(
                  children: [
                    _tableCell(item['name']?.toString() ?? ''),
                    _tableCell(_formatQty(quantity)),
                    _tableCell(price.toStringAsFixed(2)),
                    _tableCell(amount.toStringAsFixed(2)),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 16),

          // ---------- TOTALS (numbers only) ----------
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: <pw.Widget>[
              pw.Container(
                width: 220,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: <pw.Widget>[
                    _buildSummaryRow(
                      'Subtotal (Rs)',
                      subtotal.toStringAsFixed(2),
                    ),
                    _buildSummaryRow(
                      'SGST (2.5%) (Rs)',
                      sgst.toStringAsFixed(2),
                    ),
                    _buildSummaryRow(
                      'CGST (2.5%) (Rs)',
                      cgst.toStringAsFixed(2),
                    ),
                    pw.Divider(),
                    _buildSummaryRow(
                      'Total (Rs)',
                      total.toStringAsFixed(2),
                      isEmphasized: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // ---------- FOOTER ----------
          pw.Text(
            'This is a computer-generated invoice.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Thank you for your purchase.',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    return _savePdfDocument(pdf, prefix: 'invoice');
  }

  // ------------------ RETURN SUMMARY (unchanged) ------------------

  Future<File> generateReturnSummary({
    String title = 'RETURN DETAILS',
    required String productName,
    required double productPrice,
    required double totalWeight,
    required double usedWeight,
    required double returnWeight,
    required double refundAmount,
    required String reason,
    String? transactionId,
    String? location,
    DateTime? createdAt,
  }) async {
    final pw.Document pdf = pw.Document();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final NumberFormat currencyFormatter =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final DateTime timestamp = createdAt ?? DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Date: ${formatter.format(timestamp)}',
            style: pw.TextStyle(fontSize: 12),
          ),
          if (transactionId != null && transactionId.isNotEmpty)
            pw.Text(
              'Transaction ID: $transactionId',
              style: pw.TextStyle(fontSize: 12),
            ),
          pw.SizedBox(height: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              _buildSummaryRow('Product', productName),
              _buildSummaryRow(
                'Price',
                currencyFormatter.format(productPrice),
              ),
              _buildSummaryRow(
                'Total Weight',
                '${totalWeight.toStringAsFixed(2)} kg',
              ),
              _buildSummaryRow(
                'Used Weight',
                '${usedWeight.toStringAsFixed(2)} kg',
              ),
              _buildSummaryRow(
                'Return Weight',
                '${returnWeight.toStringAsFixed(2)} kg',
              ),
              _buildSummaryRow(
                'Refund Amount',
                currencyFormatter.format(refundAmount),
                isEmphasized: true,
              ),
              if (location != null && location.isNotEmpty)
                _buildSummaryRow('Location', location),
            ],
          ),
          if (reason.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 16),
            pw.Text(
              'Reason for return',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              reason,
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            'Processed with Dream Inventory',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    return _savePdfDocument(pdf, prefix: 'return');
  }

  // ---------- Shared helpers ----------

  pw.Widget _buildSummaryRow(
      String label,
      String value, {
        bool isEmphasized = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight:
              isEmphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight:
              isEmphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  static String _formatQty(double qty) {
    final bool isWhole = qty.truncateToDouble() == qty;
    return qty.toStringAsFixed(isWhole ? 0 : 2);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<File> _savePdfDocument(
      pw.Document pdf, {
        String prefix = 'invoice',
      }) async {
    final Uint8List bytes = await pdf.save();
    final Directory directory = await getApplicationSupportDirectory();
    final String fileName =
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
