import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import '../../services/car_service.dart';
import '../../services/category_service.dart';
import '../../models/car.dart';
import '../../models/category.dart';

class ManageCarPage extends StatefulWidget {
  const ManageCarPage({super.key});

  @override
  State<ManageCarPage> createState() => _ManageCarPageState();
}

class _ManageCarPageState extends State<ManageCarPage> {
  final CarService service = CarService();
  final CategoryService categoryService = CategoryService();

  List<Car> cars = [];
  List<Car> filteredCars = [];
  List<Category> categories = [];

  bool isLoading = true;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchCars();
    fetchCategories(); // 🔥 tambahan
  }

  Future<void> fetchCars() async {
    final data = await service.getCars();
    setState(() {
      cars = data;
      filteredCars = data;
      isLoading = false;
    });
  }

  Future<void> fetchCategories() async {
    final data = await categoryService.getCategories();
    setState(() {
      categories = data;
    });
  }

  void searchCars(String query) {
    final results = cars.where((car) {
      return car.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCars = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
              (route) => false,
            );
          },
        ),
        title: const Text("Manage Cars"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color.fromARGB(255, 90, 88, 88)),
            onPressed: () => showCreateCarDialog(),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search car...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: searchCars,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCars.length,
                      itemBuilder: (context, index) {
                        final car = filteredCars[index];

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(car.name),
                            subtitle: Text(
                              "${car.brand}\nRp ${car.pricePerDay}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    showEditCarDialog(car);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Konfirmasi"),
                                        content: const Text(
                                          "Yakin ingin menghapus mobil ini?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await service.deleteCar(car.id);
                                      fetchCars();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void showCreateCarDialog() {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Car"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: "Brand"),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),

                // 🔥 DROPDOWN CATEGORY (INI YANG PENTING)
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pilih category dulu")),
                  );
                  return;
                }

                try {
                  await service.createCar({
                    "name": nameController.text,
                    "brand": brandController.text,
                    "price_per_day": int.parse(priceController.text),
                    "category_id": selectedCategoryId,
                  });

                  if (!mounted) return;
                  Navigator.pop(context);
                  fetchCars();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void showEditCarDialog(Car car) {
    final nameController = TextEditingController(text: car.name);
    final brandController = TextEditingController(text: car.brand);
    final priceController = TextEditingController(
      text: car.pricePerDay.toString(),
    );

    int? selectedEditCategoryId = car.categoryId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Car"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: "Brand"),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                DropdownButtonFormField<int>(
                  value: selectedEditCategoryId,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedEditCategoryId = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await service.updateCar(car.id, {
                    "name": nameController.text,
                    "brand": brandController.text,
                    "price_per_day": int.parse(priceController.text),
                    "category_id": selectedEditCategoryId,
                  });

                  if (!mounted) return;
                  Navigator.pop(context);
                  fetchCars();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
