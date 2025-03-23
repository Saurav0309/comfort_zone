import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({super.key, required this.verificationId});

  @override
  // ignore: library_private_types_in_public_api
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();
  String _smsCode = '';

  // Function to handle OTP sign in
  Future<void> _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId:
            widget
                .verificationId, // Use the verificationId passed from previous screen
        smsCode: _smsCode,
      );

      await _auth.signInWithCredential(credential);
      Fluttertoast.showToast(msg: "Phone number verified and signed in!");
      Navigator.pushReplacementNamed(
        context,
        '/home',
      ); // Replace with your home screen route
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to sign in with OTP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // OTP Input Field
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _smsCode = value;
                });
              },
            ),
            SizedBox(height: 20),
            // Verify OTP Button
            ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
