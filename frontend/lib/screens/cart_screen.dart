import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty!"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartProvider.cartItems[index];
                    return ListTile(
                      leading: Image.asset(
                        item["image"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item["name"]),
                      subtitle: Text("NPR ${item["price"]}"),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            await cartProvider.removeFromCart(item['id']);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to remove item: $e"),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Total: NPR ${cartProvider.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          cartProvider.totalPrice > 0
                              ? () => Navigator.pushNamed(context, '/payment')
                              : null,
                      child: const Text("Proceed to Payment"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
