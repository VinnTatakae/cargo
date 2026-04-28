import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/booking.dart';
import '../core/utils/token_storage.dart';

class BookingService {
  /// 🔹 GET BOOKINGS
  Future<List<Booking>> getBookings() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/bookings"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load bookings");
    }
  }

  /// 🔥 CANCEL BOOKING
  Future<void> cancelBooking(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/bookings/$id/cancel"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel booking");
    }
  }
}