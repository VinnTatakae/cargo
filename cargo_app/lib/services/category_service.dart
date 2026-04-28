import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/token_storage.dart';
import '../models/category.dart';

class CategoryService {
  final String baseUrl = "http://localhost:8080/categories";

  Future<List<Category>> getCategories() async {
    final res = await http.get(Uri.parse(baseUrl));

    List data = jsonDecode(res.body);

    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> createCategory(String name) async {
    final token = await TokenStorage.getToken();

    await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name}),
    );
  }

  Future<void> updateCategory(int id, String name) async {
    final token = await TokenStorage.getToken();

    await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name}),
    );
  }

  Future<void> deleteCategory(int id) async {
    final token = await TokenStorage.getToken();

    await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}