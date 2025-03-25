import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/admin_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/contact_details_screen.dart';
import 'screens/edit_details_screen.dart';
import 'screens/payment_screen.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/admin_login_screen.dart';
import 'provider/cart_provider.dart';
import 'provider/design_provider.dart';
import 'token_storage.dart';

class Constants {
  static const String onboardingKey = 'onboarding_seen';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DesignProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Comfort Zone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/admin': (_) => const AdminScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/categories': (_) => const CategoriesScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/admin-login': (_) => const AdminLoginScreen(),
          '/cart': (_) => const CartScreen(),
          '/order-history': (_) => const OrderHistoryScreen(),
          '/contact-details': (_) => const ContactDetailsScreen(),
          '/edit-details': (_) => const EditDetailsScreen(),
          '/payment': (_) => const PaymentScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _checkAppState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final onboardingSeen = snapshot.data?[Constants.onboardingKey] ?? false;
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        final tokenStorage = TokenStorage();

        return FutureBuilder<String?>(
          future: tokenStorage.getToken(),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final token = tokenSnapshot.data;
            if (!onboardingSeen) {
              return const WelcomeScreen();
            }

            if (isLoggedIn || token != null) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }

  Future<Map<String, bool>> _checkAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        Constants.onboardingKey:
            prefs.getBool(Constants.onboardingKey) ?? false,
        'is_logged_in': FirebaseAuth.instance.currentUser != null,
      };
    } catch (e) {
      debugPrint("Error checking app state: $e");
      return {Constants.onboardingKey: false, 'is_logged_in': false};
    }
  }
}
