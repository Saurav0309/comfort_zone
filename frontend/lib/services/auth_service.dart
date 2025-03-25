import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign in user
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      logger.e('Error: $e', error: e);
      return null;
    }
  }

  // Register new user with email verification
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      return user;
    } catch (e) {
      logger.e('Error: $e', error: e);
      return null;
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.e('Error: $e', error: e);
    }
  }

  // Handle email link authentication
  Future<void> signInWithEmailLink(String email, String link) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      logger.e("User signed in: ${userCredential.user}");
    } catch (e) {
      logger.e("Error signing in with email link: $e", error: e);
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Function to handle login
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        User? user = await _authService.signInWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please check credentials.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login error: ${e.toString()}')));
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isNotEmpty) {
      await _authService.resetPassword(_emailController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password reset email sent.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter your email to reset password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: _login, child: Text('Login')),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Create an Account'),
              ),
              TextButton(
                onPressed: _resetPassword,
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
