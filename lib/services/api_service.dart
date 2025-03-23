import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'http://localhost:3000'; // Replace with your backend URL

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final response = await http.get(Uri.parse('$baseUrl/cart'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> cartItems = data['cart'] ?? [];
      return List<Map<String, dynamic>>.from(cartItems);
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> processPayment(
    Map<String, dynamic> paymentData, [
    String? token,
  ]) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/verify-payment'),
      headers: headers,
      body: json.encode(paymentData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }
}
