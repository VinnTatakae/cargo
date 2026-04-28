import 'package:flutter/material.dart';

// 🔐 auth
import 'pages/auth/login_user_page.dart';

// 👤 user
import 'pages/user/main_page.dart';

// 👑 admin
import 'pages/admin/admin_dashboard_page.dart';

// 🔑 token
import 'core/utils/token_storage.dart';

import 'pages/auth/choose_role_page.dart';

import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> checkLogin() async {
    final token = await TokenStorage.getToken();
    final userJson = await TokenStorage.getUser();

    // ❌ belum login
    if (token == null || userJson == null) {
      return const ChooseRolePage(); // ✅ FIX
    }

    try {
      final user = jsonDecode(userJson);

      // 🔥 CEK ROLE
      if (user['role'] == 'admin') {
        return const AdminDashboard();
      } else {
        return MainPage();
      }
    } catch (e) {
      // kalau error parsing → balik ke login
      return const LoginUserPage(); // ✅ FIX
    }
  }

  Future<void> goToHome(BuildContext context) async {
    final userJson = await TokenStorage.getUser();

    if (userJson == null) return;

    final user = jsonDecode(userJson);

    if (user['role'] == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: FutureBuilder<Widget>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data!;
        },
      ),
    );
  }
}
