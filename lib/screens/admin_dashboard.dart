import 'package:flutter/material.dart';
import 'invoice_list_page.dart';
import 'quotation_list_page.dart';
import 'invoice_form_page.dart';
import 'quotation_form_page.dart';
import '../views/product_list_page.dart';
import 'user_management_page.dart';
import 'admin_profile_page.dart'; // Import the admin profile page
import '../models/product.dart'; // Import the Product model
import '../db/database_helper.dart'; // Import the database helper

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    _DashboardHome(),
    InvoiceFormPage(),
    QuotationFormPage(),
    ProductListPage(),
    AdminProfilePage(), // Add profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Create Invoice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Create Quotation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  List<Product> _lowStockProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLowStockProducts();
  }

  Future<void> _fetchLowStockProducts() async {
    final products = await DatabaseHelper.instance.getLowStockProducts();
    setState(() {
      _lowStockProducts = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[50],
      child: ListView(
        padding: EdgeInsets.fromLTRB(24, 48, 24, 24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.green,
                child: Icon(Icons.store, size: 40, color: Colors.white),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boutique Manager',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your business efficiently',
                    style: TextStyle(color: Colors.green[400], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _DashboardCard(
                icon: Icons.receipt,
                title: 'Quotations',
                color: Colors.blue,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuotationListPage()),
                    ),
              ),
              _DashboardCard(
                icon: Icons.attach_money,
                title: 'Invoices',
                color: Colors.green,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceListPage(role: 'admin'),
                      ),
                    ),
              ),
              _DashboardCard(
                icon: Icons.inventory,
                title: 'Products',
                color: Colors.orange,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductListPage()),
                    ),
              ),
              _DashboardCard(
                icon: Icons.people,
                title: 'Users',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagementPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 32),
          Card(
            color: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Use the navigation below to manage quotations, invoices, and products. Upgrade to Pro for more features!',
                    style: TextStyle(fontSize: 16, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ),
          if (_loading) Center(child: CircularProgressIndicator()),
          if (!_loading && _lowStockProducts.isNotEmpty)
            Card(
              color: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock Alert',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The following products are low in stock (< 5):',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          ..._lowStockProducts.map(
                            (p) => Text(
                              '- ${p.name} (Stock: ${p.stock})',
                              style: TextStyle(color: Colors.red[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 40,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
