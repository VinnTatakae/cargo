import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/utils/token_storage.dart';
import '../models/booking.dart';

class AdminBookingService {
  Future<List<Booking>> getAllBookings() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/bookings"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => Booking.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to fetch bookings");
    }
  }

  Future<void> updateBooking(int id, String status) async {
    final token = await TokenStorage.getToken();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/bookings/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "status": status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update booking");
    }
  }

  Future<void> refundBooking(int bookingId) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse('http://localhost:8080/payments/refund/$bookingId'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Refund failed");
    }
  }
}