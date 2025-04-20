import 'package:flutter/material.dart';
import 'custom_widgets/product_card.dart';

import 'models/data.dart';

class WishlistScreen extends StatelessWidget {
  final String screenType;

  WishlistScreen({required this.screenType});

  @override
  Widget build(BuildContext context) {
    var storeList =
        stores.entries
            .where((entry) => entry.value['isFavorite'] == true)
            .toList();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GridView.builder(
        itemCount: storeList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0, // Add spacing between columns
          mainAxisSpacing: 10.0, // Add spacing between rows
          childAspectRatio:
              0.75, // Adjust aspect ratio if needed (width / height)
        ),
        itemBuilder: (context, index) {
          var storeEntry = storeList[index];
          var store = storeEntry.value;

          return ProductCard(
            id: storeEntry.key,
            productName: store['storeName'],
            imageUrl: store['imageUrl'],
            price: store['distance'],
            isFavorite: store['isFavorite'],
            screenType: screenType,
            onAddToCart: () {
              print('${store['storeName']} selected');
            },
            onRemoveFromCart: () {
              print('${store['storeName']} removed from favorites');
            },
          );
        },
      ),
    );
  }
}
