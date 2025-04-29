import 'package:flutter/material.dart';
import '../models/quotation.dart';
import '../db/database_helper.dart';

class QuotationFormPage extends StatefulWidget {
  @override
  _QuotationFormPageState createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  final _formKey = GlobalKey<FormState>();
  String customerName = '';
  List<QuotationItem> items = [];

  final productNameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  void _addItem() {
    final name = productNameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (name.isNotEmpty && quantity > 0 && price > 0) {
      setState(() {
        items.add(
          QuotationItem(productName: name, quantity: quantity, price: price),
        );
        productNameController.clear();
        quantityController.clear();
        priceController.clear();
      });
    }
  }

  void _saveQuotation() async {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      final quotation = Quotation(
        customerName: customerName,
        date: DateTime.now(),
        items: items,
      );
      await DatabaseHelper.instance.insertQuotation(quotation);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Quotation')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Customer Name Section
              Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => customerName = val,
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 20),

              // Add Item Section
              Text(
                'Add Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: Icon(Icons.add),
                label: Text('Add Item'),
              ),
              SizedBox(height: 20),

              // Items List Section
              if (items.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items Added (${items.length}):',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...items.map((item) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text(
                            'Qty: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            'Total: \$${(item.quantity * item.price).toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveQuotation,
                icon: Icon(Icons.save),
                label: Text('Save Quotation'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
