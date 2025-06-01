// This file implements the user dashboard with a modern UI/UX similar to the admin dashboard.
// It includes dashboard cards and a bottom navigation bar for: Dashboard, Create Invoice, Create Quotation, Invoices, and Profile.
// Each card and tab navigates to the appropriate screen.

import 'package:flutter/material.dart';
import 'invoice_list_page.dart';
import 'quotation_form_page.dart';
import 'invoice_form_page.dart';
import 'user_profile_page.dart';

class UserDashboard extends StatefulWidget {
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    _UserDashboardHome(),
    InvoiceFormPage(),
    QuotationFormPage(),
    InvoiceListPage(role: 'user'),
    UserProfilePage(),
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
            icon: Icon(Icons.receipt_long),
            label: 'Create Invoice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Create Quotation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _UserDashboardHome extends StatelessWidget {
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
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, User!',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your business at a glance',
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
              _UserDashboardCard(
                icon: Icons.receipt_long,
                title: 'Create Invoice',
                color: Colors.green,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InvoiceFormPage()),
                    ),
              ),
              _UserDashboardCard(
                icon: Icons.edit_document,
                title: 'Create Quotation',
                color: Colors.blue,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuotationFormPage()),
                    ),
              ),
              _UserDashboardCard(
                icon: Icons.list_alt,
                title: 'Invoice List',
                color: Colors.orange,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceListPage(role: 'user'),
                      ),
                    ),
              ),
              _UserDashboardCard(
                icon: Icons.person,
                title: 'Profile',
                color: Colors.teal,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserProfilePage()),
                    ),
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
                    'Hello!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Create and manage your invoices and quotations easily. Tap the profile card to update your info or change your password.',
                    style: TextStyle(fontSize: 16, color: Colors.green[700]),
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

class _UserDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _UserDashboardCard({
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
