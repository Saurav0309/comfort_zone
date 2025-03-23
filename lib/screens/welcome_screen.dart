// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for storing flag

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'lib/assets/furniture_logo.jpg',
            ), // Path to the image
            fit: BoxFit.cover, // Ensure the image covers the entire screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome title with black color for better visibility
              Text(
                'Welcome to Comfort Zone!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black color for text
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.white.withOpacity(
                        0.6,
                      ), // Light white shadow for contrast
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Subtitle with black color
              Text(
                'Enjoy the best experience with us!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black, // Black color for text
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.white.withOpacity(
                        0.6,
                      ), // Light white shadow for contrast
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Next button to move to the login screen
              ElevatedButton(
                onPressed: () {
                  // Save flag to SharedPreferences that onboarding has been seen
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool('onboarding_seen', true);
                  });
                  // Navigate to the login screen after clicking "Next"
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ), // Button size
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
