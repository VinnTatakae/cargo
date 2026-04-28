import 'package:flutter/material.dart';
import '../models/car.dart';
import '../pages/user/car_detail_page.dart';

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(car.name),
        subtitle: Text(car.brand),
        trailing: Text('Rp ${car.pricePerDay}'),

        // 🔥 INI YANG PENTING
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CarDetailPage(car: car),
            ),
          );
        },
      ),
    );
  }
}