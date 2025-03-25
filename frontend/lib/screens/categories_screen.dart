import 'package:flutter/material.dart';
import 'package:comfort_zone/screens/category_screen_detail.dart';
import 'package:comfort_zone/screens/custom_design_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Categories")),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        padding: EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildCategoryItem("Chairs", "lib/assets/chairs_image.jpg", context),
          _buildCategoryItem("Tables", "lib/assets/tables_image.jpg", context),
          _buildCategoryItem("Sofas", "lib/assets/sofas_image.jpg", context),
          _buildCategoryItem("Beds", "lib/assets/beds_image.jpg", context),
          _buildCategoryItem(
            "Custom Design",
            "lib/assets/custom_design_image.jpg",
            context,
          ),
          _buildCategoryItem(
            "Cupboard",
            "lib/assets/cupboard_image.jpg",
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String title,
    String imagePath,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == "Custom Design") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomDesignScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(category: title),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(8),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black, blurRadius: 5)],
            ),
          ),
        ),
      ),
    );
  }
}
