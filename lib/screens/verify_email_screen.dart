import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  bool _isLoading = false;
  late Timer _timer;
  int _retryCount = 0;
  final int _maxRetries = 10;

  @override
  void initState() {
    super.initState();
    _isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (!_isEmailVerified) {
      _startVerificationCheck();
    }
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_retryCount >= _maxRetries) {
        _timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification check timed out.')),
        );
        return;
      }
      _retryCount++;
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user found. Please log in again.')),
      );
      return;
    }

    await user.reload();
    setState(() {
      _isEmailVerified = user.emailVerified;
    });

    if (_isEmailVerified) {
      _timer.cancel();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() => _isLoading = true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found. Please log in again.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error sending email. Try again later.';
      if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isEmailVerified
                  ? 'Email verified! Redirecting...'
                  : 'A verification email has been sent to your email. Please verify to continue.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resendVerificationEmail,
                    child: Text('Resend Email'),
                  ),
          ],
        ),
      ),
    );
  }
}
