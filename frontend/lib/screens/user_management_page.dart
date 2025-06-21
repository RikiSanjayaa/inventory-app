import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchUsers();
  }

  Future<void> getCurrentUser() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      setState(() {
        currentUserId = userData['User']['id'].toString();
      });
    }
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        users = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        isLoading = false;
      });
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/users/$userId/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': newRole}),
    );

    if (response.statusCode == 200) {
      fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User role updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/users/$userId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'is_active': isActive}),
    );

    if (response.statusCode == 200) {
      fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('User ${isActive ? 'enabled' : 'disabled'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      await fetchUsers(); // Wait for fetchUsers to complete
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isAdmin = user['role'] == 'admin';
                  final userId = user['id'].toString();
                  final isCurrentUser = userId == currentUserId;

                  return Card(
                    child: ListTile(
                      title: Text(user['username']),
                      subtitle: Text('Role: ${user['role']}'),
                      trailing: isAdmin || isCurrentUser
                          ? const Text('No actions available')
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Toggle active status
                                IconButton(
                                  icon: Icon(
                                    user['is_active']
                                        ? Icons.block
                                        : Icons.check_circle,
                                    color: user['is_active']
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  onPressed: () => toggleUserStatus(
                                      userId, !user['is_active']),
                                  tooltip: user['is_active']
                                      ? 'Disable user'
                                      : 'Enable user',
                                ),
                                // Promote to admin
                                IconButton(
                                  icon: const Icon(Icons.admin_panel_settings),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text('Confirm Role Change'),
                                        content: Text(
                                            'Are you sure you want to promote ${user['username']} to admin?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              updateUserRole(userId, 'admin');
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Promote'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  tooltip: 'Promote to admin',
                                ),
                                // Delete user
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: Text(
                                            'Are you sure you want to delete ${user['username']}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteUser(userId);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  tooltip: 'Delete user',
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
