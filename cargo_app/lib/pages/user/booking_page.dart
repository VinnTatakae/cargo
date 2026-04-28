import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_page.dart';
import '../../models/car.dart';
import '../../core/utils/token_storage.dart';
import '../../services/payment_service.dart';

class BookingPage extends StatefulWidget {
  final Car car;

  const BookingPage({super.key, required this.car});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? startDate;
  DateTime? endDate;

  int? bookingId;
  bool isBooked = false;

  final PaymentService paymentService = PaymentService();

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> submitBooking() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select dates")));
      return;
    }

    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse('http://localhost:8080/bookings'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "car_id": widget.car.id,
        "start_date": startDate!.toIso8601String().split('T')[0],
        "end_date": endDate!.toIso8601String().split('T')[0],
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      setState(() {
        bookingId = data['booking_id'];
        isBooked = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking success")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking failed")));
    }
  }

  Future<void> payNow() async {
    try {
      await paymentService.createPayment(
        bookingId: bookingId!,
        method: "transfer",
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment success")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => MainPage()),
              (route) => false,
            );
          },
        ),
        title: Text("Booking ${car.name}"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),

              child: Column(
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: pickStartDate,
                    child: Text(
                      startDate == null
                          ? "Select Start Date"
                          : startDate.toString().split(' ')[0],
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: pickEndDate,
                    child: Text(
                      endDate == null
                          ? "Select End Date"
                          : endDate.toString().split(' ')[0],
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (!isBooked)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                        ),
                        child: const Text("Book Now"),
                      ),
                    ),

                  if (isBooked)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: payNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text("Pay Now"),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
