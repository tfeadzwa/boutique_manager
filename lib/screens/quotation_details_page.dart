import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/quotation.dart';
import '../db/database_helper.dart';
import 'quotation_form_page.dart';
import 'package:permission_handler/permission_handler.dart';

class QuotationDetailPage extends StatelessWidget {
  final Quotation quotation;

  QuotationDetailPage({required this.quotation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotation #${quotation.id}'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _exportAsPDF(context),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedQuotation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuotationFormPage(quotationToEdit: quotation),
                ),
              );

              if (updatedQuotation != null) {
                Navigator.pop(context, updatedQuotation);
              }
            },
          ),
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
            Text(
              'Customer: ${quotation.customerName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${quotation.date.toIso8601String().split('T').first}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: quotation.items.length,
                itemBuilder: (context, index) {
                  final item = quotation.items[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        'Qty: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        'Total: \$${(item.quantity * item.price).toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 1),
            Text(
              'Total Amount: \$${quotation.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            title: Text('Delete Quotation?'),
            content: Text('Are you sure you want to delete this quotation?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteQuotation(quotation.id!);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _exportAsPDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Quotation #${quotation.id}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Customer: ${quotation.customerName}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Date: ${quotation.date.toIso8601String().split('T').first}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Items:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.ListView.builder(
                  itemCount: quotation.items.length,
                  itemBuilder: (context, index) {
                    final item = quotation.items[index];
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          item.productName,
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
                pw.Divider(),
                pw.Text(
                  'Total: \$${quotation.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );

    // Request correct storage permission
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final appFolder = Directory(
        '${directory!.path}/Documents/BoutiqueManager',
      );

      if (!await appFolder.exists()) {
        await appFolder.create(recursive: true);
      }

      final file = File('${appFolder.path}/quotation_${quotation.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
    } else {
      if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      }
    }
  }
}
