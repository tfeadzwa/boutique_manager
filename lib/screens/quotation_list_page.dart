import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for currency formatting
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../db/database_helper.dart';
import '../models/quotation.dart';
import 'quotation_form_page.dart';
import 'quotation_details_page.dart'; // Import the QuotationDetailPage

class QuotationListPage extends StatefulWidget {
  final int? userId;
  QuotationListPage({this.userId, Key? key}) : super(key: key);

  @override
  _QuotationListPageState createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  List<Quotation> quotations = [];
  List<Quotation> filteredQuotations = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadQuotations();
    searchController.addListener(_filterQuotations);
  }

  Future<void> _loadQuotations() async {
    setState(() {
      isLoading = true;
    });
    final data = await DatabaseHelper.instance.getQuotationsByUser(
      widget.userId,
    );
    setState(() {
      quotations = data;
      filteredQuotations = data;
      isLoading = false;
    });
  }

  void _filterQuotations() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredQuotations =
          quotations
              .where(
                (quotation) =>
                    quotation.customerName.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  void _confirmDelete(BuildContext context, int id) {
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
                  await DatabaseHelper.instance.deleteQuotation(id);
                  Navigator.pop(context); // Close dialog
                  _loadQuotations(); // Reload list
                },
              ),
            ],
          ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatter.format(amount);
  }

  Future<void> _exportAsPDF(BuildContext context, Quotation quotation) async {
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

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/quotation_${quotation.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quotations')),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show spinner when loading
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Quotations',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        filteredQuotations.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No quotations yet!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add your first quotation to get started.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: filteredQuotations.length,
                              itemBuilder: (context, index) {
                                final q = filteredQuotations[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  elevation: 3,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      q.customerName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text(
                                          'Date: ${q.date.toIso8601String().split('T').first}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${q.items.length} items',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.picture_as_pdf),
                                          onPressed:
                                              () => _exportAsPDF(context, q),
                                        ),
                                        Text(
                                          _formatCurrency(q.totalAmount),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      final updatedQuotation =
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => QuotationDetailPage(
                                                    quotation: q,
                                                  ),
                                            ),
                                          );

                                      if (updatedQuotation != null) {
                                        setState(() {
                                          final index = quotations.indexWhere(
                                            (quotation) =>
                                                quotation.id ==
                                                updatedQuotation.id,
                                          );
                                          if (index != -1) {
                                            quotations[index] =
                                                updatedQuotation;
                                            filteredQuotations[index] =
                                                updatedQuotation;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuotationFormPage()),
          );
          _loadQuotations();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
