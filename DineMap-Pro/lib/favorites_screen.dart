// lib/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // For Position type

import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'models/store.dart';
import 'custom_widgets/store_card.dart'; // Make sure this path is correct

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use context.watch to rebuild when StoreCubit emits a new state.
    // We then get the data directly from the cubit's getters.
    final storeCubit = context.watch<StoreCubit>();
    final List<Store> favoriteStoresList = storeCubit.favoriteStores.values.toList();
    final Position? currentPosition = storeCubit.currentPositionGetter;
    final StoreState currentState = storeCubit.state; // To check for loading/error states

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorite Stores'),
        centerTitle: true,
      ),
      body: Builder( // Using Builder for context, though direct use often works
        builder: (context) {
          // Handle general loading/error states from the cubit
          if (currentState is StoreInitial || currentState is StoreLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (currentState is StoreError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${currentState.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          // If not loading or error, display favorites (or empty message)
          if (favoriteStoresList.isEmpty) {
            return _buildNoFavoritesView(context);
          }

          return _buildFavoritesGrid(context, favoriteStoresList, currentPosition);
        },
      ),
    );
  }

  Widget _buildNoFavoritesView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              "You haven't favorited any stores yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to where user can find stores
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Find Stores to Favorite"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(
      BuildContext context,
      List<Store> favoriteStoresList,
      Position? currentPosition,
      ) {
    return GridView.builder(
      padding: const EdgeInsets.all(15.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // You can adjust this
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.82, // Adjust based on your StoreCard content
      ),
      itemCount: favoriteStoresList.length,
      itemBuilder: (context, index) {
        final store = favoriteStoresList[index];
        double distance = 0.0;

        // Calculate distance if position and store coordinates are available
        if (currentPosition != null &&
            store.latitude != 0.0 && // Basic check for valid coordinates
            store.longitude != 0.0) {
          distance = context
              .read<StoreCubit>()
              .calculateDistance(store.latitude, store.longitude);
        }

        return StoreCard(
          // Using ValueKey ensures the widget updates correctly if the list order changes
          // or items are removed/added.
          key: ValueKey(store.restaurantID),
          id: store.restaurantID,
          storeName: store.restaurantName,
          imageUrl: store.imageUrl,
          district: store.district,
          distance: distance,
        );
      },
    );
  }
}