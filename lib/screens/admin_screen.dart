import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> users = [];
  final storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String? adminEmail;
  final Map<int, bool> _isPromoting = {};
  final Map<int, bool> _isDeleting = {};

  @override
  void initState() {
    super.initState();
    fetchAdminData();
    fetchUsers();
  }

  Future<String?> _getAdminToken() async {
    final token = await storage.read(key: 'admin_token');
    if (token != null && isTokenExpired(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      Navigator.pushReplacementNamed(context, '/admin-login');
      return null;
    }
    return token;
  }

  bool isTokenExpired(String token) {
    final decodedToken = Jwt.parseJwt(token);
    final exp = decodedToken['exp'];
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return expiryDate.isBefore(DateTime.now());
  }

  Future<void> fetchAdminData() async {
    final token = await _getAdminToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/admin/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          adminEmail = data['admin']['email'];
        });
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    }
  }

  Future<void> fetchUsers() async {
    final token = await _getAdminToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/admin/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> promoteUser(int userId) async {
    setState(() {
      _isPromoting[userId] = true;
    });

    final token = await _getAdminToken();
    if (token == null) {
      setState(() {
        _isPromoting[userId] = false;
      });
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/admin/users/$userId/promote'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User promoted successfully')),
        );
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to promote user: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error promoting user: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPromoting[userId] = false;
      });
    }
  }

  Future<void> deleteUser(int userId) async {
    setState(() {
      _isDeleting[userId] = true;
    });

    final token = await _getAdminToken();
    if (token == null) {
      setState(() {
        _isDeleting[userId] = false;
      });
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/admin/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isDeleting[userId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await storage.delete(key: 'admin_token');
              Navigator.pushReplacementNamed(context, '/admin-login');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Welcome Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Welcome to the Admin Panel',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Logged in as: ${adminEmail ?? "Loading..."}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // User List
                  Expanded(
                    child:
                        users.isEmpty
                            ? const Center(child: Text('No users found.'))
                            : ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final userId = user['id'];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(
                                      user['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user['email'] ?? 'Unknown Email'),
                                        Text(
                                          user['isAdmin'] == 1
                                              ? 'Role: Admin'
                                              : 'Role: User',
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (user['isAdmin'] != 1)
                                          IconButton(
                                            icon:
                                                _isPromoting[userId] == true
                                                    ? const SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    )
                                                    : const Icon(
                                                      Icons.arrow_upward,
                                                    ),
                                            onPressed:
                                                _isPromoting[userId] == true
                                                    ? null
                                                    : () => promoteUser(userId),
                                          ),
                                        IconButton(
                                          icon:
                                              _isDeleting[userId] == true
                                                  ? const SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                  : const Icon(Icons.delete),
                                          onPressed:
                                              _isDeleting[userId] == true
                                                  ? null
                                                  : () => deleteUser(userId),
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
    );
  }
}
