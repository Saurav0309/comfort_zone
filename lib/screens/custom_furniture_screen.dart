import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class CustomFurnitureScreen extends StatefulWidget {
  const CustomFurnitureScreen({super.key});

  @override
  _CustomFurnitureScreenState createState() => _CustomFurnitureScreenState();
}

class _CustomFurnitureScreenState extends State<CustomFurnitureScreen> {
  String _selectedMaterial = "Wood";
  double _size = 1.0;

  // Firebase save function
  void saveDesign(String material, double size) {
    FirebaseFirestore.instance
        .collection('furniture_designs')
        .add({
          'material': material,
          'size': size,
          'userId': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((value) {
          logger.i("Design saved successfully!");
        })
        .catchError((error) {
          logger.e("Failed to save design", error: e);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Custom Furniture Design"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Select Material:", style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _selectedMaterial,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMaterial = newValue!;
                });
              },
              items:
                  <String>[
                    'Wood',
                    'Metal',
                    'Glass',
                    'Plastic',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),
            Text("Adjust Size:", style: TextStyle(fontSize: 18)),
            Slider(
              value: _size,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              onChanged: (double value) {
                setState(() {
                  _size = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Size: ${_size.toStringAsFixed(1)} m",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveDesign(_selectedMaterial, _size);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Design submitted!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange, // Define the button color
              ),
              child: Text("Submit Design"),
            ),
          ],
        ),
      ),
    );
  }
}
