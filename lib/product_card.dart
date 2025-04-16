import 'package:flutter/material.dart';
import 'data.dart';
import 'product_details_screen.dart';

class ProductCard extends StatefulWidget {
  final int id;
  final String productName;
  final String imageUrl;
  final double price;
  final bool isFavorite;
  final String screenType;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;
  final String? size;
  final int? ind;

  ProductCard({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
    required this.screenType,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.size,
    this.ind,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    stores[widget.id]?['isFavorite'] = _isFavorite;
    print(stores[widget.id]?['isFavorite']);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailScreen with the store id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(id: widget.id),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Store Image
                    Image.network(widget.imageUrl,
                        fit: BoxFit.cover, height: 120, width: double.infinity),

                    // Favorite Icon (Top-right corner)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: toggleFavorite,
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                // Store Name and Distance
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.productName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text("${widget.price.toString()} km",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Delete button for Favorites screen
            if (widget.screenType == 'Favorites')
              Positioned(
                bottom: 0,
                right: 50,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (widget.onRemoveFromCart != null)
                      widget.onRemoveFromCart!();
                  },
                ),
              ),
            // Location icon (bottom-right corner)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.directions,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}