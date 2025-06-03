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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                  if (value == null || value.isEmpty) return 'Enter stock';
                  if (int.tryParse(value) == null)
                    return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _stock = int.tryParse(value ?? '0') ?? 0,
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  if (double.tryParse(value) == null)
                    return 'Enter a valid price';
                  return null;
                },
                onSaved:
                    (value) => _price = double.tryParse(value ?? '0.0') ?? 0.0,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final product = Product(
                      name: _name,
                      stock: _stock,
                      category: _category,
                      lastSoldDate: DateTime.now(),
                      price: _price,
                    );
                    await DatabaseHelper.instance.insertProduct(product);
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
