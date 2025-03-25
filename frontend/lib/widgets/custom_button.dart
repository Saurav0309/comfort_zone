import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final Color color;
  final double width;
  final double height;
  final TextStyle textStyle;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Colors.deepOrange,
    this.width = double.infinity,
    this.height = 50.0,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Define the background color of the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(vertical: 12), // Padding inside button
        ),
        child: Text(
          label,
          style: textStyle, // Text style for the button
        ),
      ),
    );
  }
}
