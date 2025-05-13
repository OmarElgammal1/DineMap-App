import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_widgets/store_card.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';

class FavoritesScreen extends StatelessWidget {
  final String screenType;

  FavoritesScreen({required this.screenType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state is StoreInitial) {
          return Center(child: CircularProgressIndicator());
        } else if (state is StoreError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is StoresLoaded) {
          var favoriteStores = state.favoriteStores;
          var storeList = favoriteStores.entries.toList();

          // Show message when there are no favorites
          if (storeList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: Colors.grey[400]),
                  SizedBox(height: 10),
                  Text(
                    'No favorite stores yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Add stores to your favorites',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

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
                    double distance = context.read<StoreCubit>().calculateDistance(storeLat, storeLng);

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
                        // Toggle favorite using cubit
                        context.read<StoreCubit>().toggleFavorite(id);
                        print('${store['storeName']} removed from favorites');
                      },
                    );
                  }, childCount: storeList.length),
                ),
              ),
            ],
          );
        }

        return SizedBox(); // Fallback
      },
    );
  }
}