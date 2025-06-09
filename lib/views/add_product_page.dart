import 'package:flutter/material.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _stock = 0;
  String _category = '';
  double _price = 0.0;
  int _restockThreshold = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, int>>(
              future: _getProductMetrics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMetricCard(
                          'Available',
                          '--',
                          Icons.inventory,
                          Colors.blue,
                        ),
                        _buildMetricCard(
                          'Sold',
                          '--',
                          Icons.shopping_cart,
                          Colors.green,
                        ),
                        _buildMetricCard(
                          'Qty Sold',
                          '--',
                          Icons.bar_chart,
                          Colors.purple,
                        ),
                      ],
                    ),
                  );
                }
                final metrics = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMetricCard(
                        'Available',
                        metrics['available'].toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                      _buildMetricCard(
                        'Sold',
                        metrics['sold'].toString(),
                        Icons.shopping_cart,
                        Colors.green,
                      ),
                      _buildMetricCard(
                        'Qty Sold',
                        metrics['totalQtySold'].toString(),
                        Icons.bar_chart,
                        Colors.purple,
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(height: 16), // Extra space above Product Name
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter product name'
                                  : null,
                      onSaved: (value) => _name = value ?? '',
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter stock';
                        if (int.tryParse(value) == null)
                          return 'Enter a valid number';
                        return null;
                      },
                      onSaved:
                          (value) => _stock = int.tryParse(value ?? '0') ?? 0,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter category'
                                  : null,
                      onSaved: (value) => _category = value ?? '',
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter price';
                        if (double.tryParse(value) == null)
                          return 'Enter a valid price';
                        return null;
                      },
                      onSaved:
                          (value) =>
                              _price = double.tryParse(value ?? '0.0') ?? 0.0,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Restock Threshold',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '5',
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter restock threshold';
                        if (int.tryParse(value) == null)
                          return 'Enter a valid number';
                        return null;
                      },
                      onSaved:
                          (value) =>
                              _restockThreshold =
                                  int.tryParse(value ?? '5') ?? 5,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final now = DateTime.now();
                          final product = Product(
                            productId: 'P${now.millisecondsSinceEpoch}',
                            name: _name,
                            category: _category,
                            description: '',
                            imageUrl: '',
                            restockThreshold: _restockThreshold,
                            stockQty: _stock,
                            unitPrice: _price,
                            status: 'active',
                            discontinued: false,
                            expiryDate: null,
                            createdAt: now,
                            createdBy: 'admin',
                            updatedAt: now,
                            updatedBy: 'admin',
                            lastSoldAt: null,
                            totalRevenueGenerated: 0,
                          );
                          // Debug: print product data
                          print(
                            'Attempting to save product: ' +
                                product.toMap().toString(),
                          );
                          final result = await DatabaseHelper.instance
                              .insertProduct(product);
                          // Debug: print result of insert
                          print('Insert result (row id): $result');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Product added!')),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: Text('Add Product'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 140,
        height: 110, // Increased from 80 to 110
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, int>> _getProductMetrics() async {
    final products = await DatabaseHelper.instance.getAllProducts();
    int available = products.fold(0, (sum, p) => sum + p.stockQty);
    int sold = products.fold(
      0,
      (sum, p) => sum + (p.totalRevenueGenerated > 0 ? 1 : 0),
    );
    int totalQtySold = products.fold(0, (sum, p) => sum + p.totalQuantitySold);
    return {'available': available, 'sold': sold, 'totalQtySold': totalQtySold};
  }
}
