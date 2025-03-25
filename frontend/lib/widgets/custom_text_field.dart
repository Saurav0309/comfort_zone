import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final Icon? icon;
  final TextInputType inputType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.icon,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText, // Hide text for password fields
      keyboardType: inputType, // Define the keyboard type (e.g., email, number)
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Rounded borders
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
