import 'product.dart';
import '../models/data.dart'; // Assuming 'stores' (Map<int, Map<String, dynamic>>) is exported from here

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

  /// Creates a [Store] instance from a store ID by looking up in the global [stores] data.
  ///
  /// Returns `null` if the store with the given [id] is not found.
  /// Assumes that `data.dart` exports a `Map<int, Map<String, dynamic>> stores`.
  static Store? getStoreById(int id) {
    // 'stores' is assumed to be the Map<int, Map<String, dynamic>> from data.dart
    final Map<String, dynamic>? storeJson = stores[id];
    if (storeJson != null) {
      return Store.fromJson(storeJson);
    }
    return null;
  }
}
