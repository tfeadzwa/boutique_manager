import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../db/database_helper.dart';
import 'invoice_form_page.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;

  InvoiceDetailPage({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceFormPage(invoiceToEdit: invoice),
                ),
              );
              Navigator.pop(context); // After editing, go back to refresh list
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
              'Customer: ${invoice.customerName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${invoice.date.toIso8601String().split('T').first}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Products:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Product Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Price',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ...invoice.products.map((product) {
                        final productTotal = product.quantity * product.price;
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.name,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${product.quantity}',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '\$${productTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${invoice.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
