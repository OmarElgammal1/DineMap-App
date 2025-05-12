import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_widgets/store_card.dart';
import 'providers/store_provider.dart';

class FavoritesScreen extends StatelessWidget {
  final String screenType;

  FavoritesScreen({required this.screenType});

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    var favoriteStores = storeProvider.favoriteStores;
    var storeList = favoriteStores.entries.toList();

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
              int id = storeEntry.key;

              // Calculate distance dynamically
              double storeLat = store['latitude'];
              double storeLng = store['longitude'];
              double distance = storeProvider.calculateDistance(storeLat, storeLng);

              return StoreCard(
                id: id,
                productName: store['storeName'],
                imageUrl: store['imageUrl'],
                distance: distance, // Using dynamically calculated distance
                district: store['district'],
                isFavorite: true, // Already in favorites
                screenType: screenType,
                onAddToCart: () {
                  print('${store['storeName']} selected');
                },
                onRemoveFromCart: () {
                  // Toggle favorite using provider
                  storeProvider.toggleFavorite(id);
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