import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import '../core/config/api_config.dart';
import '../core/utils/token_storage.dart';

class CarService {
  Future<List<Car>> getCars() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/cars"),
    );

    if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List data = decoded is List ? decoded : decoded['data'];
    return data.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch cars");
    }
  }

  Future<void> createCar(Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/cars"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create car");
    }
  }

  Future<void> updateCar(int id, Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/cars/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update car");
    }
  }

  Future<void> deleteCar(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/cars/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete car");
    }
  }
}