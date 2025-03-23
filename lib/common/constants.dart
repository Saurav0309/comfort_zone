// constants.dart
import 'package:flutter/material.dart';

// Define custom colors for the app
class AppColors {
  static const primaryColor = Colors.blue; // Example primary color
  static const lightBackgroundColor = Colors.white;
  static const darkBackgroundColor = Colors.black;
  static const lightTextColor = Colors.black;
  static const darkTextColor = Colors.white;
}

// Define custom text styles for the app
class AppTextStyles {
  static const headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextColor,
  );
  
  static const bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.lightTextColor,
  );
  
  static const bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.lightTextColor,
  );
}
