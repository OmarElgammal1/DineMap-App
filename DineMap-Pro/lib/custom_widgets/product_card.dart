import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final int id;
  final String productName;
  final String imageUrl;
  final double price;

  const ProductCard({
    super.key,
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column( // This main Column defines the Card's content structure
        crossAxisAlignment: CrossAxisAlignment.start,
        // Removed mainAxisSize: MainAxisSize.min from outer Column
        // because Expanded needs its parent Column to fill available space.
        // If this Card is in a ListView without itemExtent, this could be an issue.
        // However, "bottom overflow" strongly suggests a height-constrained parent.
        children: [
          // Product Image - This takes a fixed height
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 48.0), // Explicit size for error icon
                );
              },
            ),
          ),

          // Product Name and Price section
          // Wrapped the Padding in Expanded so it takes the remaining vertical space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, // Align text to the top of its expanded space
                mainAxisSize: MainAxisSize.min, // The inner column should still be minimal within the expanded space
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2, // Allow product name to wrap up to 2 lines
                    overflow: TextOverflow.ellipsis, // Ellipsis if it's still too long
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${price.toInt()} EGP',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1, // Ensure price stays on one line
                    overflow: TextOverflow.ellipsis, // Ellipsis if it's too long
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}