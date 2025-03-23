import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Only for Android & iOS
import 'dart:typed_data'; // For Web image handling
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final Logger logger = Logger();

class CustomDesignScreen extends StatefulWidget {
  const CustomDesignScreen({super.key});

  @override
  _CustomDesignScreenState createState() => _CustomDesignScreenState();
}

class _CustomDesignScreenState extends State<CustomDesignScreen> {
  XFile? _selectedImage;
  Uint8List? _webImage;
  String? _selectedMaterial;
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = pickedFile;
            _webImage = null;
          });
        }
      }
    } catch (e) {
      logger.e("Error picking image", error: e);
    }
  }

  Future<void> _submitDesign() async {
    if (_selectedMaterial == null ||
        _lengthController.text.isEmpty ||
        _widthController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill in all details")));
      return;
    }

    final designData = {
      'image': kIsWeb ? _webImage : _selectedImage,
      'userId': '123',
      'material': _selectedMaterial,
      'length': _lengthController.text,
      'width': _widthController.text,
      'notes': 'Custom design with specific dimensions',
    };

    try {
      final response = await http.post(
        Uri.parse('https://your-store-api.com/submit-design'),
        body: designData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Design submitted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit design")));
      }
    } catch (e) {
      logger.e("Error submitting design", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Custom Design")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectedImage == null && _webImage == null
                ? Text("No image selected")
                : kIsWeb
                ? Image.memory(_webImage!, height: 100)
                : Image.file(File(_selectedImage!.path), height: 100),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: Text("Pick Image")),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedMaterial,
              hint: Text("Select Material"),
              items:
                  ["Wood", "Metal", "Glass", "Plastic"].map((material) {
                    return DropdownMenuItem(
                      value: material,
                      child: Text(material),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMaterial = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lengthController,
              decoration: InputDecoration(labelText: "Length (cm)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _widthController,
              decoration: InputDecoration(labelText: "Width (cm)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedImage != null || _webImage != null) {
                  _submitDesign();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select an image first")),
                  );
                }
              },
              child: Text("Submit Design"),
            ),
          ],
        ),
      ),
    );
  }
}
