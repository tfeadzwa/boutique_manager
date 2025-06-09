import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'invoice_list_page.dart';
import 'quotation_list_page.dart';

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
    InvoiceListPage(role: 'admin'), // Show invoice list first
    QuotationListPage(), // Use the Quotation List screen instead of the form
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

  // Demo data for charts
  final List<BarChartGroupData> _productBarData = [
    BarChartGroupData(
      x: 0,
      barRods: [BarChartRodData(toY: 30, color: Colors.blue)],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [BarChartRodData(toY: 12, color: Colors.green)],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [BarChartRodData(toY: 18, color: Colors.orange)],
    ),
    BarChartGroupData(
      x: 3,
      barRods: [BarChartRodData(toY: 8, color: Colors.purple)],
    ),
  ];
  final List<String> _productLabels = [
    'Dresses',
    'Shoes',
    'Bags',
    'Accessories',
  ];

  final List<PieChartSectionData> _invoicePieData = [
    PieChartSectionData(
      value: 40,
      color: Colors.green,
      title: 'Paid',
      radius: 38,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      value: 20,
      color: Colors.redAccent,
      title: 'Unpaid',
      radius: 34,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ];

  final List<FlSpot> _quotationLineData = [
    FlSpot(1, 2),
    FlSpot(2, 3),
    FlSpot(3, 1.5),
    FlSpot(4, 4),
    FlSpot(5, 3.5),
    FlSpot(6, 5),
  ];

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

  Widget _buildProductMetricsSection() {
    return FutureBuilder<List<Product>>(
      future: DatabaseHelper.instance.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('Error loading product metrics')),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No product data available')),
          );
        }
        final products = snapshot.data!;
        int available = products.fold(0, (sum, p) => sum + p.stockQty);
        int sold = products.fold(
          0,
          (sum, p) => sum + (p.totalRevenueGenerated > 0 ? 1 : 0),
        );
        int totalQtySold = products.fold(
          0,
          (sum, p) => sum + p.totalQuantitySold,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
              child: Text(
                'Product Metrics Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Text(
                'Monitor your product performance at a glance',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricCard(
                    'Products Available',
                    available.toString(),
                    Icons.inventory,
                    Colors.blue,
                  ),
                  SizedBox(width: 18),
                  _buildMetricCard(
                    'Products Sold',
                    sold.toString(),
                    Icons.shopping_cart,
                    Colors.green,
                  ),
                  SizedBox(width: 18),
                  _buildMetricCard(
                    'Total Quantity Sold',
                    totalQtySold.toString(),
                    Icons.bar_chart,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 160, // Reduced width
        height: 160, // Reduced height
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32), // Slightly smaller icon
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22, // Slightly smaller text
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, // Slightly smaller label
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Categories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: _productBarData,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  idx >= 0 && idx < _productLabels.length
                                      ? _productLabels[idx]
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: EdgeInsets.only(right: 8),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoices',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            sections: _invoicePieData,
                            centerSpaceRadius: 24,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: EdgeInsets.only(left: 8),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quotations (Monthly)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _quotationLineData,
                                isCurved: true,
                                color: Colors.blueAccent,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      'M${value.toInt()}',
                                      style: TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
      ],
    );
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
                    'Use the navigation below to manage quotations, invoices, and products',
                    style: TextStyle(fontSize: 16, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
                letterSpacing: 0.5,
              ),
            ),
          ),
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
          SizedBox(height: 24),
          _buildProductMetricsSection(),
          _buildChartsSection(),
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
                              '- ${p.name} (Stock: ${p.stockQty})',
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
