import 'package:flutter/material.dart';
import '../models/product.dart';
import '../db/database_helper.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage()),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductPage(product: product)),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete Product?'),
            content: Text('Are you sure you want to delete "${product.name}"?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteProduct(product.id!);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
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
          SizedBox(height: 16),
          Expanded(
            child:
                _products.isEmpty
                    ? Center(
                      child: Text(
                        'No products found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: Colors.orange.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.inventory,
                                    color: Colors.orange[700],
                                    size: 32,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            p.category,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: Colors.green[700],
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            ' 24${p.unitPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory_2,
                                            size: 16,
                                            color: Colors.blue[700],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Stock: ${p.stockQty}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                        size: 26,
                                      ),
                                      tooltip: 'Edit',
                                      onPressed: () => _editProduct(p),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                        size: 26,
                                      ),
                                      tooltip: 'Delete',
                                      onPressed: () => _deleteProduct(p),
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        icon: Icon(Icons.add),
        label: Text('Add Product'),
        backgroundColor: Colors.orange,
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
        height: 110,
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
