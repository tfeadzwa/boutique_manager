// This file implements the user profile page with options for update, change password, and logout.
// Replace the placeholder email and add logic for profile update and password change as needed.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../models/user.dart';
import 'login_page.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('current_user_username');
    if (username != null) {
      final users = await DatabaseHelper.instance.getAllUsers();
      final user = users.firstWhere(
        (u) => u.username == username,
        orElse: () => User(username: username, password: '', role: 'user'),
      );
      setState(() {
        _user = user;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
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
                if (_formKey.currentState!.validate() && _user != null) {
                  final updatedUser = User(
                    id: _user!.id,
                    username: _user!.username,
                    password: newPassword,
                    role: _user!.role,
                  );
                  await DatabaseHelper.instance.updateUser(updatedUser);
                  setState(() {
                    _user = updatedUser;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated successfully!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final _formKey = GlobalKey<FormState>();
    String username = _user?.username ?? '';
    String email = _user?.email ?? '';
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
                if (_formKey.currentState!.validate() && _user != null) {
                  final updatedUser = User(
                    id: _user!.id,
                    username: username,
                    password: _user!.password,
                    role: _user!.role,
                    email: email,
                  );
                  await DatabaseHelper.instance.updateUser(updatedUser);
                  setState(() {
                    _user = updatedUser;
                  });
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.blueGrey[50],
        appBar: AppBar(
          title: Text('User Profile'),
          backgroundColor: Colors.green,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('User Profile'),
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
                      Icons.person,
                      size: 48,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    _user?.username ?? 'User',
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
                      'Role: ${_user?.role ?? ''}',
                      style: TextStyle(fontSize: 15, color: Colors.green[700]),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _user?.email ?? '',
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
