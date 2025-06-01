import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String _adminName = 'Admin';
  String _email = 'admin@boutique.com';
  String _password = 'admin123'; // Demo only

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('admin_name') ?? 'Admin';
      _email = prefs.getString('admin_email') ?? 'admin@boutique.com';
      _password = prefs.getString('admin_password') ?? 'admin123';
    });
  }

  Future<void> _saveAdminProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_name', _adminName);
    await prefs.setString('admin_email', _email);
    await prefs.setString('admin_password', _password);
  }

  void _showEditProfileDialog() {
    final _formKey = GlobalKey<FormState>();
    String username = _adminName;
    String email = _email;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Edit Profile'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: username,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter username' : null,
                  onChanged: (v) => username = v,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter email' : null,
                  onChanged: (v) => email = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _adminName = username;
                    _email = email;
                  });
                  await _saveAdminProfile();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Profile updated!')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    String newPassword = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Change Password'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
              validator:
                  (v) => v == null || v.isEmpty ? 'Enter new password' : null,
              onChanged: (v) => newPassword = v,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Update'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _password = newPassword;
                  });
                  await _saveAdminProfile();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Password updated!')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Admin Profile'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.green[200],
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    _adminName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Role: admin',
                      style: TextStyle(fontSize: 15, color: Colors.green[700]),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 28),
                  Divider(),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.green[700]),
                    title: Text('Update Profile'),
                    onTap: _showEditProfileDialog,
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.green[700]),
                    title: Text('Change Password'),
                    onTap: _showChangePasswordDialog,
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout'),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('current_user_username');
                      await prefs.remove('username');
                      await prefs.remove('password');
                      await prefs.remove('role');
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
