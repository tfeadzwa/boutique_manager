import 'package:flutter/material.dart';
import '../models/quotation.dart';
import '../db/database_helper.dart';

class QuotationFormPage extends StatefulWidget {
  final Quotation? quotationToEdit;

  QuotationFormPage({this.quotationToEdit});

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

  @override
  void initState() {
    super.initState();
    if (widget.quotationToEdit != null) {
      customerName = widget.quotationToEdit!.customerName;
      items = List.from(widget.quotationToEdit!.items);
    }
  }

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

  void _editItem(int index) {
    final item = items[index];
    productNameController.text = item.productName;
    quantityController.text = item.quantity.toString();
    priceController.text = item.price.toString();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final updatedName = productNameController.text.trim();
                  final updatedQuantity =
                      int.tryParse(quantityController.text.trim()) ?? 0;
                  final updatedPrice =
                      double.tryParse(priceController.text.trim()) ?? 0.0;

                  if (updatedName.isNotEmpty &&
                      updatedQuantity > 0 &&
                      updatedPrice > 0) {
                    setState(() {
                      items[index] = QuotationItem(
                        productName: updatedName,
                        quantity: updatedQuantity,
                        price: updatedPrice,
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _saveQuotation() async {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      final quotation = Quotation(
        id: widget.quotationToEdit?.id, // Use existing ID if editing
        customerName: customerName,
        date: widget.quotationToEdit?.date ?? DateTime.now(),
        items: items,
      );

      if (widget.quotationToEdit == null) {
        await DatabaseHelper.instance.insertQuotation(quotation);
      } else {
        await DatabaseHelper.instance.updateQuotation(quotation);
      }

      Navigator.pop(context, quotation); // Pass the updated quotation back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quotationToEdit == null ? 'New Quotation' : 'Edit Quotation',
        ),
      ),
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
                initialValue: customerName,
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
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text(
                            'Qty: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editItem(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    items.removeAt(index);
                                  });
                                },
                              ),
                            ],
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
