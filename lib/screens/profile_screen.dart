import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _populateUserDetails();
  }

  void _populateUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      _nameController.text = userDoc['name'] ?? user.displayName ?? '';
      _emailController.text = userDoc['email'] ?? user.email ?? '';
      setState(() {
        _photoURL = userDoc['photoURL'] ?? user.photoURL;
      });
    }
  }

  Future<void> _saveUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'photoURL': _photoURL,
      }, SetOptions(merge: true));

      await user.updateDisplayName(_nameController.text);
      await user.updateEmail(_emailController.text);
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _goForward() {
    Navigator.pushNamed(context, '/categories');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goForward,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        _photoURL != null
                            ? NetworkImage(_photoURL!)
                            : const AssetImage('lib/assets/default_avatar.jpg')
                                as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Name: ${user?.displayName ?? 'No name'}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Email: ${user?.email ?? 'No email'}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () => Navigator.pushNamed(context, '/order_history'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  _photoURL != null
                      ? NetworkImage(_photoURL!)
                      : const AssetImage('lib/assets/default_avatar.jpg')
                          as ImageProvider,
            ),
            const SizedBox(height: 20),
            _isEditing
                ? Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserDetails,
                      child: const Text('Save'),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Text('Name: ${user?.displayName ?? 'No name'}'),
                    Text('Email: ${user?.email ?? 'No email'}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      child: const Text('Edit Details'),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
