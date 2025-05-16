import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // For Position type
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/user/user_state.dart';
import 'models/store.dart';
import 'custom_widgets/store_card.dart';
import 'favorites_screen.dart'; // Import the new favorites screen
import 'search_screen.dart'; // Import the new search screen

class HomeScreen extends StatefulWidget {
  final int? userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoreCubit>().setUserId(widget.userId);
    context.read<StoreCubit>().fetchStoresFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          List<Widget> slivers = [];

          // AppBar and Search Button (always present)
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.only(top: 0.0),
              sliver: SliverAppBar(
                title: BlocBuilder<UserCubit, UserState>(
                  builder: (context, userState) {
                    String username = 'User'; // Default
                    if (userState is UserAuthenticated) {
                      username = userState.user.name;
                    }
                    return Text(
                      'Welcome, $username 👋',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                floating: true, // App bar floats
                pinned: true, // Search bar stays pinned
                centerTitle: true,
                elevation: 0.5,
                actions: [
                  BlocBuilder<StoreCubit, StoreState>(
                    builder: (context, storeState) {
                      final storeCubit = context.read<StoreCubit>();
                      bool hasFavorites = storeCubit.favoriteStores.isNotEmpty;
                      int favoriteCount = storeCubit.favoriteStores.length;

                      const Color activeColor = Colors.redAccent;
                      final Color inactiveColor = Colors.grey[700]!;
                      const Color activeIconTextColor = Colors.white;
                      final Color inactiveIconTextColor = inactiveColor;
                      final Color inactiveBackgroundColor = Colors.grey[200]!;

                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 12.0,
                            top: 8.0,
                            bottom: 8.0), // Adjusted for centering
                        child: ActionChip(
                          backgroundColor: hasFavorites
                              ? activeColor
                              : inactiveBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          labelPadding: EdgeInsets.only(
                              left:
                                  favoriteCount > 0 || !hasFavorites ? 4.0 : 0),
                          avatar: Icon(
                            hasFavorites
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: hasFavorites
                                ? activeIconTextColor
                                : inactiveIconTextColor,
                            size: 18,
                          ),
                          label: Text(
                            favoriteCount > 0
                                ? '$favoriteCount'
                                : (hasFavorites ? '' : 'Favorites'),
                            style: TextStyle(
                              color: hasFavorites
                                  ? activeIconTextColor
                                  : inactiveIconTextColor,
                              fontWeight: hasFavorites
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FavoritesScreen()),
                            );
                          },
                          tooltip: 'My Favorites',
                        ),
                      );
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight + 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Search Products in Restaurants...'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                        if (mounted) {
                          context.read<StoreCubit>().fetchStoresFromApi();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          );

          // Content based on state
          if (state is StoreInitial || state is StoreLoading) {
            // Search empty on SearchScreen
            slivers.add(const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())));
          } else if (state is StoreError) {
            slivers.add(SliverFillRemaining(
                child: Center(
                    child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
            ))));
          } else if (state is StoresLoaded) {
            var storeList = state.allStores.values.toList();
            if (storeList.isEmpty) {
              slivers.add(SliverFillRemaining(
                  child: _buildNoResultsView(
                      'No stores available right now. Tap search to find products.')));
            } else {
              slivers
                  .add(_buildStoreGridSliver(storeList, state.currentPosition));
            }
          } else {
            slivers.add(const SliverFillRemaining(
                child: Center(
                    child: Text(
              'Welcome! Discover stores or use search.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ))));
          }

          return CustomScrollView(slivers: slivers);
        },
      ),
    );
  }

  Widget _buildNoResultsView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(message,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text("Search Products"),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
                if (mounted) {
                  context.read<StoreCubit>().fetchStoresFromApi();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStoreGridSliver(
      List<Store> storeList, Position? currentPosition) {
    if (storeList.isEmpty) {
      return SliverFillRemaining(
        child: _buildNoResultsView("No stores to display in this list."),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            Store store = storeList[index];
            double distance = 0.0;
            if (currentPosition != null) {
              distance = context
                  .read<StoreCubit>()
                  .calculateDistance(store.latitude, store.longitude);
            }

            return StoreCard(
              id: store.restaurantID,
              storeName: store.restaurantName,
              imageUrl: store.imageUrl,
              district: store.district,
              distance: distance,
            );
          },
          childCount: storeList.length,
        ),
      ),
    );
  }
}
