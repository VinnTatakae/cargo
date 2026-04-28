class Car {
  final int id;
  final String name;
  final String brand;
  final int pricePerDay;
  final String image;
  final int categoryId;
  final String? categoryName;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.image,
    required this.categoryId,
    required this.categoryName,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      pricePerDay: int.tryParse(json['price_per_day'].toString()) ?? 0,
      image: json['image'] ?? '',
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,

      /// 🔥 INI YANG KURANG
      categoryName: json['category_name'],
    );
  }
}