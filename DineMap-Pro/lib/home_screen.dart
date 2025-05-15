// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/user/user_state.dart';
import 'models/store.dart'; // Ensure your Store model is correctly defined
import 'custom_widgets/store_card.dart'; // Your StoreCard widget
// Import your MapScreen if you have it for navigation later
// import 'map_screen.dart';
// import 'package:Maps_flutter/Maps_flutter.dart'; // For LatLng if passing to map

class HomeScreen extends StatefulWidget {
  // Changed to StatefulWidget for TextEditingController
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        Widget bodyContent;

        if (state is StoreInitial || state is StoreLoading) {
          bodyContent = const Center(child: CircularProgressIndicator());
        } else if (state is StoreSearchLoading) {
          // Handle search loading specifically
          bodyContent = const Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Searching for products..."),
            ],
          ));
        } else if (state is StoreError) {
          bodyContent = Center(child: Text('Error: ${state.message}'));
        } else if (state is StoresLoaded) {
          var storeList = state.allStores.values.toList();
          if (storeList.isEmpty) {
            bodyContent = const Center(child: Text('No stores available.'));
          } else {
            bodyContent = _buildStoreGrid(storeList, state.currentPosition);
          }
        } else if (state is StoreSearchResultsLoaded) {
          if (state.searchedRestaurants.isEmpty) {
            // Should be handled by StoreSearchEmpty ideally
            bodyContent = _buildNoResultsView(
                "No restaurants found matching your search.");
          } else {
            bodyContent = _buildStoreGrid(
                state.searchedRestaurants, state.currentPosition);
            // Optionally, add a button to navigate to the map here
            // if (state.searchedRestaurants.isNotEmpty) {
            //   bodyContent = Column(
            //     children: [
            //       ElevatedButton(
            //         onPressed: () {
            //           // Navigate to MapScreen
            //           // Navigator.push(context, MaterialPageRoute(builder: (_) =>
            //           //   MapScreen(stores: state.searchedRestaurants, userLocation: state.currentPosition != null ? LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude) : null)));
            //         },
            //         child: Text("View on Map"),
            //       ),
            //       Expanded(child: _buildStoreGrid(state.searchedRestaurants, state.currentPosition)),
            //     ],
            //   );
            // }
          }
        } else if (state is StoreSearchEmpty) {
          bodyContent = _buildNoResultsView(
              "No restaurants found for the specified product.");
        } else {
          bodyContent = const Center(
              child: Text(
                  'Welcome! Search for products in restaurants.')); // Fallback or initial empty view
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 10.0),
                sliver: SliverAppBar(
                  title: BlocBuilder<UserCubit, UserState>(
                    builder: (context, userState) {
                      String username = 'User';
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
                  floating: true,
                  pinned: true,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight + 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Products in Restaurants...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    // Fetch all stores again or go to an initial state
                                    context
                                        .read<StoreCubit>()
                                        .fetchStoresFromApi();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onSubmitted: (String query) {
                          if (query.trim().isNotEmpty) {
                            context
                                .read<StoreCubit>()
                                .searchRestaurantsByProduct(query);
                          } else {
                            // If submitted with empty query, load all stores
                            context.read<StoreCubit>().fetchStoresFromApi();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Display content based on state
              SliverFillRemaining(
                // Use SliverFillRemaining if the bodyContent is not a Sliver itself
                child: bodyContent,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoResultsView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              context
                  .read<StoreCubit>()
                  .fetchStoresFromApi(); // Go back to all stores
            },
            child: const Text("Clear Search"),
          )
        ],
      ),
    );
  }

  Widget _buildStoreGrid(List<Store> storeList, Position? currentPosition) {
    if (storeList.isEmpty) {
      return _buildNoResultsView(
          "No stores to display."); // Should ideally be handled by specific states
    }
    return CustomScrollView(
        // If _buildStoreGrid itself returns a scrollable, remove the outer CustomScrollView's SliverFillRemaining
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(15.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.80, // Adjust as needed
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
                    // You might want to pass and display the distance
                    // distance: distance > 0 ? '${distance}km' : null,
                    // You might also want to pass products if StoreCard can display them
                    // products: store.products,
                    // onTap: () { /* Navigate to store details screen */ }
                  );
                },
                childCount: storeList.length,
              ),
            ),
          ),
        ]);
  }
}
