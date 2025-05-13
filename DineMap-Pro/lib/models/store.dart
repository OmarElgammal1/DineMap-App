import 'product.dart';

class Store {
  final String restaurantName;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String description;
  final List<Product> products;

  Store({
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
    if (json['products'] != null) {
      if (json['products'] is List) {
        productsList =
            (json['products'] as List)
                .map(
                  (productJson) =>
                      Product.fromJson(productJson as Map<String, dynamic>),
                )
                .toList();
      }
    }

    return Store(
      restaurantName: json['restaurantName'] as String,
      address: json['address'] as String,
      district: json['district'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      products: productsList,
    );
  }
}
