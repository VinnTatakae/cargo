import 'package:flutter/material.dart';
import '../../services/admin_booking_service.dart';
import '../../models/booking.dart';

class ManageBookingPage extends StatefulWidget {
  const ManageBookingPage({super.key});

  @override
  State<ManageBookingPage> createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends State<ManageBookingPage> {
  final AdminBookingService service = AdminBookingService();

  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final data = await service.getAllBookings();
      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> refundBooking(int bookingId) async {
    try {
      await service.refundBooking(bookingId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Refund success")));

      fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Refund failed")));
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await service.updateBooking(id, status);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking $status")));

      fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update status")));
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookings.isEmpty
            ? const Center(child: Text("No bookings"))
            : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text("User ID: ${b.userId}"),
                      subtitle: Text("Car: ${b.carId}\nRp ${b.totalPrice}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            b.status,
                            style: TextStyle(
                              color: getStatusColor(b.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ✅ APPROVE
                          if (b.status == "pending")
                            ElevatedButton(
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm"),
                                    content: const Text(
                                      "Approve this booking?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Approve"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  updateStatus(b.id, "approved");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("Approve"),
                            ),

                          const SizedBox(width: 5),

                          // ❌ REJECT
                          if (b.status == "pending")
                            ElevatedButton(
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm"),
                                    content: const Text("Reject this booking?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Reject"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  updateStatus(b.id, "rejected");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Reject"),
                            ),

                          const SizedBox(width: 5),

                          // 🔥 REFUND
                          if ((b.status == "rejected" ||
                                  b.status == "cancelled") &&
                              (b.paymentStatus ?? "") == "paid")
                            ElevatedButton(
                              onPressed: () => refundBooking(b.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text("Refund"),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
