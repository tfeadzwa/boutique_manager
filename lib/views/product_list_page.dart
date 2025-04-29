import 'package:flutter/material.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

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

  Future<void> _addSampleProduct() async {
    final newProduct = Product(
      name: 'T-shirt',
      stock: 15,
      reorderLevel: 5,
      lastSoldDate: DateTime.now(),
    );
    await DatabaseHelper.instance.insertProduct(newProduct);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return ListTile(
            title: Text(p.name),
            subtitle: Text(
              'Stock: ${p.stock} | Reorder Level: ${p.reorderLevel}',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
