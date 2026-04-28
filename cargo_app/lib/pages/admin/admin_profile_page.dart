import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/token_storage.dart';
import '../auth/choose_role_page.dart'; // 🔥 ganti ke ini

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userJson = await TokenStorage.getUser();

    if (userJson != null) {
      setState(() {
        user = jsonDecode(userJson);
      });
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    await TokenStorage.clearUser();

    // Logout diarahkan ke Choose Role Page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ChooseRolePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings, size: 70),
              const SizedBox(height: 20),

              Text("Name: ${user!['name']}"),
              Text("Email: ${user!['email']}"),
              Text("Role: ${user!['role']}"),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
