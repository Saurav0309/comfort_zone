import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:comfort_zone/token_storage.dart'; // Import the TokenStorage class

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // For loading indicator

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email & password required!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'http://localhost:3000/admin/login',
    ); // Update endpoint

    try {
      final response = await http.post(
        url,
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);
      print('Server Response: $responseData'); // Debugging log

      if (response.statusCode == 200 && responseData['token'] != null) {
        final String token = responseData['token'];

        // Store the token
        TokenStorage tokenStorage = TokenStorage();
        await tokenStorage.saveToken(token);

        // Navigate to the Admin Panel
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Invalid credentials'),
          ),
        );
      }
    } catch (e) {
      print('Error logging in: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong!')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
