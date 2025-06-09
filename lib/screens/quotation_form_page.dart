import 'package:flutter/material.dart';
import '../models/quotation.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

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
  List<Product> allProducts = [];

  final quantityController = TextEditingController();
  Product? selectedProduct;
  double? selectedProductPrice;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (widget.quotationToEdit != null) {
      customerName = widget.quotationToEdit!.customerName;
      items = List.from(widget.quotationToEdit!.items);
    }
  }

  Future<void> _loadProducts() async {
    allProducts = await DatabaseHelper.instance.getAllProducts();
    setState(() {});
  }

  void _addItem() {
    final product = selectedProduct;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final price = selectedProductPrice ?? 0.0;
    // Prevent adding if product is null, quantity is invalid, or already in the list
    if (product == null || quantity <= 0 || price <= 0) return;
    final alreadyAdded = items.any((item) => item.productName == product.name);
    if (alreadyAdded) return;
    setState(() {
      items.add(
        QuotationItem(
          productName: product.name,
          quantity: quantity,
          price: price,
        ),
      );
      quantityController.clear();
      selectedProduct = null;
      selectedProductPrice = null;
    });
  }

  void _saveQuotation() async {
    if (!_formKey.currentState!.validate() || items.isEmpty) return;
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
    if (mounted)
      Navigator.pop(context, quotation); // Pass the updated quotation back
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                validator:
                    (value) => value!.isEmpty ? 'Enter customer name' : null,
                onChanged: (val) => customerName = val,
              ),
              SizedBox(height: 20),
              Text(
                'Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...items.map((item) {
                int index = items.indexOf(item);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(Icons.shopping_bag, color: Colors.blueAccent),
                    ),
                    title: Text(
                      item.productName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Price: ${item.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.confirmation_number,
                          color: Colors.blueAccent,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Colors.green,
                          ),
                        ),
                        controller: TextEditingController(
                          text:
                              selectedProductPrice != null
                                  ? selectedProductPrice!.toStringAsFixed(2)
                                  : '',
                        ),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        readOnly: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<Product>(
                value: selectedProduct,
                hint: Text('Select Product'),
                items:
                    allProducts
                        .map(
                          (product) => DropdownMenuItem(
                            value: product,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 8),
                                Text(product.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (product) {
                  setState(() {
                    selectedProduct = product;
                    selectedProductPrice = product?.unitPrice;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Product',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  prefixIcon: Icon(Icons.shopping_cart, color: Colors.orange),
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add_circle, color: Colors.blueAccent),
                  label: Text(
                    'Add Product',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Set background to white
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _addItem,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuotation,
                child: Text(
                  widget.quotationToEdit == null
                      ? 'Save Quotation'
                      : 'Update Quotation',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
