import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/cart_provider.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final int amount =
        (cartProvider.totalPrice * 100).toInt(); // Convert NPR to paisa
    final apiService = ApiService();

    return Scaffold(
      appBar: AppBar(title: const Text("Khalti Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed:
              amount > 0
                  ? () async {
                    try {
                      await _redirectToKhaltiPayment(
                        context,
                        cartProvider,
                        apiService,
                        amount,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                  : null,
          child: Text(
            "Pay NPR ${(amount / 100).toStringAsFixed(2)} with Khalti",
          ),
        ),
      ),
    );
  }

  Future<void> _redirectToKhaltiPayment(
    BuildContext context,
    CartProvider cartProvider,
    ApiService apiService,
    int amount,
  ) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cart is empty!")));
      return;
    }

    // Generate a unique transaction ID
    final transactionId =
        "comfort_zone_${DateTime.now().millisecondsSinceEpoch}";
    final user = FirebaseAuth.instance.currentUser;
    final mobile = user?.phoneNumber ?? "9800000000";

    // Construct Khalti payment URL with query parameters
    final khaltiUrl = Uri.parse(
      "https://web.khalti.com/#/payment?"
      "amount=$amount&"
      "mobile=$mobile&"
      "product_identity=$transactionId&"
      "product_name=Comfort Zone Purchase",
    );

    // Launch Khalti payment page
    if (await canLaunchUrl(khaltiUrl)) {
      await launchUrl(khaltiUrl, mode: LaunchMode.externalApplication);

      // After returning, prompt user to confirm payment (manual for now)
      final confirmed = await _showConfirmationDialog(context);
      if (confirmed) {
        try {
          final token = user != null ? await user.getIdToken() : null;
          // Verify payment with backend (you'll need to adjust backend to handle this)
          await apiService.processPayment({
            "transaction_id": transactionId,
            "amount": amount,
            "mobile": mobile,
            "productIdentity": transactionId,
          }, token);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Payment Successful!")));
          await cartProvider.clearCart();
          Navigator.pushNamed(context, '/order-history');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment verification failed: $e")),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Payment not confirmed")));
      }
    } else {
      throw 'Could not launch Khalti payment URL';
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Payment Confirmation"),
                content: const Text("Did you complete the payment on Khalti?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes"),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
