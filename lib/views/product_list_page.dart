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
      body:
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
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Icon(Icons.inventory, color: Colors.orange[800]),
                      ),
                      title: Text(
                        p.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Stock: ${p.stock}\nCategory: ${p.category}\nPrice: ₹${p.price.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit',
                            onPressed: () => _editProduct(p),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => _deleteProduct(p),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        icon: Icon(Icons.add),
        label: Text('Add Product'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
