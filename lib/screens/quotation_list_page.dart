import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/quotation.dart';
import 'quotation_form_page.dart';

class QuotationListPage extends StatefulWidget {
  @override
  _QuotationListPageState createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  List<Quotation> quotations = [];
  List<Quotation> filteredQuotations = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuotations();
    searchController.addListener(_filterQuotations);
  }

  Future<void> _loadQuotations() async {
    final data = await DatabaseHelper.instance.getAllQuotations();
    setState(() {
      quotations = data;
      filteredQuotations = data; // Initialize filtered list
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quotations')),
      body: Column(
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
                      child: Text(
                        'No quotations available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuotationFormPage(),
                                    ),
                                  );
                                  _loadQuotations(); // Reload after editing
                                } else if (value == 'delete') {
                                  _confirmDelete(context, q.id!);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                            ),
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
