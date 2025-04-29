import 'package:flutter/material.dart';
import 'screens/quotation_list_page.dart';
import 'screens/invoice_list_page.dart';
import 'views/sidebar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boutique Manager',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Boutique Manager')),
        drawer: Sidebar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Manage Quotations'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuotationListPage()),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Manage Invoices'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InvoiceListPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
