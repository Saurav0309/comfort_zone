import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../cart_service.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  final CartService _cartService = CartService();

  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Fetch cart from backend
  Future<void> fetchCart() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/cart'));
      print('Raw response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is Map<String, dynamic>) {
          _cartItems.clear();
          _cartItems.addAll(
            List<Map<String, dynamic>>.from(data['cart'] ?? []),
          );
          notifyListeners();
        } else {
          print('Invalid response format: $data');
        }
      } else {
        print('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  // Add item to cart
  Future<void> addToCart(Map<String, dynamic> item) async {
    // Ensure item has a unique ID if not already present
    final newItem = Map<String, dynamic>.from(item);
    if (!newItem.containsKey('id')) {
      newItem['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    _cartItems.add(newItem);
    notifyListeners();
    try {
      await _cartService.addToCart(jsonEncode({'item': newItem}));
      print('Add to cart response: 200 - Item added to cart');
    } catch (e) {
      print('Error adding to cart: $e');
      _cartItems.remove(newItem);
      notifyListeners();
      rethrow; // Propagate error for UI feedback
    }
  }

  // Remove item from cart by ID
  Future<void> removeFromCart(String itemId) async {
    final index = _cartItems.indexWhere((item) => item['id'] == itemId);
    if (index == -1) return;

    final item = _cartItems[index];
    _cartItems.removeAt(index);
    notifyListeners();
    try {
      await _cartService.removeFromCart(item);
      print('Remove from cart response: 200 - Item removed');
    } catch (e) {
      print('Error removing from cart: $e');
      _cartItems.insert(index, item);
      notifyListeners();
      rethrow;
    }
  }

  // Calculate total price (in NPR)
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 1.0;
      return sum + (price * quantity);
    });
  }

  // Clear cart after successful payment
  Future<void> clearCart() async {
    final itemsToClear = List.from(_cartItems); // Backup in case of failure
    _cartItems.clear();
    notifyListeners();
    try {
      await _cartService.checkout({'status': 'cleared'});
      print('Cart cleared successfully');
    } catch (e) {
      print('Error clearing cart: $e');
      _cartItems.addAll(itemsToClear as Iterable<Map<String, dynamic>>);
      notifyListeners();
      rethrow;
    }
  }
}
