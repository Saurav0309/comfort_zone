import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl = 'http://localhost:3000';

  Future<void> addToCart(String itemJson) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-to-cart'),
      headers: {'Content-Type': 'application/json'},
      body: itemJson,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add item to cart');
    }
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final response = await http.get(Uri.parse('$baseUrl/cart'));
    if (response.statusCode == 200) {
      Map<String, dynamic> cartData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(cartData['cart']);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> removeFromCart(Map<String, dynamic> item) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/remove-from-cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item': item}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from cart');
    }
  }

  Future<void> checkout(Map<String, dynamic> paymentInfo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'paymentInfo': paymentInfo}),
    );
    if (response.statusCode != 200) {
      throw Exception('Checkout failed');
    }
  }
}
