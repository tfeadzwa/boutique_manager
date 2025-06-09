import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for currency formatting
import '../db/database_helper.dart';
import '../models/invoice.dart';
import 'invoice_form_page.dart';
import 'invoice_detail_page.dart';

class InvoiceListPage extends StatefulWidget {
  final int? userId;
  final String? role;
  InvoiceListPage({this.userId, this.role, Key? key}) : super(key: key);

  @override
  _InvoiceListPageState createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Invoice> invoices = [];
  List<Invoice> filteredInvoices = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    searchController.addListener(_filterInvoices);
  }

  Future<void> _loadInvoices() async {
    setState(() {
      isLoading = true; // Show loading spinner
    });
    try {
      final data = await DatabaseHelper.instance.getInvoicesByUser(
        widget.userId,
      );
      debugPrint(
        'Fetched invoices: ' + data.map((e) => e.toString()).join("\n"),
      );
      setState(() {
        invoices = data;
        filteredInvoices = data; // Initialize filtered list
        isLoading = false; // Hide loading spinner
      });
    } catch (e, stack) {
      debugPrint('Error fetching invoices: $e');
      debugPrint('Stack trace: $stack');
      setState(() {
        isLoading = false;
      });
    }
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

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatter.format(amount);
  }

  Widget _buildInvoiceMetricsSection(List invoices, List quotations) {
    // Calculate metrics
    int totalInvoices = invoices.length;
    int paidInvoices =
        invoices
            .where((inv) => (inv.status?.toUpperCase() ?? '') == 'PAID')
            .length;
    int unpaidInvoices =
        invoices
            .where((inv) => (inv.status?.toUpperCase() ?? '') == 'UNPAID')
            .length;
    double totalRevenue = invoices.fold(
      0.0,
      (sum, inv) => sum + (inv.grandTotal ?? 0),
    );
    int totalQuotations = quotations.length;
    double totalQuotationValue = quotations.fold(
      0.0,
      (sum, q) => sum + (q.totalAmount ?? 0),
    );
    int convertedQuotations =
        quotations
            .where(
              (q) => invoices.any(
                (inv) =>
                    inv.customerName == q.customerName &&
                    inv.totalAmount == q.totalAmount,
              ),
            )
            .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
          child: Text(
            'Invoice & Quotation Metrics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Track your sales and quotation performance',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMetricCard(
                'Total Invoices',
                totalInvoices.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
              SizedBox(width: 18),
              _buildMetricCard(
                'Paid Invoices',
                paidInvoices.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              SizedBox(width: 18),
              _buildMetricCard(
                'Unpaid Invoices',
                unpaidInvoices.toString(),
                Icons.cancel,
                Colors.redAccent,
              ),
              SizedBox(width: 18),
              _buildMetricCard(
                'Total Revenue',
                '\$${totalRevenue.toStringAsFixed(2)}', // Dollar sign
                Icons.attach_money,
                Colors.teal,
              ),
              SizedBox(width: 18),
              _buildMetricCard(
                'Total Quotations',
                totalQuotations.toString(),
                Icons.description,
                Colors.orange,
              ),
              SizedBox(width: 18),
              _buildMetricCard(
                'Quotation Value',
                '\$${totalQuotationValue.toStringAsFixed(2)}', // Dollar sign
                Icons.sticky_note_2,
                Colors.purple,
              ),
              SizedBox(width: 18),
              _buildMetricCard(
                'Quotations Converted',
                convertedQuotations.toString(),
                Icons.swap_horiz,
                Colors.indigo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 160,
        height: 160,
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        DatabaseHelper.instance
            .getAllInvoices()
            .then((data) {
              debugPrint('getAllInvoices: ' + data.toString());
              return data;
            })
            .catchError((e, stack) {
              debugPrint('Error in getAllInvoices: $e');
              debugPrint('Stack: $stack');
              return [];
            }),
        DatabaseHelper.instance
            .getAllQuotations()
            .then((data) {
              debugPrint('getAllQuotations: ' + data.toString());
              return data;
            })
            .catchError((e, stack) {
              debugPrint('Error in getAllQuotations: $e');
              debugPrint('Stack: $stack');
              return [];
            }),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Invoices')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final invoices = snapshot.data![0];
        final quotations = snapshot.data![1];
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
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildInvoiceMetricsSection(invoices, quotations),
              isLoading
                  ? Center(
                    child: CircularProgressIndicator(),
                  ) // Show spinner when loading
                  : filteredInvoices.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No invoices yet!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first invoice to get started.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                                'Date: ${invoice.timestamp.toIso8601String().split('T').first}',
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
                                      invoice.status == 'PAID'
                                          ? Color(0xFF4CAF50)
                                          : Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  invoice.status == 'PAID' ? 'PAID' : 'UNPAID',
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
                            _formatCurrency(invoice.totalAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => InvoiceDetailPage(
                                      invoice: invoice,
                                      role: widget.role ?? 'user',
                                    ),
                              ),
                            );
                            if (result == true) _loadInvoices();
                          },
                        ),
                      );
                    },
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
      },
    );
  }
}
