import 'package:flutter/material.dart';
import '../screens/quotation_list_page.dart';
import '../screens/invoice_list_page.dart';
import '../views/product_list_page.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.store, size: 40, color: Colors.green),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Boutique Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your business efficiently',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.dashboard, color: Colors.green),
                    title: Text('Dashboard'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.receipt, color: Colors.green),
                    title: Text('Quotations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QuotationListPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.green),
                    title: Text('Invoices'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => InvoiceListPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.inventory, color: Colors.green),
                    title: Text('Products'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductListPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Divider(),
                  Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Handle upgrade action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Upgrade Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
