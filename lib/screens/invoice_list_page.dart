import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/invoice.dart';
import 'invoice_form_page.dart';
import 'invoice_detail_page.dart';

class InvoiceListPage extends StatefulWidget {
  @override
  _InvoiceListPageState createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Invoice> invoices = [];
  List<Invoice> filteredInvoices = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    searchController.addListener(_filterInvoices);
  }

  Future<void> _loadInvoices() async {
    final data = await DatabaseHelper.instance.getAllInvoices();
    setState(() {
      invoices = data;
      filteredInvoices = data; // Initialize filtered list
    });
  }

  void _filterInvoices() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredInvoices =
          invoices
              .where(
                (invoice) => invoice.customerName.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InvoiceFormPage()),
              );
              _loadInvoices(); // Reload after adding a new invoice
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by customer or invoice',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child:
                filteredInvoices.isEmpty
                    ? Center(
                      child: Text(
                        'No invoices available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              invoice.customerName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'Date: ${invoice.date.toIso8601String().split('T').first}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        invoice.isPaid
                                            ? Color(
                                              0xFF4CAF50,
                                            ) // Green for PAID
                                            : Color(
                                              0xFFF44336,
                                            ), // Red for UNPAID
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    invoice.isPaid ? 'PAID' : 'UNPAID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '\$${invoice.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          InvoiceDetailPage(invoice: invoice),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Handle filter action
              },
              icon: Icon(Icons.filter_list),
              label: Text('FILTER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Handle sort action
              },
              icon: Icon(Icons.sort),
              label: Text('SORT BY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
