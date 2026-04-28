class Booking {
  final int id;
  final int userId;
  final int carId;
  final String startDate;
  final String endDate;
  final int totalPrice;
  final String status;
  final String? paymentStatus;

  Booking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.paymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      carId: int.tryParse(json['car_id'].toString()) ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalPrice: int.tryParse(json['total_price'].toString()) ?? 0,
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'],
    );
  }
}