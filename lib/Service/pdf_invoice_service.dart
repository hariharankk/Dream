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
  }) async {
    final pw.Document pdf = pw.Document();
    final DateTime timestamp = createdAt ?? DateTime.now();
    final NumberFormat currencyFormatter =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

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
            'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}',
            style: pw.TextStyle(fontSize: 12),
          ),
          if (billNo != null)
            pw.Text(
              'Bill No: $billNo',
              style: pw.TextStyle(fontSize: 12),
            ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: const <String>['Item', 'Price', 'Qty', 'Total'],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            columnWidths: <int, pw.TableColumnWidth>{
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
            },
            data: <List<String>>[
              for (final Map<String, dynamic> item in items)
                <String>[
                  '${item['name']}',
                  currencyFormatter.format((item['price'] ?? 0).toDouble()),
                  '${item['quantity'] ?? 0}',
                  currencyFormatter.format(
                    ((item['price'] ?? 0) * (item['quantity'] ?? 0))
                        .toDouble(),
                  ),
                ],
            ],
            border: pw.TableBorder.all(width: 0.5),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: <pw.Widget>[
              pw.Container(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: <pw.Widget>[
                    _buildSummaryRow('Subtotal', currencyFormatter.format(subtotal)),
                    _buildSummaryRow('SGST (2.5%)', currencyFormatter.format(sgst)),
                    _buildSummaryRow('CGST (2.5%)', currencyFormatter.format(cgst)),
                    pw.Divider(),
                    _buildSummaryRow(
                      'Total',
                      currencyFormatter.format(total),
                      isEmphasized: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Thank you for your purchase!',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    return _savePdfDocument(pdf, prefix: 'invoice');
  }

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
              _buildSummaryRow('Price', currencyFormatter.format(productPrice)),
              _buildSummaryRow(
                  'Total Weight', '${totalWeight.toStringAsFixed(2)} kg'),
              _buildSummaryRow(
                  'Used Weight', '${usedWeight.toStringAsFixed(2)} kg'),
              _buildSummaryRow(
                  'Return Weight', '${returnWeight.toStringAsFixed(2)} kg'),
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

  pw.Widget _buildSummaryRow(String label, String value,
      {bool isEmphasized = false}) {
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

  Future<File> _savePdfDocument(pw.Document pdf, {String prefix = 'invoice'})
  async {
    final Uint8List bytes = await pdf.save();
    final Directory directory = await getApplicationDocumentsDirectory();
    final String fileName =
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}