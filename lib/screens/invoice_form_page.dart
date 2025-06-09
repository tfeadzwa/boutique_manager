import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/invoice.dart';
import '../models/product.dart';

class InvoiceFormPage extends StatefulWidget {
  final Invoice? invoiceToEdit;

  InvoiceFormPage({this.invoiceToEdit});

  @override
  _InvoiceFormPageState createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController customerNameController = TextEditingController();
  List<Product> allProducts = [];
  List<InvoiceItem> items = [];
  double totalAmount = 0.0;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (widget.invoiceToEdit != null) {
      customerNameController.text = widget.invoiceToEdit!.customerName;
      items = List<InvoiceItem>.from(widget.invoiceToEdit!.items);
      totalAmount = widget.invoiceToEdit!.totalAmount;
      isPaid = widget.invoiceToEdit!.status == 'Paid';
    }
  }

  Future<void> _loadProducts() async {
    allProducts = await DatabaseHelper.instance.getAllProducts();
    setState(() {});
  }

  void _addInvoiceItem(Product product) {
    setState(() {
      items.add(
        InvoiceItem(
          productId: product.productId,
          productName: product.name,
          quantity: 1,
          unitPrice: product.unitPrice,
          total: product.unitPrice,
        ),
      );
    });
  }

  void _calculateTotal() {
    totalAmount = items.fold(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      _calculateTotal();
      final invoice = Invoice(
        id: widget.invoiceToEdit?.id,
        invoiceId:
            widget.invoiceToEdit?.invoiceId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        cashier: 'Cashier', // Replace with actual user
        customerName: customerNameController.text,
        discount: 0.0,
        grandTotal: totalAmount,
        items: items,
        notes: '',
        paymentMethod: 'Cash',
        soldBy: 'Cashier', // Replace with actual user
        status: isPaid ? 'PAID' : 'UNPAID',
        tax: 0.0,
        timestamp: DateTime.now(),
        totalAmount: totalAmount,
        totalQuantity: items.fold(0, (sum, item) => sum + item.quantity),
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
              Text(
                'Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...items.map((item) {
                int index = items.indexOf(item);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: item.productId,
                          items:
                              allProducts
                                  .map(
                                    (product) => DropdownMenuItem(
                                      value: product.productId,
                                      child: Text(product.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            final selected = allProducts.firstWhere(
                              (p) => p.productId == val,
                            );
                            setState(() {
                              items[index] = InvoiceItem(
                                productId: selected.productId,
                                productName: selected.name,
                                quantity: item.quantity,
                                unitPrice: selected.unitPrice,
                                total: selected.unitPrice * item.quantity,
                              );
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Product',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item.quantity.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  int qty = int.tryParse(val) ?? 1;
                                  setState(() {
                                    items[index] = InvoiceItem(
                                      productId: item.productId,
                                      productName: item.productName,
                                      quantity: qty,
                                      unitPrice: item.unitPrice,
                                      total: item.unitPrice * qty,
                                    );
                                    _calculateTotal();
                                  });
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
                                initialValue: item.unitPrice.toStringAsFixed(2),
                                decoration: InputDecoration(
                                  labelText: 'Unit Price',
                                  border: OutlineInputBorder(),
                                ),
                                enabled: false,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                items.removeAt(index);
                                _calculateTotal();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              DropdownButtonFormField<Product>(
                hint: Text('Add Product'),
                items:
                    allProducts
                        .map(
                          (product) => DropdownMenuItem(
                            value: product,
                            child: Text(product.name),
                          ),
                        )
                        .toList(),
                onChanged: (product) {
                  if (product != null) _addInvoiceItem(product);
                },
              ),
              SizedBox(height: 20),
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
