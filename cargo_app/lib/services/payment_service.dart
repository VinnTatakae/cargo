import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = "http://localhost:8080"; // sesuaikan

  Future<void> createPayment({
    required int bookingId,
    required String method,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/payments"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "booking_id": bookingId,
        "method": method,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create payment");
    }
  }
}