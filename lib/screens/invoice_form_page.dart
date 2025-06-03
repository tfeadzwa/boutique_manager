import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/invoice.dart';
import '../models/product.dart';

class InvoiceFormPage extends StatefulWidget {
  final Invoice? invoiceToEdit;

  InvoiceFormPage({this.invoiceToEdit}); // 👈 Accept invoiceToEdit!

  @override
  _InvoiceFormPageState createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController customerNameController = TextEditingController();
  List<Product> products = [];
  double totalAmount = 0.0;
  bool isPaid = false; // Add a field to track the "Paid" status

  @override
  void initState() {
    super.initState();
    if (widget.invoiceToEdit != null) {
      // 👈 Pre-fill fields if editing
      customerNameController.text = widget.invoiceToEdit!.customerName;
      products = List<Product>.from(widget.invoiceToEdit!.products);
      totalAmount = widget.invoiceToEdit!.totalAmount;
      isPaid = widget.invoiceToEdit!.isPaid; // Pre-fill "Paid" status
    }
  }

  void _addProduct() {
    setState(() {
      products.add(
        Product(
          id: null,
          name: '',
          stock: 0,
          category: '',
          lastSoldDate: DateTime.now(),
          quantity: 1,
          price: 0.0,
        ),
      );
    });
  }

  void _calculateTotal() {
    totalAmount = products.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate() && products.isNotEmpty) {
      _calculateTotal();

      final invoice = Invoice(
        id: widget.invoiceToEdit?.id, // 👈 Important for updating
        customerName: customerNameController.text,
        products: products,
        items: [], // Not used here
        totalAmount: totalAmount,
        date:
            widget.invoiceToEdit?.date ??
            DateTime.now(), // Keep original date if editing
        isPaid: isPaid, // Save the "Paid" status
      );

      if (widget.invoiceToEdit == null) {
        await DatabaseHelper.instance.insertInvoice(invoice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice created successfully!')),
        );
      } else {
        await DatabaseHelper.instance.updateInvoice(invoice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice updated successfully!')),
        );
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields and add at least one product',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoiceToEdit == null ? 'New Invoice' : 'Edit Invoice',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                controller: customerNameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Enter customer name' : null,
              ),
              SizedBox(height: 20),

              // Products Section
              Text(
                'Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...products.map((product) {
                int index = products.indexOf(product);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: product.name,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => product.name = val,
                          validator:
                              (val) =>
                                  val!.isEmpty ? 'Enter product name' : null,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: product.quantity.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  product.quantity = int.tryParse(val) ?? 1;
                                  _calculateTotal(); // Recalculate total
                                  setState(() {}); // Update UI
                                },
                                validator:
                                    (val) =>
                                        (int.tryParse(val!) ?? 0) <= 0
                                            ? 'Enter quantity'
                                            : null,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: product.price.toStringAsFixed(2),
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  product.price = double.tryParse(val) ?? 0.0;
                                  _calculateTotal(); // Recalculate total
                                  setState(() {}); // Update UI
                                },
                                validator:
                                    (val) =>
                                        (double.tryParse(val!) ?? 0.0) <= 0
                                            ? 'Enter price'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addProduct,
                icon: Icon(Icons.add),
                label: Text('Add Product'),
              ),
              SizedBox(height: 20),

              // Mark as Paid Section
              Text(
                'Invoice Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mark as Paid', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: isPaid,
                    onChanged: (value) {
                      setState(() {
                        isPaid = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveInvoice,
                icon: Icon(Icons.save),
                label: Text(
                  widget.invoiceToEdit == null
                      ? 'Save Invoice'
                      : 'Update Invoice',
                ),
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
