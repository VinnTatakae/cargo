import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/car.dart';

class ApiService {
  Future<List<Car>> getCars() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/cars"),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }
}