import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/invoice_list_page.dart'; // or your main home page
import 'screens/admin_dashboard.dart';
import 'screens/user_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') != null &&
        prefs.getString('password') != null;
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boutique Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.blueGrey[50],
      ),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data == true) {
            return FutureBuilder<String?>(
              future: getRole(),
              builder: (context, roleSnapshot) {
                if (!roleSnapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return MainApp(role: roleSnapshot.data ?? 'user');
              },
            );
          }
          return LoginPage();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// This widget is the main app after login. Pass the role to child screens as needed.
class MainApp extends StatelessWidget {
  final String role;
  const MainApp({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'admin') {
      return AdminDashboard();
    } else if (role == 'user') {
      return UserDashboard();
    }
    return InvoiceListPage(role: role); // Example: pass role to home page
  }
}
