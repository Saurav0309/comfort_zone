import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context, listen: false);

    Map<String, List<Map<String, dynamic>>> categoryData = {
      "Chairs": [
        {
          "id": "chair1",
          "name": "Office Chair",
          "image": "lib/assets/chairs/office_chair.webp",
          "price": 4999,
        },
        {
          "id": "chair2",
          "name": "Wooden Chair",
          "image": "lib/assets/chairs/wooden_chair.jpg",
          "price": 3499,
        },
        {
          "id": "chair3",
          "name": "Gaming Chair",
          "image": "lib/assets/chairs/gaming_chair.webp",
          "price": 7999,
        },
      ],
      "Tables": [
        {
          "id": "table1",
          "name": "Dining Table",
          "image": "lib/assets/tables/dining_table.jpg",
          "price": 9999,
        },
        {
          "id": "table2",
          "name": "Coffee Table",
          "image": "lib/assets/tables/coffee_table.jpg",
          "price": 4599,
        },
        {
          "id": "table3",
          "name": "Study Table",
          "image": "lib/assets/tables/study_table.png",
          "price": 6999,
        },
      ],
      "Sofas": [
        {
          "id": "sofa1",
          "name": "Leather Sofa",
          "image": "lib/assets/sofa/leather_sofa.jpg",
          "price": 15999,
        },
        {
          "id": "sofa2",
          "name": "Fabric Sofa",
          "image": "lib/assets/sofa/fabric_sofa.jpeg",
          "price": 12999,
        },
        {
          "id": "sofa3",
          "name": "Recliner Sofa",
          "image": "lib/assets/sofa/recliner_sofa.jpg",
          "price": 19999,
        },
      ],
      "Beds": [
        {
          "id": "bed1",
          "name": "King Size Bed",
          "image": "lib/assets/beds/king_bed.webp",
          "price": 24999,
        },
        {
          "id": "bed2",
          "name": "Queen Size Bed",
          "image": "lib/assets/beds/queen_bed.webp",
          "price": 21999,
        },
        {
          "id": "bed3",
          "name": "Single Bed",
          "image": "lib/assets/beds/single_bed.webp",
          "price": 14999,
        },
      ],
      "Cupboard": [
        {
          "id": "cup1",
          "name": "Sliding Cupboard",
          "image": "lib/assets/cupboard/sliding_cupboard.webp",
          "price": 18999,
        },
        {
          "id": "cup2",
          "name": "Wooden Cupboard",
          "image": "lib/assets/cupboard/wooden_cupboard.jpg",
          "price": 15999,
        },
        {
          "id": "cup3",
          "name": "Glass Cupboard",
          "image": "lib/assets/cupboard/glass_cupboard.jpg",
          "price": 20999,
        },
      ],
    };

    List<Map<String, dynamic>> items = categoryData[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("$category Collection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, "/cart"),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: Column(
              children: [
                Expanded(child: Image.asset(item["image"], fit: BoxFit.cover)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "NPR ${item["price"]}",
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await cartProvider.addToCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${item["name"]} added to cart!"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add to cart: $e")),
                      );
                    }
                  },
                  child: const Text("Add to Cart"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
