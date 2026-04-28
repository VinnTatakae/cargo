import 'dart:convert';
import 'package:flutter/material.dart';
import 'main_page.dart';
import '../../core/utils/token_storage.dart';
import '../auth/choose_role_page.dart'; // 🔥 ganti ke ini

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String role = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? userJson = await TokenStorage.getUser();

    if (userJson != null) {
      final user = jsonDecode(userJson);

      setState(() {
        name = user["name"] ?? "";
        email = user["email"] ?? "";
        role = user["role"] ?? "";
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    await TokenStorage.clearUser();

    // 🔥 FIX: arahkan ke Choose Role Page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ChooseRolePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => MainPage()),
              (route) => false,
            );
          },
        ),
        title: const Text("Profile")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name),
                  Text(email),
                  Text(role),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
    );
  }
}
