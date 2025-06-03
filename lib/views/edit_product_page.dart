import 'package:flutter/material.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _stock;
  late String _category;
  late double _price;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _stock = widget.product.stock;
    _category = widget.product.category;
    _price = widget.product.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
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
                initialValue: _stock.toString(),
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
                initialValue: _category,
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
                initialValue: _price.toStringAsFixed(2),
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
                label: Text('Save Changes'),
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
                    final updatedProduct = Product(
                      id: widget.product.id,
                      name: _name,
                      stock: _stock,
                      category: _category,
                      lastSoldDate: widget.product.lastSoldDate,
                      price: _price,
                    );
                    await DatabaseHelper.instance.updateProduct(updatedProduct);
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
