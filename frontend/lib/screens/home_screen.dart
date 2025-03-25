import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  void _navigateTo(BuildContext context, String route) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushNamed(context, route);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<String?> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      return doc.data()?['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
                : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _navigateTo(context, '/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _navigateTo(context, '/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Guest"),
            accountEmail: Text(user?.email ?? "Not Logged In"),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child:
                  user?.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: "Profile",
            route: '/profile',
          ),
          if (user?.email == 'admin@example.com') // Show only for admin users
            _buildDrawerItem(
              context: context,
              icon: Icons.admin_panel_settings,
              title: "Admin Panel",
              route: '/admin',
            ),
          _buildDrawerItem(
            context: context,
            icon: Icons.history,
            title: "Order History",
            route: '/order-history',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.contact_mail,
            title: "Contact Details",
            route: '/contact-details',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.edit,
            title: "Edit Details",
            route: '/edit-details',
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _navigateTo(context, route),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'lib/assets/logo.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Placeholder(),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Comfort Zone!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Design your home in an attractive way. Customize your furniture, choose colors, and make it truly yours!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateTo(context, '/categories'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Browse Categories'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
