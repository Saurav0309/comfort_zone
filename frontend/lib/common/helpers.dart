import 'package:flutter/material.dart';

// Show a Snackbar
void showSnackbar(BuildContext context, String message, {Color? backgroundColor}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? Colors.red,
    ),
  );
}

// Validate Email Format
bool isValidEmail(String email) {
  final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegExp.hasMatch(email);
}

// Validate Password Strength
bool isValidPassword(String password) {
  return password.length >= 6; // At least 6 characters
}
