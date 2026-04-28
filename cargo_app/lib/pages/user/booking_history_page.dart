import 'package:flutter/material.dart';
import 'main_page.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';

class BookingHistoryPage extends StatefulWidget {
  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();

  List<Booking> bookings = [];
  bool isLoading = true;

  Set<int> paidBookings = {};

  Future<void> fetchBookings() async {
    try {
      final result = await _bookingService.getBookings();

      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> payBooking(int bookingId) async {
    try {
      await _paymentService.createPayment(
        bookingId: bookingId,
        method: "transfer",
      );

      setState(() {
        paidBookings.add(bookingId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment success")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Already paid")));
    }
  }

  Future<void> confirmPay(int bookingId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: const Text("Pay this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Pay"),
          ),
        ],
      ),
    );

    if (confirm == true) payBooking(bookingId);
  }

  Future<void> cancelBooking(int id) async {
    try {
      await _bookingService.cancelBooking(id);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking cancelled")));

      fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cancel failed")));
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text("Booking History"),
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

        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookings.isEmpty
            ? const Center(child: Text("No bookings yet"))
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  final isPaid = paidBookings.contains(b.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Booking ID: ${b.id}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 5),

                        Text("${b.startDate} - ${b.endDate}"),
                        Text("Rp ${b.totalPrice}"),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b.status,
                              style: TextStyle(
                                color: getStatusColor(b.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Row(
                              children: [
                                if (b.status == "pending" && !isPaid)
                                  ElevatedButton(
                                    onPressed: () => confirmPay(b.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text("Pay"),
                                  ),

                                if (isPaid)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      "Paid",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                const SizedBox(width: 8),

                                if (b.status == "pending")
                                  ElevatedButton(
                                    onPressed: () => cancelBooking(b.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
