import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helpers.dart';

class AuthUtil {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  static Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(
        context,
        'Error signing in: $e',
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  // Register new account
  static Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      showSnackbar(
        context,
        'Error registering: $e',
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  // Log out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
