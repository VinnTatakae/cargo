import 'package:flutter/material.dart';
import 'main_page.dart';
import '../../models/car.dart';
import '../../services/car_service.dart';
import '../../widgets/car_card.dart';

class CarListPage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const CarListPage({super.key, this.categoryId, this.categoryName});

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  final CarService _carService = CarService();

  List<Car> cars = [];
  List<Car> filteredCars = [];
  bool isLoading = true;

  Future<void> fetchCars() async {
    try {
      final result = await _carService.getCars();

      List<Car> temp = result;

      if (widget.categoryId != null) {
        temp = result
            .where((car) => car.categoryId == widget.categoryId)
            .toList();
      }

      setState(() {
        cars = temp;
        filteredCars = temp;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load cars")));
    }
  }

  void searchCars(String query) {
    final results = cars.where((car) {
      final name = car.name.toLowerCase();
      final brand = car.brand.toLowerCase();
      final input = query.toLowerCase();

      return name.contains(input) || brand.contains(input);
    }).toList();

    setState(() {
      filteredCars = results;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCars();
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
        title: Text(widget.categoryName ?? "Car List"),
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
            : Column(
                children: [
                  /// 🔍 SEARCH BAR (UPGRADE)
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search car...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: searchCars,
                    ),
                  ),

                  /// 🔽 LIST
                  Expanded(
                    child: filteredCars.isEmpty
                        ? const Center(child: Text("No cars found"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: filteredCars.length,
                            itemBuilder: (context, index) {
                              return CarCard(car: filteredCars[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
