import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../db/database_helper.dart';
import 'invoice_form_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _exportAsPDF(context),
          ),
          if (role == 'admin') // Show edit button only for admin
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoiceFormPage(invoiceToEdit: invoice),
                  ),
                );
                Navigator.pop(
                  context,
                ); // After editing, go back to refresh list
              },
            ),
          if (role == 'admin') // Show delete button only for admin
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
                      'Invoice Date: ${_formatDate(invoice.date)}',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4),
                    _buildText(
                      invoice.isPaid ? 'PAID' : 'UNPAID',
                      fontSize: 14,
                      color: invoice.isPaid ? Colors.green : Colors.red,
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
                      'Paid Date: ${invoice.isPaid ? _formatDate(invoice.date) : 'N/A'}',
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
                itemCount: invoice.products.length,
                itemBuilder: (context, index) {
                  final product = invoice.products[index];
                  final productTotal = product.quantity * product.price;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.shopping_cart, color: Colors.black),
                      ),
                      title: _buildText(product.name, fontSize: 16),
                      subtitle: _buildText(
                        '${product.quantity} pcs • €${product.price.toStringAsFixed(2)}',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      trailing: _buildText(
                        '€${productTotal.toStringAsFixed(2)}',
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
                ElevatedButton(
                  onPressed: () {
                    // Save action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: Text('SAVE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Pick Order action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'PICK ORDER €${invoice.totalAmount.toStringAsFixed(2)}',
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
                  Navigator.pop(context); // Go back to invoice list
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
                  'Invoice #${invoice.id}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Customer: ${invoice.customerName}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Date: ${_formatDate(invoice.date)}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Products:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.ListView.builder(
                  itemCount: invoice.products.length,
                  itemBuilder: (context, index) {
                    final product = invoice.products[index];
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          product.name,
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          '${product.quantity} x €${product.price.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          '€${(product.quantity * product.price).toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
                pw.Divider(),
                pw.Text(
                  'Total: €${invoice.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
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
