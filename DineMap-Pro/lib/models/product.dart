class Product {
  final String productName;
  final double price;
  final String imageUrl;
  final int restaurantID;

  Product({
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.restaurantID,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      restaurantID: json['restaurantID'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'restaurantID': restaurantID,
    };
  }
}
