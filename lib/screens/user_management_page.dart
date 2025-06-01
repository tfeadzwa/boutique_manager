import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import 'quotation_list_page.dart';
import 'invoice_list_page.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showUserDialog({User? user}) {
    final _formKey = GlobalKey<FormState>();
    String username = user?.username ?? '';
    String password = user?.password ?? '';
    String role = user?.role ?? 'user';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(user == null ? 'Add User' : 'Edit User'),
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
                  initialValue: password,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter password' : null,
                  onChanged: (v) => password = v,
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) => role = v ?? 'user',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(user == null ? 'Add' : 'Update'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (user == null) {
                    await DatabaseHelper.instance.insertUser(
                      User(username: username, password: password, role: role),
                    );
                  } else {
                    await DatabaseHelper.instance.updateUser(
                      User(
                        id: user.id,
                        username: username,
                        password: password,
                        role: role,
                      ),
                    );
                  }
                  Navigator.pop(context);
                  _fetchUsers();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showUserDialog(),
            tooltip: 'Add User',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? Center(child: Text('No users found.'))
              : ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: _users.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final user = _users[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(
                          user.role == 'admin'
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Role: ${user.role}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.description,
                              color: Colors.deepPurple,
                            ),
                            tooltip: 'View Quotations',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => QuotationListPage(userId: user.id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.receipt_long,
                              color: Colors.orange,
                            ),
                            tooltip: 'View Invoices',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => InvoiceListPage(
                                        userId: user.id,
                                        role: 'admin',
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUserDialog(user: user),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: Text('Delete User'),
                                      content: Text(
                                        'Are you sure you want to delete this user?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () => Navigator.pop(ctx),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Text('Delete'),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            _deleteUser(user.id!);
                                          },
                                        ),
                                      ],
                                    ),
                              );
                            },
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () => _showUserDialog(),
        tooltip: 'Add User',
      ),
    );
  }
}
