import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';
  bool _isCodeSent = false;

  // Function to send OTP to the user's phone number
  Future<void> _verifyPhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a phone number.');
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieve or instant verification completed
          await _auth.signInWithCredential(credential);
          Fluttertoast.showToast(msg: 'Phone verification successful!');
          Navigator.pushReplacementNamed(
              context, '/home'); // Navigate to HomeScreen
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
              msg: 'Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isCodeSent = true;
            _verificationId = verificationId;
          });
          Fluttertoast.showToast(msg: 'OTP sent to your phone!');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout callback if OTP is not received
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  // Function to verify the OTP entered by the user
  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter the OTP');
      return;
    }

    try {
      // Create a PhoneAuthCredential with the verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // Sign in with the credential
      await _auth.signInWithCredential(credential);
      Fluttertoast.showToast(msg: 'Phone verification successful!');
      Navigator.pushReplacementNamed(
          context, '/home'); // Navigate to HomeScreen
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid OTP or error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              _isCodeSent
                  ? Column(
                      children: [
                        TextField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'Enter the OTP sent to your phone',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _verifyOTP,
                          child: Text('Verify OTP'),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _verifyPhoneNumber,
                      child: Text('Send OTP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
