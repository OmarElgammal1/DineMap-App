import 'package:flutter/material.dart';
import 'custom_widgets/product_card.dart';

import 'models/data.dart';

class FavoritesScreen extends StatelessWidget {
  final String screenType;

  FavoritesScreen({required this.screenType});

  @override
  Widget build(BuildContext context) {
    var storeList =
        stores.entries
            .where((entry) => entry.value['isFavorite'] == true)
            .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 10.0),
          sliver: SliverAppBar(
            title: const Text(
              'Favorites',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            floating: true,
            centerTitle: true,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(15.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              var storeEntry = storeList[index];
              var store = storeEntry.value;

              return ProductCard(
                id: storeEntry.key,
                productName: store['storeName'],
                imageUrl: store['imageUrl'],
                price: store['distance'],
                district: store['district'],
                isFavorite: store['isFavorite'],
                screenType: screenType,
                onAddToCart: () {
                  print('${store['storeName']} selected');
                },
                onRemoveFromCart: () {
                  print('${store['storeName']} removed from favorites');
                },
              );
            }, childCount: storeList.length),
          ),
        ),
      ],
    );
  }
}
