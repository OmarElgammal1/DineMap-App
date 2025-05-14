import 'product.dart';

class Store {
  final int restaurantID;
  final String restaurantName;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String description;
  final List<Product> products;

  Store({
    required this.restaurantID, // Added
    required this.restaurantName,
    required this.address,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.description,
    required this.products,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    var productsList = <Product>[];
    if (json['products'] != null && json['products'] is List) {
      productsList = (json['products'] as List)
          .map((productJson) => Product.fromJson(productJson as Map<String, dynamic>))
          .toList();
    }

    return Store(
      restaurantID: json['restaurantID'] as int? ?? json['id'] as int, // Expect 'id' or 'restaurantID' from backend
      restaurantName: json['restaurantName'] as String? ?? json['name'] as String, // Expect 'restaurantName' or 'name'
      address: json['address'] as String,
      district: json['district'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String, // Expect 'imageUrl' or 'image_url'
      description: json['description'] as String? ?? "No description available.",
      products: productsList,
    );
  }
}