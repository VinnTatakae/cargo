import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/utils/token_storage.dart';

class AuthService {
  // 🔹 LOGIN
  Future<bool> login(String email, String password) async {
    final cleanedEmail = email.trim();
    final cleanedPassword = password.trim();

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": cleanedEmail, "password": cleanedPassword}),
    );

    print("LOGIN REQUEST: $cleanedEmail");
    print("LOGIN RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String token = data["token"];
      var user = data["user"];

      await TokenStorage.saveToken(token);
      await TokenStorage.saveUser(jsonEncode(user));

      return true;
    } else {
      print("LOGIN FAILED: ${response.statusCode}");
      return false;
    }
  }

  // 🔹 REGISTER
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final cleanedEmail = email.trim();
    final cleanedPassword = password.trim();
    final cleanedName = name.trim();

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": cleanedEmail,
        "password": cleanedPassword,
        "name": cleanedName,
        "role": "user",
      }),
    );

    print("REGISTER REQUEST: $cleanedEmail");
    print("REGISTER RESPONSE: ${response.body}");

    if (response.statusCode == 201) {
      return true;
    } else {
      print("REGISTER FAILED: ${response.statusCode}");
      return false;
    }
  }
}
