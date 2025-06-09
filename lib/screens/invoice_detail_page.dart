import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../db/database_helper.dart';
import 'invoice_form_page.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;
  final String role; // Add role parameter

  InvoiceDetailPage({required this.invoice, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.id}'),
        actions: [
          if (role == 'admin')
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoiceFormPage(invoiceToEdit: invoice),
                  ),
                );
                Navigator.pop(context, result == true);
              },
            ),
          if (role == 'admin')
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(
                      'Invoice Date: ${_formatDate(invoice.timestamp)}',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4),
                    _buildText(
                      invoice.status == 'PAID' ? 'PAID' : 'UNPAID',
                      fontSize: 14,
                      color:
                          invoice.status == 'PAID' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildText(
                      'INVOICED €${invoice.totalAmount.toStringAsFixed(2)}',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 4),
                    _buildText(
                      'Paid Date: ${invoice.status == 'PAID' ? _formatDate(invoice.timestamp) : 'N/A'}',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Product List Section
            Expanded(
              child: ListView.builder(
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  final itemTotal = item.quantity * item.unitPrice;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.shopping_cart, color: Colors.black),
                      ),
                      title: _buildText(item.productName, fontSize: 16),
                      subtitle: _buildText(
                        '${item.quantity} pcs • €${item.unitPrice.toStringAsFixed(2)}',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      trailing: _buildText(
                        '€${itemTotal.toStringAsFixed(2)}',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer Section
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _downloadInvoicePDF(context),
                  icon: Icon(Icons.download),
                  label: Text('Download Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _shareInvoicePDF(context),
                  icon: Icon(Icons.share),
                  label: Text('Share Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete Invoice?'),
            content: Text('Are you sure you want to delete this invoice?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteInvoice(invoice.id!);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Go back to invoice list with result
                },
              ),
            ],
          ),
    );
  }

  Future<pw.Document> _buildInvoicePdf() async {
    final pdf = pw.Document();
    final logoImage = await imageFromAssetBundle('assets/botique_icon.png');
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo and business name
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 48,
                    height: 48,
                    child: pw.Image(logoImage),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    'Boutique Manager',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.deepOrange,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              // Invoice and customer info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Invoice #: ${invoice.id}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Customer: ${invoice.customerName}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Date: ${_formatDate(invoice.timestamp)}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Status: ${invoice.status}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color:
                              invoice.status == 'PAID'
                                  ? PdfColors.green
                                  : PdfColors.red,
                        ),
                      ),
                      pw.Text(
                        'Total: €${invoice.totalAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Products',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Product',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Unit Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...invoice.items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(item.productName),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(item.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '€${item.unitPrice.toStringAsFixed(2)}',
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '€${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Grand Total: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    '€${invoice.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                      color: PdfColors.deepOrange,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.green),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Boutique Manager • boutique@example.com',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _downloadInvoicePDF(BuildContext context) async {
    final pdf = await _buildInvoicePdf();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'invoice_${invoice.id}.pdf',
    );
  }

  Future<void> _shareInvoicePDF(BuildContext context) async {
    final pdf = await _buildInvoicePdf();
    final pdfBytes = await pdf.save();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'invoice_${invoice.id}.pdf',
      subject: 'Invoice PDF',
      body: 'Please find the attached invoice.',
    );
  }

  Future<pw.ImageProvider> imageFromAssetBundle(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return pw.MemoryImage(byteData.buffer.asUint8List());
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  Text _buildText(
    String text, {
    double fontSize = 14,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}
